# Agent output
output "agent_instances" {
  value = [for instance in vultr_instance.agent : "${instance.label} - ${instance.main_ip}"]
}
