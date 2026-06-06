# Agent output
output "agent_instances" {
  value = [for instance in scaleway_instance_server.agent : "${instance.name} - ${instance.public_ips[0].address}"]
}
