# Locals - Main
locals {
  create               = var.agent_create
  agent_name           = lower(replace(var.agent_name, " ", "-"))
  region               = var.region
  location_description = local.region
  open_tcp_ports       = try(element(var.open_ports, 0), null)
  open_udp_ports       = try(element(var.open_ports, 1), null)
  firewall_protocols   = var.ipv6 ? ["v4", "v6"] : ["v4"]
  allow_ssh            = local.create ? var.allow_ssh : []
  resource_name        = "${local.agent_name}-${local.region}"
  resource_description = "${var.agent_name} - ${local.location_description}"
  tags                 = [local.resource_name]
}
