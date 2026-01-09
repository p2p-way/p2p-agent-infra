# Multiple regions
module "multi-regions" {
  source = "./modules/agent"

  for_each = toset(data.digitalocean_regions.all-regions[0].regions[*].slug)
  # for_each = toset(["fra1"])

  region                   = each.key
  agent_create             = var.agent_create
  agent_name               = var.agent_name
  agent_open_ports         = var.agent_open_ports
  allow_ssh                = var.allow_ssh
  ssh_keys                 = local.ssh_keys
  droplet_size             = each.key == "atl1" ? "s-1vcpu-1gb-amd" : var.droplet_size
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
}

# All regions
data "digitalocean_regions" "all-regions" {
  count = var.agent_create ? 1 : 0

  filter {
    key    = "available"
    values = ["true"]
  }

  sort {
    key       = "slug"
    direction = "asc"
  }
}

# Agent instances
output "agent_instances_all" {
  value = join("\n", flatten([for instance in values(module.multi-regions) : instance.agent_instances]))
}
