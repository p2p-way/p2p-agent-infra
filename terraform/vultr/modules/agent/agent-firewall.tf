# Firewall Group
resource "vultr_firewall_group" "agent" {
  count = local.create ? 1 : 0

  description = local.resource_name
}

# Firewall Rule - Open TCP
resource "vultr_firewall_rule" "agent_tcp" {
  for_each = local.agent_open_tcp_ports != null ? toset(local.firewall_protocols) : []

  ip_type     = each.key
  protocol    = "tcp"
  port        = local.agent_open_tcp_ports
  subnet      = each.key == "v4" ? "0.0.0.0" : "::"
  subnet_size = 0
  notes       = "Open TCP - Any"

  firewall_group_id = vultr_firewall_group.agent[0].id

  lifecycle {
    ignore_changes = [source]
  }
}

# Firewall Rule - Open UDP
resource "vultr_firewall_rule" "agent_udp" {
  for_each = local.agent_open_udp_ports != null ? toset(local.firewall_protocols) : []

  ip_type     = each.key
  protocol    = "udp"
  port        = local.agent_open_udp_ports
  subnet      = each.key == "v4" ? "0.0.0.0" : "::"
  subnet_size = 0
  notes       = "Open UDP - Any"

  firewall_group_id = vultr_firewall_group.agent[0].id

  lifecycle {
    ignore_changes = [source]
  }
}

# Firewall Rule - SSH
resource "vultr_firewall_rule" "agent_ssh" {
  for_each = toset(local.allow_ssh)

  ip_type     = strcontains(each.key, ":") ? "v6" : "v4"
  protocol    = "tcp"
  port        = 22
  subnet      = element(split("/", each.key), 0)
  subnet_size = element(split("/", each.key), 1)
  source      = null
  notes       = "SSH - ${each.key}"

  firewall_group_id = vultr_firewall_group.agent[0].id

  lifecycle {
    ignore_changes = [source]
  }
}
