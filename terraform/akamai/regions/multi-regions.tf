# Multiple regions
module "multi-regions" {
  source = "./modules/agent"

  # Exclude regions not-available for a new customers
  for_each = setsubtract(sort(data.linode_regions.all-regions[0].regions[*].id), ["au-mel", "eu-west", "id-cgk", "us-iad"])

  # Just 5 first regions
  # for_each = toset(slice(tolist(setsubtract(sort(data.linode_regions.all-regions[0].regions[*].id), ["au-mel", "eu-west", "id-cgk", "us-iad"])), 0, 5))

  # Specific regions
  # for_each = toset(["eu-central"])

  region                    = each.key
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

# All regions
data "linode_regions" "all-regions" {
  count = var.agent_create ? 1 : 0

  filter {
    name   = "status"
    values = ["ok"]
  }
}

# Agent instances
output "agent_instances_all" {
  value = join("\n", flatten([for instance in values(module.multi-regions) : instance.agent_instances]))
}
