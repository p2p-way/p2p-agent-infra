# Multiple regions
module "multi-regions" {
  source = "./modules/agent"

  for_each = toset(jsondecode(data.http.vultr-regions.response_body).regions[*].id)
  # for_each = toset(["fra"])

  region                   = each.key
  agent_create             = var.agent_create
  agent_name               = var.agent_name
  agent_open_ports         = var.agent_open_ports
  allow_ssh                = var.allow_ssh
  ssh_key_ids              = local.ssh_keys
  plan                     = each.key == "hnl" ? "vhp-1c-1gb" : each.key == "mxp" ? "voc-g-1c-4gb-30s" : var.plan
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
output "agent_instances_all" {
  value = join("\n", flatten([for instance in values(module.multi-regions) : instance.agent_instances]))
}

# All regions
data "http" "vultr-regions" {
  url = "https://api.vultr.com/v2/regions"

  method = "GET"
  request_headers = {
    Authorization = "Bearer ${var.VULTR_API_KEY}"
  }
}
