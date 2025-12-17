# Firewall
resource "digitalocean_firewall" "agent" {
  count = local.create ? 1 : 0

  name        = local.resource_name
  tags        = [resource.digitalocean_tag.agent[count.index].id]
  droplet_ids = digitalocean_droplet.agent[*].id

  # Archivist TCP
  dynamic "inbound_rule" {
    for_each = local.agent_p2p_archivist_tcp_ports != null ? [1] : []

    content {
      protocol         = "tcp"
      port_range       = local.agent_p2p_archivist_tcp_ports
      source_addresses = var.enable_ipv6 ? ["0.0.0.0/0", "::/0"] : ["0.0.0.0/0"]
    }
  }

  # Archivist UDP
  dynamic "inbound_rule" {
    for_each = local.agent_p2p_archivist_udp_ports != null ? [1] : []

    content {
      protocol         = "udp"
      port_range       = local.agent_p2p_archivist_udp_ports
      source_addresses = var.enable_ipv6 ? ["0.0.0.0/0", "::/0"] : ["0.0.0.0/0"]
    }
  }

  # IPFS TCP
  dynamic "inbound_rule" {
    for_each = local.agent_p2p_ipfs_tcp_ports != null ? [1] : []

    content {
      protocol         = "tcp"
      port_range       = local.agent_p2p_ipfs_tcp_ports
      source_addresses = var.enable_ipv6 ? ["0.0.0.0/0", "::/0"] : ["0.0.0.0/0"]
    }
  }

  # IPFS UDP
  dynamic "inbound_rule" {
    for_each = local.agent_p2p_ipfs_udp_ports != null ? [1] : []

    content {
      protocol         = "udp"
      port_range       = local.agent_p2p_ipfs_udp_ports
      source_addresses = var.enable_ipv6 ? ["0.0.0.0/0", "::/0"] : ["0.0.0.0/0"]
    }
  }

  # Radicle TCP
  dynamic "inbound_rule" {
    for_each = local.agent_p2p_radicle_tcp_ports != null ? [1] : []

    content {
      protocol         = "tcp"
      port_range       = local.agent_p2p_radicle_tcp_ports
      source_addresses = var.enable_ipv6 ? ["0.0.0.0/0", "::/0"] : ["0.0.0.0/0"]
    }
  }

  # Radicle UDP
  dynamic "inbound_rule" {
    for_each = local.agent_p2p_radicle_udp_ports != null ? [1] : []

    content {
      protocol         = "udp"
      port_range       = local.agent_p2p_radicle_udp_ports
      source_addresses = var.enable_ipv6 ? ["0.0.0.0/0", "::/0"] : ["0.0.0.0/0"]
    }
  }

  # TON Storage TCP
  dynamic "inbound_rule" {
    for_each = local.agent_p2p_ton_tcp_ports != null ? [1] : []

    content {
      protocol         = "tcp"
      port_range       = local.agent_p2p_ton_tcp_ports
      source_addresses = var.enable_ipv6 ? ["0.0.0.0/0", "::/0"] : ["0.0.0.0/0"]
    }
  }

  # TON Storage UDP
  dynamic "inbound_rule" {
    for_each = local.agent_p2p_ton_udp_ports != null ? [1] : []

    content {
      protocol         = "udp"
      port_range       = local.agent_p2p_ton_udp_ports
      source_addresses = var.enable_ipv6 ? ["0.0.0.0/0", "::/0"] : ["0.0.0.0/0"]
    }
  }

  # Torrent TCP
  dynamic "inbound_rule" {
    for_each = local.agent_p2p_torrent_tcp_ports != null ? [1] : []

    content {
      protocol         = "tcp"
      port_range       = local.agent_p2p_torrent_tcp_ports
      source_addresses = var.enable_ipv6 ? ["0.0.0.0/0", "::/0"] : ["0.0.0.0/0"]
    }
  }

  # Torrent UDP
  dynamic "inbound_rule" {
    for_each = local.agent_p2p_torrent_udp_ports != null ? [1] : []

    content {
      protocol         = "udp"
      port_range       = local.agent_p2p_torrent_udp_ports
      source_addresses = var.enable_ipv6 ? ["0.0.0.0/0", "::/0"] : ["0.0.0.0/0"]
    }
  }

  # Custom TCP
  dynamic "inbound_rule" {
    for_each = local.agent_custom_tcp_ports != null ? [1] : []

    content {
      protocol         = "tcp"
      port_range       = local.agent_custom_tcp_ports
      source_addresses = var.enable_ipv6 ? ["0.0.0.0/0", "::/0"] : ["0.0.0.0/0"]
    }
  }

  # Custom UDP
  dynamic "inbound_rule" {
    for_each = local.agent_custom_udp_ports != null ? [1] : []

    content {
      protocol         = "udp"
      port_range       = local.agent_custom_udp_ports
      source_addresses = var.enable_ipv6 ? ["0.0.0.0/0", "::/0"] : ["0.0.0.0/0"]
    }
  }

  # SSH
  dynamic "inbound_rule" {
    for_each = var.allow_ssh

    content {
      protocol         = "tcp"
      port_range       = "22"
      source_addresses = [inbound_rule.value]
    }
  }

  # Outbound
  outbound_rule {
    protocol              = "icmp"
    destination_addresses = var.enable_ipv6 ? ["0.0.0.0/0", "::/0"] : ["0.0.0.0/0"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = var.enable_ipv6 ? ["0.0.0.0/0", "::/0"] : ["0.0.0.0/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = var.enable_ipv6 ? ["0.0.0.0/0", "::/0"] : ["0.0.0.0/0"]
  }
}
