output "certificate_arn" {
  description = "ARN of the ACM certificate."
  value       = aws_acm_certificate.this.arn
}

output "domain_name" {
  description = "Domain name on the ACM certificate."
  value       = aws_acm_certificate.this.domain_name
}
