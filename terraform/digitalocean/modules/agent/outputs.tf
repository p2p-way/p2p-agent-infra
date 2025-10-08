# Agent output
output "agent_instances" {
  value = [for instance in digitalocean_droplet.agent : "${instance.name} - ${instance.ipv4_address}"]
}
