terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# --- Networking: reuse default VPC + subnets for now ---

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# --- Security Group for Swarm node ---

resource "aws_security_group" "swarm_node" {
  name        = "swarm-node-sg"
  description = "Security group for Docker Swarm node"
  vpc_id      = data.aws_vpc.default.id

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  # HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Swarm management (for future extra nodes/same SG)
  ingress {
    from_port = 2377
    to_port   = 2377
    protocol  = "tcp"
    self      = true
  }

  # Swarm node communication
  ingress {
    from_port = 7946
    to_port   = 7946
    protocol  = "tcp"
    self      = true
  }

  ingress {
    from_port = 7946
    to_port   = 7946
    protocol  = "udp"
    self      = true
  }

  # Swarm overlay network
  ingress {
    from_port = 4789
    to_port   = 4789
    protocol  = "udp"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# --- IAM role so the instance can talk to ECR / SSM, etc. ---

resource "aws_iam_role" "swarm_node_role" {
  name = "swarm-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Basic: ECR read-only + SSM access (optional but handy)
resource "aws_iam_role_policy_attachment" "ecr_readonly" {
  role       = aws_iam_role.swarm_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.swarm_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "swarm_node_profile" {
  name = "swarm-node-instance-profile"
  role = aws_iam_role.swarm_node_role.name
}

# --- Find a recent Amazon Linux 2023 ARM64 AMI ---

data "aws_ami" "al2023_arm" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-kernel-6.1-arm64"]
  }

  filter {
    name   = "architecture"
    values = ["arm64"]
  }
}

# --- User data: install Docker and init Swarm (single manager) ---

locals {
  user_data = <<-EOF
    #!/bin/bash
    set -xe

    # Update system
    dnf update -y

    # Install Docker on Amazon Linux 2023
    dnf install -y docker

    systemctl enable docker
    systemctl start docker

    # Allow ec2-user to use docker
    usermod -aG docker ec2-user || true

    # Initialize swarm manager (single node for now)
    PRIVATE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4 || echo "127.0.0.1")

    # If swarm is not already active, init
    docker info 2>/dev/null | grep -q "Swarm: active" || \
      docker swarm init --advertise-addr "$${PRIVATE_IP}" || true

    # Optional: pull some base images so first deploy is faster
    docker pull nginx:alpine || true
  EOF
}

# --- Launch template for Swarm nodes ---

resource "aws_launch_template" "swarm_node" {
  name_prefix   = "swarm-node-"
  image_id      = data.aws_ami.al2023_arm.id
  instance_type = var.instance_type
  key_name      = var.ssh_key_name

  iam_instance_profile {
    name = aws_iam_instance_profile.swarm_node_profile.name
  }

  vpc_security_group_ids = [aws_security_group.swarm_node.id]

  user_data = base64encode(local.user_data)

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size = 30 # for testing; bump to 20–40 GB later
      volume_type = "gp3"
    }
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "swarm-node"
      Role = "swarm-manager"
    }
  }
}

# --- Auto Scaling Group (for now: single node) ---

resource "aws_autoscaling_group" "swarm_asg" {
  name                      = "swarm-asg"
  max_size                  = 1
  min_size                  = 1
  desired_capacity          = 1
  vpc_zone_identifier       = data.aws_subnets.default.ids
  health_check_type         = "EC2"
  health_check_grace_period = 120

  launch_template {
    id      = aws_launch_template.swarm_node.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "swarm-node"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}
