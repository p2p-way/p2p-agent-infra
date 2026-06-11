# Security Group
resource "exoscale_security_group" "agent" {
  count = local.create ? 1 : 0

  name        = local.resource_name
  description = local.resource_description
}

# Ingress - Security Group
resource "exoscale_security_group_rule" "security_group" {
  for_each = local.create ? toset(["TCP", "UDP"]) : []

  description            = "${each.key} - Security Group"
  type                   = "INGRESS"
  protocol               = each.key
  user_security_group_id = exoscale_security_group.agent[0].id
  start_port             = element(split("-", local.open_tcp_ports), 0)
  end_port               = element(split("-", local.open_tcp_ports), 1)
  security_group_id      = exoscale_security_group.agent[0].id
}

# Ingress - TCP
resource "exoscale_security_group_rule" "tcp" {
  for_each = local.open_tcp_ports != null ? toset(local.firewall_protocols) : []

  description       = "TCP - Any"
  type              = "INGRESS"
  protocol          = "TCP"
  cidr              = each.key == "v4" ? "0.0.0.0/0" : "::/0"
  start_port        = element(split("-", local.open_tcp_ports), 0)
  end_port          = element(split("-", local.open_tcp_ports), 1)
  security_group_id = exoscale_security_group.agent[0].id
}

# Ingress - UDP
resource "exoscale_security_group_rule" "udp" {
  for_each = local.open_udp_ports != null ? toset(local.firewall_protocols) : []

  description       = "UDP - Any"
  type              = "INGRESS"
  protocol          = "UDP"
  cidr              = each.key == "v4" ? "0.0.0.0/0" : "::/0"
  start_port        = element(split("-", local.open_tcp_ports), 0)
  end_port          = element(split("-", local.open_tcp_ports), 1)
  security_group_id = exoscale_security_group.agent[0].id
}

# Ingress - SSH
resource "exoscale_security_group_rule" "ssh" {
  for_each = toset(local.allow_ssh)

  description       = "SSH - ${each.key}"
  type              = "INGRESS"
  protocol          = "TCP"
  cidr              = each.key
  start_port        = 22
  end_port          = 22
  security_group_id = exoscale_security_group.agent[0].id
}
