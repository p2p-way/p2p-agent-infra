# Locals
locals {
  create               = var.agent_create
  agent_name           = lower(replace(var.agent_name, " ", "-"))
  region               = var.region
  location_description = try(data.linode_region.current[0].label, "")
  agent_open_tcp_ports = try(element(var.agent_open_ports, 0), null)
  agent_open_udp_ports = try(element(var.agent_open_ports, 1), null)
  resource_name        = "${local.agent_name}-${local.region}"
  resource_description = "${var.agent_name} - ${local.location_description}"
  tags                 = [local.resource_name]
}

# Region
data "linode_region" "current" {
  count = local.create ? 1 : 0

  id = local.region
}
