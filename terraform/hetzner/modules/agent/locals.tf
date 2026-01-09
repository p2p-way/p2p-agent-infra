# Locals
locals {
  create               = var.agent_create
  agent_name           = lower(replace(var.agent_name, " ", "-"))
  location             = var.location
  location_description = try(data.hcloud_location.current[0].description, "")
  agent_open_tcp_ports = try(element(var.agent_open_ports, 0), null)
  agent_open_udp_ports = try(element(var.agent_open_ports, 1), null)
  resource_name        = "${local.agent_name}-${local.location}"
  resource_description = "${var.agent_name} - ${local.location_description}"
  default_labels       = { for k, v in var.default_labels : k => replace(v, "/ /", "-") }
}

# Location
data "hcloud_location" "current" {
  count = local.create ? 1 : 0

  name = var.location
}
