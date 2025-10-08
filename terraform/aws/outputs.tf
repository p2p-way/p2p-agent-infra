# CloudFront CC URL
output "cloudfront_cc_url" {
  description = "CloudFront CC URL"
  value       = length(module.control-center.url) > 0 ? module.control-center.url : null
}

# SSH private key - Agent
output "instance_private_key" {
  description = "Agent instance SSH private key"
  value       = try(tls_private_key.agent[0].private_key_openssh, null)
  sensitive   = true
}

# SSH public key - Agent
output "instance_public_key" {
  description = "Agent instance SSH public key"
  value       = try(chomp(tls_private_key.agent[0].public_key_openssh), null)
}

# SSH private key - Repository
output "repository_private_key" {
  description = "Repository SSH private key"
  value       = try(tls_private_key.repository[0].private_key_openssh, null)
  sensitive   = true
}

# SSH public key - Repository
output "repository_public_key" {
  description = "Repository SSH public key"
  value       = try(chomp(tls_private_key.repository[0].public_key_openssh), null)
}
