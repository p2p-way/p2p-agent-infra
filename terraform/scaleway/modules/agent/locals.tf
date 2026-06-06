# Locals - Main
locals {
  create                   = var.agent_create
  agent_name               = lower(replace(var.agent_name, " ", "-"))
  region                   = var.region
  agent_open_tcp_ports     = try(element(var.agent_open_ports, 0), null)
  agent_open_udp_ports     = try(element(var.agent_open_ports, 1), null)
  security_group_protocols = var.enable_ipv6 ? ["v4", "v6"] : ["v4"]
  resource_name            = "${local.agent_name}-${local.region}"
  resource_description     = "${var.agent_name} - ${local.region}"
  default_tags             = [for k, v in var.default_tags : "${k}=${replace(v, "/ /", "-")}"]
}
