variable "aws_region" {
  type        = string
  description = "AWS region for Route53 provider."
  default     = "us-east-1"
}

variable "cloudfront_domain_name" {
  type        = string
  description = "CloudFront distribution domain name."
  default     = "dgr73dx8fqznr.cloudfront.net"
}

variable "cloudfront_hosted_zone_id" {
  type        = string
  description = "CloudFront hosted zone ID."
  default = "Z2FDTNDATAQYW2"
}
