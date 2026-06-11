# Firewall
resource "hcloud_firewall" "agent" {
  count = local.create ? 1 : 0

  name = local.resource_name

  # TCP
  dynamic "rule" {
    for_each = local.open_tcp_ports != null ? [1] : []

    content {
      direction   = "in"
      protocol    = "tcp"
      port        = local.open_tcp_ports
      source_ips  = var.enable_ipv6 ? ["0.0.0.0/0", "::/0"] : ["0.0.0.0/0"]
      description = "TCP - Any"
    }
  }

  # UDP
  dynamic "rule" {
    for_each = local.open_udp_ports != null ? [1] : []

    content {
      direction   = "in"
      protocol    = "udp"
      port        = local.open_udp_ports
      source_ips  = var.enable_ipv6 ? ["0.0.0.0/0", "::/0"] : ["0.0.0.0/0"]
      description = "UDP - Any"
    }
  }

  # SSH
  dynamic "rule" {
    for_each = var.allow_ssh

    content {
      direction   = "in"
      protocol    = "tcp"
      port        = "22"
      source_ips  = [rule.value]
      description = "SSH - ${rule.value}"
    }
  }
}

# Firewall attachment
resource "hcloud_firewall_attachment" "agent" {
  count = local.create ? 1 : 0

  firewall_id = hcloud_firewall.agent[count.index].id
  server_ids  = hcloud_server.agent[*].id
}
