# Control center URL
output "control_center_url" {
  description = "Control center URL"
  value       = module.control-center.url != null ? module.control-center.url : null
}

# Analytics URL
output "analytics_url" {
  description = "Analytics URL"
  value       = module.radar.analytics_url
}

# Radar Auth
output "radar_auth" {
  description = "Radar Auth"
  value       = module.radar.radar_auth
}

# Radar URL
output "radar_url" {
  description = "Radar URL"
  value       = module.radar.radar_url
}
