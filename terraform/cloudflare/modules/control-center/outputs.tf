# Control center URL
output "url" {
  description = "Control center URL"
  value       = try("https://${cloudflare_r2_custom_domain.cc[0].domain}", null)
}
