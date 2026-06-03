# Agent output
output "agent_instances" {
  value = [for instance in exoscale_compute_instance.agent : "${instance.name} - ${instance.public_ip_address}"]
}
