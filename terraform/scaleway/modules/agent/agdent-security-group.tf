# Security group
resource "scaleway_instance_security_group" "agent" {
  count = local.create ? 1 : 0

  name        = local.resource_name
  description = local.resource_description

  inbound_default_policy  = "drop"
  outbound_default_policy = "accept"
  external_rules          = true

  zone       = var.region
  project_id = var.project_id
}

# Security group rules
resource "scaleway_instance_security_group_rules" "agent" {
  count = local.create ? 1 : 0

  security_group_id = scaleway_instance_security_group.agent[count.index].id

  # TCP
  dynamic "inbound_rule" {
    for_each = local.open_tcp_ports != null ? toset(local.security_group_protocols) : []

    content {
      action     = "accept"
      port_range = local.open_tcp_ports
      ip_range   = inbound_rule.value == "v4" ? "0.0.0.0/0" : "::/0"
    }
  }

  # UDP
  dynamic "inbound_rule" {
    for_each = local.open_udp_ports != null ? toset(local.security_group_protocols) : []

    content {
      action     = "accept"
      port_range = local.open_udp_ports
      ip_range   = inbound_rule.value == "v4" ? "0.0.0.0/0" : "::/0"
    }
  }

  # SSH
  dynamic "inbound_rule" {
    for_each = var.allow_ssh

    content {
      action   = "accept"
      port     = 22
      ip_range = inbound_rule.value
    }
  }
}
