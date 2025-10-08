# Firewall
resource "hcloud_firewall" "agent" {
  count = local.create ? 1 : 0

  name = local.resource_name

  # Archivist TCP
  dynamic "rule" {
    for_each = local.agent_p2p_archivist_tcp_ports != null ? [1] : []

    content {
      direction   = "in"
      protocol    = "tcp"
      port        = local.agent_p2p_archivist_tcp_ports
      source_ips  = var.enable_ipv6 ? ["0.0.0.0/0", "::/0"] : ["0.0.0.0/0"]
      description = "Archivist TCP - Any"
    }
  }

  # Archivist UDP
  dynamic "rule" {
    for_each = local.agent_p2p_archivist_udp_ports != null ? [1] : []

    content {
      direction   = "in"
      protocol    = "udp"
      port        = local.agent_p2p_archivist_udp_ports
      source_ips  = var.enable_ipv6 ? ["0.0.0.0/0", "::/0"] : ["0.0.0.0/0"]
      description = "Archivist UDP - Any"
    }
  }

  # IPFS TCP
  dynamic "rule" {
    for_each = local.agent_p2p_ipfs_tcp_ports != null ? [1] : []

    content {
      direction   = "in"
      protocol    = "tcp"
      port        = local.agent_p2p_ipfs_tcp_ports
      source_ips  = var.enable_ipv6 ? ["0.0.0.0/0", "::/0"] : ["0.0.0.0/0"]
      description = "IPFS TCP - Any"
    }
  }

  # IPFS UDP
  dynamic "rule" {
    for_each = local.agent_p2p_ipfs_udp_ports != null ? [1] : []

    content {
      direction   = "in"
      protocol    = "udp"
      port        = local.agent_p2p_ipfs_udp_ports
      source_ips  = var.enable_ipv6 ? ["0.0.0.0/0", "::/0"] : ["0.0.0.0/0"]
      description = "IPFS UDP - Any"
    }
  }

  # Radicle TCP
  dynamic "rule" {
    for_each = local.agent_p2p_radicle_tcp_ports != null ? [1] : []

    content {
      direction   = "in"
      protocol    = "tcp"
      port        = local.agent_p2p_radicle_tcp_ports
      source_ips  = var.enable_ipv6 ? ["0.0.0.0/0", "::/0"] : ["0.0.0.0/0"]
      description = "Radicle TCP - Any"
    }
  }

  # Radicle UDP
  dynamic "rule" {
    for_each = local.agent_p2p_radicle_udp_ports != null ? [1] : []

    content {
      direction   = "in"
      protocol    = "udp"
      port        = local.agent_p2p_radicle_udp_ports
      source_ips  = var.enable_ipv6 ? ["0.0.0.0/0", "::/0"] : ["0.0.0.0/0"]
      description = "Radicle UDP - Any"
    }
  }

  # TON Storage TCP
  dynamic "rule" {
    for_each = local.agent_p2p_ton_tcp_ports != null ? [1] : []

    content {
      direction   = "in"
      protocol    = "tcp"
      port        = local.agent_p2p_ton_tcp_ports
      source_ips  = var.enable_ipv6 ? ["0.0.0.0/0", "::/0"] : ["0.0.0.0/0"]
      description = "TON Storage TCP - Any"
    }
  }

  # TON Storage UDP
  dynamic "rule" {
    for_each = local.agent_p2p_ton_udp_ports != null ? [1] : []

    content {
      direction   = "in"
      protocol    = "udp"
      port        = local.agent_p2p_ton_udp_ports
      source_ips  = var.enable_ipv6 ? ["0.0.0.0/0", "::/0"] : ["0.0.0.0/0"]
      description = "TON Storage UDP - Any"
    }
  }

  # Torrent TCP
  dynamic "rule" {
    for_each = local.agent_p2p_torrent_tcp_ports != null ? [1] : []

    content {
      direction   = "in"
      protocol    = "tcp"
      port        = local.agent_p2p_torrent_tcp_ports
      source_ips  = var.enable_ipv6 ? ["0.0.0.0/0", "::/0"] : ["0.0.0.0/0"]
      description = "Torrent TCP - Any"
    }
  }

  # Torrent UDP
  dynamic "rule" {
    for_each = local.agent_p2p_torrent_udp_ports != null ? [1] : []

    content {
      direction   = "in"
      protocol    = "udp"
      port        = local.agent_p2p_torrent_udp_ports
      source_ips  = var.enable_ipv6 ? ["0.0.0.0/0", "::/0"] : ["0.0.0.0/0"]
      description = "Torrent UDP - Any"
    }
  }

  # Custom TCP
  dynamic "rule" {
    for_each = local.agent_custom_tcp_ports != null ? [1] : []

    content {
      direction   = "in"
      protocol    = "tcp"
      port        = local.agent_custom_tcp_ports
      source_ips  = var.enable_ipv6 ? ["0.0.0.0/0", "::/0"] : ["0.0.0.0/0"]
      description = "Custom TCP - Any"
    }
  }

  # Custom UDP
  dynamic "rule" {
    for_each = local.agent_custom_udp_ports != null ? [1] : []

    content {
      direction   = "in"
      protocol    = "udp"
      port        = local.agent_custom_udp_ports
      source_ips  = var.enable_ipv6 ? ["0.0.0.0/0", "::/0"] : ["0.0.0.0/0"]
      description = "Custom UDP - Any"
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
