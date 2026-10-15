# Cloudinit config
output "cloudinit_config" {
  description = "Cloudinit config"
  value       = data.cloudinit_config.agent.rendered
}
