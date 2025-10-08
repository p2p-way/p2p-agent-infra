# Firewall
resource "linode_firewall" "agent" {
  count = local.create ? 1 : 0

  label           = local.resource_name
  inbound_policy  = "DROP"
  outbound_policy = "ACCEPT"

  # Archivist TCP
  dynamic "inbound" {
    for_each = local.agent_p2p_archivist_tcp_ports != null ? [1] : []

    content {
      label    = "Archivist-TCP-Any"
      action   = "ACCEPT"
      protocol = "TCP"
      ports    = local.agent_p2p_archivist_tcp_ports
      ipv4     = ["0.0.0.0/0"]
      ipv6     = ["::/0"]
    }
  }

  # Archivist UDP
  dynamic "inbound" {
    for_each = local.agent_p2p_archivist_udp_ports != null ? [1] : []

    content {
      label    = "Archivist-UDP-Any"
      action   = "ACCEPT"
      protocol = "UDP"
      ports    = local.agent_p2p_archivist_udp_ports
      ipv4     = ["0.0.0.0/0"]
      ipv6     = ["::/0"]
    }
  }

  # IPFS TCP
  dynamic "inbound" {
    for_each = local.agent_p2p_ipfs_tcp_ports != null ? [1] : []

    content {
      label    = "IPFS-TCP-Any"
      action   = "ACCEPT"
      protocol = "TCP"
      ports    = local.agent_p2p_ipfs_tcp_ports
      ipv4     = ["0.0.0.0/0"]
      ipv6     = ["::/0"]
    }
  }

  # IPFS UDP
  dynamic "inbound" {
    for_each = local.agent_p2p_ipfs_udp_ports != null ? [1] : []

    content {
      label    = "IPFS-UDP-Any"
      action   = "ACCEPT"
      protocol = "UDP"
      ports    = local.agent_p2p_ipfs_udp_ports
      ipv4     = ["0.0.0.0/0"]
      ipv6     = ["::/0"]
    }
  }

  # Radicle TCP
  dynamic "inbound" {
    for_each = local.agent_p2p_radicle_tcp_ports != null ? [1] : []

    content {
      label    = "Radicle-TCP-Any"
      action   = "ACCEPT"
      protocol = "TCP"
      ports    = local.agent_p2p_radicle_tcp_ports
      ipv4     = ["0.0.0.0/0"]
      ipv6     = ["::/0"]
    }
  }

  # Radicle UDP
  dynamic "inbound" {
    for_each = local.agent_p2p_radicle_udp_ports != null ? [1] : []

    content {
      label    = "Radicle-UDP-Any"
      action   = "ACCEPT"
      protocol = "UDP"
      ports    = local.agent_p2p_radicle_udp_ports
      ipv4     = ["0.0.0.0/0"]
      ipv6     = ["::/0"]
    }
  }

  # TON Storage TCP
  dynamic "inbound" {
    for_each = local.agent_p2p_ton_tcp_ports != null ? [1] : []

    content {
      label    = "TON-Storage-TCP-Any"
      action   = "ACCEPT"
      protocol = "TCP"
      ports    = local.agent_p2p_ton_tcp_ports
      ipv4     = ["0.0.0.0/0"]
      ipv6     = ["::/0"]
    }
  }

  # TON Storage UDP
  dynamic "inbound" {
    for_each = local.agent_p2p_ton_udp_ports != null ? [1] : []

    content {
      label    = "TON-Storage-UDP-Any"
      action   = "ACCEPT"
      protocol = "UDP"
      ports    = local.agent_p2p_ton_udp_ports
      ipv4     = ["0.0.0.0/0"]
      ipv6     = ["::/0"]
    }
  }

  # Torrent TCP
  dynamic "inbound" {
    for_each = local.agent_p2p_torrent_tcp_ports != null ? [1] : []

    content {
      label    = "Torrent-TCP-Any"
      action   = "ACCEPT"
      protocol = "TCP"
      ports    = local.agent_p2p_torrent_tcp_ports
      ipv4     = ["0.0.0.0/0"]
      ipv6     = ["::/0"]
    }
  }

  # Torrent UDP
  dynamic "inbound" {
    for_each = local.agent_p2p_torrent_udp_ports != null ? [1] : []

    content {
      label    = "Torrent-UDP-Any"
      action   = "ACCEPT"
      protocol = "UDP"
      ports    = local.agent_p2p_torrent_udp_ports
      ipv4     = ["0.0.0.0/0"]
      ipv6     = ["::/0"]
    }
  }

  # Custom TCP
  dynamic "inbound" {
    for_each = local.agent_custom_tcp_ports != null ? [1] : []

    content {
      label    = "Custom-TCP-Any"
      action   = "ACCEPT"
      protocol = "TCP"
      ports    = local.agent_custom_tcp_ports
      ipv4     = ["0.0.0.0/0"]
      ipv6     = ["::/0"]
    }
  }

  # Custom UDP
  dynamic "inbound" {
    for_each = local.agent_custom_udp_ports != null ? [1] : []

    content {
      label    = "Custom-UDP-Any"
      action   = "ACCEPT"
      protocol = "UDP"
      ports    = local.agent_custom_udp_ports
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
