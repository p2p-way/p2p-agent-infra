# Locals - Main
locals {
  create               = var.agent_create
  agent_name           = lower(replace(var.agent_name, " ", "-"))
  region               = var.region
  location_description = try(data.digitalocean_region.current[0].name, "")
  open_tcp_ports       = try(element(var.open_ports, 0), null)
  open_udp_ports       = try(element(var.open_ports, 1), null)
  resource_name        = "${local.agent_name}-${local.region}"
  resource_description = "${var.agent_name} - ${local.location_description}"
}

# Region
data "digitalocean_region" "current" {
  count = local.create ? 1 : 0

  slug = local.region
}
