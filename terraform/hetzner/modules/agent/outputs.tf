# Agent output
output "agent_instances" {
  value = [for instance in hcloud_server.agent : "${instance.name} - ${instance.ipv4_address}"]
}
