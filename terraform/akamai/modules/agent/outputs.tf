# Agent output
output "agent_instances" {
  value = [for instance in linode_instance.agent : "${instance.label} - ${instance.ipv4}"]
}
