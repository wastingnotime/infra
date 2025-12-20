variable "aws_region" {
  type        = string
  description = "AWS region for the SQS queue."
  default     = "us-east-1"
}

variable "queue_name" {
  type        = string
  description = "Name of the existing SQS queue."
  default     = "wnt-plausible-events"
}
