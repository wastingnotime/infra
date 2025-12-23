variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type for Swarm nodes"
  type        = string
  default     = "t4g.micro" # ARM (Graviton). Use t3.small if x86_64.
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

variable "enable_ssh_to_manager" {
  description = "Enable SSH access to the Swarm manager"
  type        = bool
  default     = false
}

variable "ssh_cidr_manager" {
  description = "CIDR allowed to SSH into the Swarm manager when enabled"
  type        = string
  default     = "189.34.167.230/32"
}

variable "cloudfront_origin_prefix_list_id" {
  description = "AWS-managed prefix list ID for CloudFront origin-facing ranges"
  type        = string
}
