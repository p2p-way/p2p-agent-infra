# Amsterdam, AMS3
module "nl-ams-3" {
  source = "./modules/agent"

  region                   = "nl-ams-3"
  project_id               = local.project_id
  agent_create             = var.agent_create
  agent_name               = var.agent_name
  default_tags             = var.default_tags
  open_ports               = var.open_ports
  allow_ssh                = var.allow_ssh
  instance_type            = var.instance_type
  os_name                  = var.os_name
  os_disk_size             = var.os_disk_size
  os_disk_type             = var.os_disk_type
  desired_capacity         = var.desired_capacity
  enable_ipv6              = var.enable_ipv6
  agent_cron_schedule      = var.agent_cron_schedule
  agent_commands           = var.agent_commands
  agent_commands_defaults  = var.agent_commands_defaults
  agent_cc_hosts           = var.agent_cc_hosts
  agent_cc_commands        = var.agent_cc_commands
  agent_cc_commands_prefix = var.agent_cc_commands_prefix
  agent_repository_ssh_key = local.agent_repository_ssh_key
  radar_url                = var.radar_url
  radar_url_file           = var.radar_url_file
}

# Agent instances
output "agent_instances_nl-ams-3" {
  value = join("\n", flatten([for instance in module.nl-ams-3 : instance]))
}
