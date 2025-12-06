variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type for Swarm nodes"
  type        = string
  default     = "t4g.nano" # ARM (Graviton). Use t3.small if x86_64.
}

variable "ssh_key_name" {
  description = "Name of the EC2 key pair to use"
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "CIDR allowed to SSH into the node"
  type        = string
  default     = "0.0.0.0/0" # change to your IP/CIDR later
}
