# CloudFront output
output "url" {
  description = "Control center URL"
  value       = flatten([try("https://${aws_cloudfront_distribution.cc[0].domain_name}${aws_cloudfront_distribution.cc[0].ordered_cache_behavior[0].path_pattern}", try("https://${aws_cloudfront_distribution.cc[0].domain_name}", []))])
}
