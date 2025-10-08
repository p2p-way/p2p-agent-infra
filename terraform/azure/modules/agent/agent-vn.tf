# Virtual Network
resource "azurerm_virtual_network" "agent" {
  count = local.create ? 1 : 0

  name                = local.resource_name
  resource_group_name = azurerm_resource_group.agent[count.index].name
  location            = local.region
  address_space       = var.address_space

  subnet {
    name             = local.resource_name
    address_prefixes = var.address_prefixes
  }

  tags = var.default_tags
}

# Network security group
resource "azurerm_network_security_group" "agent" {
  count = local.create ? 1 : 0

  name                = local.resource_name
  location            = local.region
  resource_group_name = azurerm_resource_group.agent[count.index].name

  # Archivist TCP
  dynamic "security_rule" {
    for_each = local.agent_p2p_archivist_tcp_ports != null ? [1] : []

    content {
      name                       = "Archivist-TCP-Any"
      description                = "Archivist TCP - Any"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_ranges    = [for ports in split(",", local.agent_p2p_archivist_tcp_ports) : trimspace(ports)]
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  }

  # Archivist UDP
  dynamic "security_rule" {
    for_each = local.agent_p2p_archivist_udp_ports != null ? [1] : []

    content {
      name                       = "Archivist-UDP-Any"
      description                = "Archivist UDP - Any"
      priority                   = 110
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Udp"
      source_port_range          = "*"
      destination_port_ranges    = [for ports in split(",", local.agent_p2p_archivist_udp_ports) : trimspace(ports)]
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  }

  # IPFS TCP
  dynamic "security_rule" {
    for_each = local.agent_p2p_ipfs_tcp_ports != null ? [1] : []

    content {
      name                       = "IPFS-TCP-Any"
      description                = "IPFS TCP - Any"
      priority                   = 200
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_ranges    = [for ports in split(",", local.agent_p2p_ipfs_tcp_ports) : trimspace(ports)]
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  }

  # IPFS UDP
  dynamic "security_rule" {
    for_each = local.agent_p2p_ipfs_udp_ports != null ? [1] : []

    content {
      name                       = "IPFS-UDP-Any"
      description                = "IPFS UDP - Any"
      priority                   = 210
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Udp"
      source_port_range          = "*"
      destination_port_ranges    = [for ports in split(",", local.agent_p2p_ipfs_udp_ports) : trimspace(ports)]
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  }

  # Radicle TCP
  dynamic "security_rule" {
    for_each = local.agent_p2p_radicle_tcp_ports != null ? [1] : []

    content {
      name                       = "Radicle-TCP-Any"
      description                = "Radicle TCP - Any"
      priority                   = 300
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_ranges    = [for ports in split(",", local.agent_p2p_radicle_tcp_ports) : trimspace(ports)]
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  }

  # Radicle UDP
  dynamic "security_rule" {
    for_each = local.agent_p2p_radicle_udp_ports != null ? [1] : []

    content {
      name                       = "Radicle-UDP-Any"
      description                = "Radicle UDP - Any"
      priority                   = 310
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Udp"
      source_port_range          = "*"
      destination_port_ranges    = [for ports in split(",", local.agent_p2p_radicle_udp_ports) : trimspace(ports)]
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  }

  # TON Storage TCP
  dynamic "security_rule" {
    for_each = local.agent_p2p_ton_tcp_ports != null ? [1] : []

    content {
      name                       = "TON-Storage-TCP-Any"
      description                = "TON Storage TCP - Any"
      priority                   = 400
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_ranges    = [for ports in split(",", local.agent_p2p_ton_tcp_ports) : trimspace(ports)]
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  }

  # TON Storage UDP
  dynamic "security_rule" {
    for_each = local.agent_p2p_ton_udp_ports != null ? [1] : []

    content {
      name                       = "TON-Storage-UDP-Any"
      description                = "TON Storage UDP - Any"
      priority                   = 410
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Udp"
      source_port_range          = "*"
      destination_port_ranges    = [for ports in split(",", local.agent_p2p_ton_udp_ports) : trimspace(ports)]
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  }

  # Torrent TCP
  dynamic "security_rule" {
    for_each = local.agent_p2p_torrent_tcp_ports != null ? [1] : []

    content {
      name                       = "Torrent-TCP-Any"
      description                = "Torrent TCP - Any"
      priority                   = 500
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_ranges    = [for ports in split(",", local.agent_p2p_torrent_tcp_ports) : trimspace(ports)]
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  }

  # Torrent UDP
  dynamic "security_rule" {
    for_each = local.agent_p2p_torrent_udp_ports != null ? [1] : []

    content {
      name                       = "Torrent-UDP-Any"
      description                = "Torrent UDP - Any"
      priority                   = 510
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Udp"
      source_port_range          = "*"
      destination_port_ranges    = [for ports in split(",", local.agent_p2p_torrent_udp_ports) : trimspace(ports)]
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  }

  # Custom TCP
  dynamic "security_rule" {
    for_each = local.agent_custom_tcp_ports != null ? [1] : []

    content {
      name                       = "Custom-TCP-Any"
      description                = "Custom TCP - Any"
      priority                   = 600
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_ranges    = [for ports in split(",", local.agent_custom_tcp_ports) : trimspace(ports)]
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  }

  # Custom UDP
  dynamic "security_rule" {
    for_each = local.agent_custom_udp_ports != null ? [1] : []

    content {
      name                       = "Custom-UDP-Any"
      description                = "Custom UDP - Any"
      priority                   = 610
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Udp"
      source_port_range          = "*"
      destination_port_ranges    = [for ports in split(",", local.agent_custom_udp_ports) : trimspace(ports)]
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  }

  # SSH
  dynamic "security_rule" {
    for_each = var.allow_ssh

    content {
      name                       = "SSH-${replace(security_rule.value, "///", "-")}"
      description                = "SSH - ${security_rule.value}"
      priority                   = 700 + "${security_rule.key * 10}"
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = security_rule.value
      destination_address_prefix = "*"
    }
  }

  tags = var.default_tags
}
