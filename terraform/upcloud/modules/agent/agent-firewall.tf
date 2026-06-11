# Firewall
resource "upcloud_firewall_rules" "agent" {
  count = local.create ? var.desired_capacity : 0

  server_id = upcloud_server.agent[count.index].id

  # TCP
  dynamic "firewall_rule" {
    for_each = local.open_tcp_ports != null ? [1] : []

    content {
      action                 = "accept"
      comment                = "TCP - Any"
      destination_port_start = element(split("-", local.open_tcp_ports), 0)
      destination_port_end   = element(split("-", local.open_tcp_ports), 1)
      direction              = "in"
      family                 = "IPv4"
      protocol               = "tcp"
      source_address_start   = "0.0.0.0"
      source_address_end     = "0.0.0.0"
    }
  }

  # UDP
  dynamic "firewall_rule" {
    for_each = local.open_udp_ports != null ? [1] : []

    content {
      action                 = "accept"
      comment                = "UDP - Any"
      destination_port_start = element(split("-", local.open_udp_ports), 0)
      destination_port_end   = element(split("-", local.open_udp_ports), 1)
      direction              = "in"
      family                 = "IPv4"
      protocol               = "udp"
      source_address_start   = "0.0.0.0"
      source_address_end     = "0.0.0.0"
    }
  }

  # SSH
  dynamic "firewall_rule" {
    for_each = var.allow_ssh

    content {
      action                 = "accept"
      comment                = "SSH - ${firewall_rule.value}"
      destination_port_end   = "22"
      destination_port_start = "22"
      direction              = "in"
      family                 = "IPv4"
      protocol               = "tcp"
      source_address_start   = cidrhost(firewall_rule.value, 1)
      source_address_end     = cidrhost(firewall_rule.value, -1)
    }
  }

  # Default
  firewall_rule {
    action    = "drop"
    comment   = "Drop any IPv4"
    direction = "in"
    family    = "IPv4"
  }

  dynamic "firewall_rule" {
    for_each = var.enable_ipv6 ? [1] : []

    content {
      action    = "drop"
      comment   = "Drop any IPv6"
      direction = "in"
      family    = "IPv6"
    }
  }
}
