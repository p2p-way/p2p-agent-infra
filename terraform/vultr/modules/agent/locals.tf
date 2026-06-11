# Locals
locals {
  create               = var.agent_create
  agent_name           = lower(replace(var.agent_name, " ", "-"))
  region               = var.region
  location_description = try(data.vultr_region.current[0].city, "")
  open_tcp_ports       = try(replace(element(var.open_ports, 0), "-", ":"), null)
  open_udp_ports       = try(replace(element(var.open_ports, 1), "-", ":"), null)
  firewall_protocols   = var.enable_ipv6 ? ["v4", "v6"] : ["v4"]
  allow_ssh            = local.create ? var.allow_ssh : []
  resource_name        = "${local.agent_name}-${local.region}"
  resource_description = "${var.agent_name} - ${local.location_description}"
  tags                 = [local.resource_name]
}

# Region
data "vultr_region" "current" {
  count = local.create ? 1 : 0

  filter {
    name   = "id"
    values = [local.region]
  }
}
