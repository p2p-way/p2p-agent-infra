# Multiple regions
module "multi-regions" {
  source = "./modules/agent"

  for_each = toset(data.upcloud_zones.all-zones[0].zone_ids)
  # for_each = toset(["de-fra1"])

  region                   = each.key
  agent_create             = var.agent_create
  agent_name               = var.agent_name
  default_labels           = var.default_labels
  open_ports               = var.open_ports
  allow_ssh                = var.allow_ssh
  keys                     = local.keys
  instance_type            = var.instance_type
  os_name                  = var.os_name
  storage_size             = var.storage_size
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
output "agent_instances_all" {
  value = join("\n", flatten([for instance in values(module.multi-regions) : instance.agent_instances]))
}

# All zones
data "upcloud_zones" "all-zones" {
  count = var.agent_create ? 1 : 0

  filter_type = "public"
}
