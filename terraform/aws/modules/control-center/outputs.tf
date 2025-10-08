# CloudFront output
output "url" {
  description = "Control center URL"
  value       = try(["https://${aws_cloudfront_distribution.cc[0].domain_name}"], [])
}
