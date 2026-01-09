# Osaka, JP
module "jp-osa" {
  source = "./modules/agent"

  region                   = "jp-osa"
  agent_create             = var.agent_create
  agent_name               = var.agent_name
  agent_open_ports         = var.agent_open_ports
  allow_ssh                = var.allow_ssh
  authorized_keys          = local.ssh_keys
  type                     = var.type
  os_name                  = var.os_name
  desired_capacity         = var.desired_capacity
  agent_cron_schedule      = var.agent_cron_schedule
  agent_commands           = var.agent_commands
  agent_commands_defaults  = var.agent_commands_defaults
  agent_cc_hosts           = var.agent_cc_hosts
  agent_cc_commands        = var.agent_cc_commands
  agent_cc_commands_prefix = var.agent_cc_commands_prefix
  agent_repository_ssh_key = local.agent_repository_ssh_key
}

# Agent instances
output "agent_instances_jp-osa" {
  value = join("\n", flatten([for instance in module.jp-osa : instance]))
}
