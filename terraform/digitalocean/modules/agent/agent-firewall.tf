# Firewall
resource "digitalocean_firewall" "agent" {
  count = local.create ? 1 : 0

  name        = local.resource_name
  tags        = [resource.digitalocean_tag.agent[count.index].id]
  droplet_ids = digitalocean_droplet.agent[*].id

  # Open TCP
  dynamic "inbound_rule" {
    for_each = local.agent_open_tcp_ports != null ? [1] : []

    content {
      protocol         = "tcp"
      port_range       = local.agent_open_tcp_ports
      source_addresses = var.enable_ipv6 ? ["0.0.0.0/0", "::/0"] : ["0.0.0.0/0"]
    }
  }

  # Open UDP
  dynamic "inbound_rule" {
    for_each = local.agent_open_udp_ports != null ? [1] : []

    content {
      protocol         = "udp"
      port_range       = local.agent_open_udp_ports
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
