# Multiple regions
module "multi-regions" {
  source = "./modules/agent"

  for_each = toset(sort(data.hcloud_locations.all-locations[0].locations[*].name))
  # for_each = toset(["fsn1"])

  location                  = each.key
  agent_create              = var.agent_create
  agent_name                = var.agent_name
  agent_p2p_archivist_ports = var.agent_p2p_archivist_ports
  agent_p2p_ipfs_ports      = var.agent_p2p_ipfs_ports
  agent_p2p_radicle_ports   = var.agent_p2p_radicle_ports
  agent_p2p_ton_ports       = var.agent_p2p_ton_ports
  agent_p2p_torrent_ports   = var.agent_p2p_torrent_ports
  agent_custom_ports        = var.agent_custom_ports
  default_labels            = var.default_labels
  allow_ssh                 = var.allow_ssh
  ssh_keys                  = local.ssh_keys
  server_type               = var.server_type
  os_name                   = var.os_name
  desired_capacity          = var.desired_capacity
  enable_ipv6               = var.enable_ipv6
  agent_cron_schedule       = var.agent_cron_schedule
  agent_commands            = var.agent_commands
  agent_commands_defaults   = var.agent_commands_defaults
  agent_cc_hosts            = var.agent_cc_hosts
  agent_cc_commands         = var.agent_cc_commands
  agent_cc_commands_prefix  = var.agent_cc_commands_prefix
  agent_repository_ssh_key  = local.agent_repository_ssh_key
}

# All locations
data "hcloud_locations" "all-locations" {
  count = var.agent_create ? 1 : 0
}

# Agent instances
output "agent_instances_all" {
  value = join("\n", flatten([for instance in values(module.multi-regions) : instance.agent_instances]))
}
