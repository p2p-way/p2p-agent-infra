# Firewall
resource "linode_firewall" "agent" {
  count = local.create ? 1 : 0

  label           = local.resource_name
  inbound_policy  = "DROP"
  outbound_policy = "ACCEPT"

  # Open TCP
  dynamic "inbound" {
    for_each = local.agent_open_tcp_ports != null ? [1] : []

    content {
      label    = "Open-TCP-Any"
      action   = "ACCEPT"
      protocol = "TCP"
      ports    = local.agent_open_tcp_ports
      ipv4     = ["0.0.0.0/0"]
      ipv6     = ["::/0"]
    }
  }

  # Open UDP
  dynamic "inbound" {
    for_each = local.agent_open_udp_ports != null ? [1] : []

    content {
      label    = "Open-UDP-Any"
      action   = "ACCEPT"
      protocol = "UDP"
      ports    = local.agent_open_udp_ports
      ipv4     = ["0.0.0.0/0"]
      ipv6     = ["::/0"]
    }
  }

  # SSH
  dynamic "inbound" {
    for_each = var.allow_ssh

    content {
      label    = "SSH-${replace(replace(inbound.value, "/[./:]/", "-"), "/^[-]+/", "")}"
      action   = "ACCEPT"
      protocol = "TCP"
      ports    = 22
      ipv4     = strcontains(inbound.value, ":") ? null : [inbound.value]
      ipv6     = strcontains(inbound.value, ":") ? [inbound.value] : null
    }
  }
}
