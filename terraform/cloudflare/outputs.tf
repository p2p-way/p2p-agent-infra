# Control center URL
output "control_center_url" {
  description = "Control center URL"
  value       = module.control-center.url != null ? module.control-center.url : null
}
