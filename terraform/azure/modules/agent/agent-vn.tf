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

  # Open TCP
  dynamic "security_rule" {
    for_each = local.agent_open_tcp_ports != null ? [1] : []

    content {
      name                       = "Open-TCP-Any"
      description                = "Open TCP - Any"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_ranges    = [for ports in split(",", local.agent_open_tcp_ports) : trimspace(ports)]
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  }

  # Open UDP
  dynamic "security_rule" {
    for_each = local.agent_open_udp_ports != null ? [1] : []

    content {
      name                       = "Open-UDP-Any"
      description                = "Open UDP - Any"
      priority                   = 110
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Udp"
      source_port_range          = "*"
      destination_port_ranges    = [for ports in split(",", local.agent_open_udp_ports) : trimspace(ports)]
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
      priority                   = 200 + security_rule.key
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
