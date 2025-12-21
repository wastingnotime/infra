output "zone_id" {
  description = "Route53 hosted zone ID for wastingnotime.org."
  value       = data.aws_route53_zone.root.zone_id
}

output "fqdn_a" {
  description = "FQDN for the A record."
  value       = aws_route53_record.root_a.fqdn
}

output "fqdn_aaaa" {
  description = "FQDN for the AAAA record."
  value       = aws_route53_record.root_aaaa.fqdn
}
