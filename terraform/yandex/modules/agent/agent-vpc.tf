# VPC Network
resource "yandex_vpc_network" "agent" {
  count = local.create ? 1 : 0

  name        = local.resource_name
  description = local.resource_description
  folder_id   = local.folder_id
  labels      = local.default_labels
}

# VPC Subnet
resource "yandex_vpc_subnet" "agent" {
  for_each = { for idx, az in local.az_list : idx => az }

  name           = each.value
  description    = "${local.resource_name}-${each.value}"
  network_id     = yandex_vpc_network.agent[0].id
  v4_cidr_blocks = [cidrsubnet(var.cidr_block, local.subnet_newbits, each.key)]
  zone           = each.value
  folder_id      = local.folder_id
  labels         = local.default_labels
}

# Security group
resource "yandex_vpc_security_group" "agent" {
  count = local.create ? 1 : 0

  name        = local.resource_name
  description = local.resource_description
  network_id  = yandex_vpc_network.agent[count.index].id
  folder_id   = local.folder_id
  labels      = local.default_labels
}

# Ingress - Security Group
resource "yandex_vpc_security_group_rule" "security_group" {
  count = local.create ? 1 : 0

  direction         = "ingress"
  description       = "All - Security Group"
  predefined_target = "self_security_group"
  protocol          = "ANY"

  security_group_binding = yandex_vpc_security_group.agent[count.index].id
}

# Ingress - SSH Health check
resource "yandex_vpc_security_group_rule" "ssh_health_check" {
  count = local.create ? 1 : 0

  direction         = "ingress"
  description       = "SSH - Heath check"
  predefined_target = "loadbalancer_healthchecks"
  protocol          = "TCP"
  port              = 22

  security_group_binding = yandex_vpc_security_group.agent[count.index].id
}

# Ingress - TCP
resource "yandex_vpc_security_group_rule" "tcp" {
  count = local.create && local.open_tcp_ports != null ? 1 : 0

  direction      = "ingress"
  description    = "TCP - Any"
  from_port      = element(split("-", local.open_tcp_ports), 0)
  to_port        = element(split("-", local.open_tcp_ports), 1)
  protocol       = "TCP"
  v4_cidr_blocks = ["0.0.0.0/0"]
  v6_cidr_blocks = var.enable_ipv6 ? ["::/0"] : []
  labels         = local.default_labels

  security_group_binding = yandex_vpc_security_group.agent[count.index].id
}

# Ingress - UDP
resource "yandex_vpc_security_group_rule" "udp" {
  count = local.create && local.open_udp_ports != null ? 1 : 0

  direction      = "ingress"
  description    = "UDP - Any"
  from_port      = element(split("-", local.open_udp_ports), 0)
  to_port        = element(split("-", local.open_udp_ports), 1)
  protocol       = "UDP"
  v4_cidr_blocks = ["0.0.0.0/0"]
  v6_cidr_blocks = var.enable_ipv6 ? ["::/0"] : []
  labels         = local.default_labels

  security_group_binding = yandex_vpc_security_group.agent[count.index].id
}

# Ingress - SSH
resource "yandex_vpc_security_group_rule" "ssh" {
  for_each = toset(local.allow_ssh)

  direction      = "ingress"
  description    = "SSH - ${each.key}"
  port           = 22
  protocol       = "TCP"
  v4_cidr_blocks = [each.key]
  v6_cidr_blocks = var.enable_ipv6 ? [each.key] : []
  labels         = local.default_labels

  security_group_binding = yandex_vpc_security_group.agent[0].id
}

# Egress
resource "yandex_vpc_security_group_rule" "egress" {
  count = local.create ? 1 : 0

  direction      = "egress"
  description    = "All - Any"
  protocol       = "ANY"
  v4_cidr_blocks = ["0.0.0.0/0"]
  v6_cidr_blocks = var.enable_ipv6 ? ["::/0"] : []
  labels         = local.default_labels

  security_group_binding = yandex_vpc_security_group.agent[count.index].id
}

# Security group - Default
resource "yandex_vpc_default_security_group" "agent" {
  count = local.create ? 1 : 0

  description = local.resource_description
  network_id  = yandex_vpc_network.agent[count.index].id
  folder_id   = local.folder_id
  labels      = local.default_labels
}
