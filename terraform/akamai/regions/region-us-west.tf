# Fremont, CA
module "us-west" {
  source = "./modules/agent"

  region                    = "us-west"
  agent_create              = var.agent_create
  agent_name                = var.agent_name
  agent_p2p_archivist_ports = var.agent_p2p_archivist_ports
  agent_p2p_ipfs_ports      = var.agent_p2p_ipfs_ports
  agent_p2p_radicle_ports   = var.agent_p2p_radicle_ports
  agent_p2p_ton_ports       = var.agent_p2p_ton_ports
  agent_p2p_torrent_ports   = var.agent_p2p_torrent_ports
  agent_custom_ports        = var.agent_custom_ports
  allow_ssh                 = var.allow_ssh
  authorized_keys           = local.ssh_keys
  type                      = var.type
  os_name                   = var.os_name
  desired_capacity          = var.desired_capacity
  agent_cron_schedule       = var.agent_cron_schedule
  agent_commands            = var.agent_commands
  agent_commands_defaults   = var.agent_commands_defaults
  agent_cc_hosts            = var.agent_cc_hosts
  agent_cc_commands         = var.agent_cc_commands
  agent_cc_commands_prefix  = var.agent_cc_commands_prefix
  agent_repository_ssh_key  = local.agent_repository_ssh_key
}

# Agent instances
output "agent_instances_us-west" {
  value = join("\n", flatten([for instance in module.us-west : instance]))
}
