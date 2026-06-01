# Agent output
output "agent_instances" {
  value = [for instance in upcloud_server.agent : "${instance.title} - ${instance.network_interface[0].ip_address}"]
}
