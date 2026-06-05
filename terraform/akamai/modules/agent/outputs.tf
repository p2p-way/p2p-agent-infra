# Agent output
output "agent_instances" {
  value = [for instance in linode_instance.agent : "${instance.label} - ${join(",", tolist(instance.ipv4))}"]
}
