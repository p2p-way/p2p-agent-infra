# Milan, IT - Europe
module "mxp" {
  source = "./modules/agent"

  region                   = "mxp"
  agent_create             = var.agent_create
  agent_name               = var.agent_name
  open_ports               = var.open_ports
  allow_ssh                = var.allow_ssh
  ssh_key_ids              = local.ssh_keys
  instance_type            = "voc-g-1c-4gb-30s" # var.instance_type
  os_name                  = var.os_name
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
output "agent_instances_mxp" {
  value = join("\n", flatten([for instance in module.mxp : instance]))
}
