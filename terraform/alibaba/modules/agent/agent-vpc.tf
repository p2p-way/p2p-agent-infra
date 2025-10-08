# VPC
resource "alicloud_vpc" "agent" {
  count = local.create ? 1 : 0

  vpc_name          = local.resource_name
  description       = local.resource_description
  cidr_block        = var.cidr_block
  resource_group_id = alicloud_resource_manager_resource_group.agent[count.index].id

  tags = var.default_tags
}

# IPv4 gateway
resource "alicloud_vpc_ipv4_gateway" "agent" {
  count = local.create ? 1 : 0

  enabled                  = true
  ipv4_gateway_name        = local.resource_name
  ipv4_gateway_description = local.resource_description
  vpc_id                   = alicloud_vpc.agent[count.index].id
  resource_group_id        = alicloud_resource_manager_resource_group.agent[count.index].id

  tags = var.default_tags
}

# Route table - Default route
resource "alicloud_route_entry" "agent" {
  count = local.create ? 1 : 0

  name                  = local.resource_name
  description           = local.resource_description
  route_table_id        = alicloud_vpc.agent[count.index].route_table_id
  destination_cidrblock = "0.0.0.0/0"
  nexthop_type          = "Ipv4Gateway"
  nexthop_id            = alicloud_vpc_ipv4_gateway.agent[count.index].id
}

# AZ
data "alicloud_zones" "agent" {
  count = local.create ? 1 : 0

  available_resource_creation = "VSwitch"
  network_type                = "Vpc"
}

# vSwitch
resource "alicloud_vswitch" "agent" {
  for_each = { for idx, az in local.az_list : idx => az }

  vswitch_name = "${local.agent_name}-${each.value}"
  cidr_block   = cidrsubnet(var.cidr_block, local.subnet_newbits, each.key)
  vpc_id       = alicloud_vpc.agent[0].id
  zone_id      = each.value

  tags = var.default_tags
}

# Security Group - Agent
resource "alicloud_security_group" "agent" {
  count = local.create ? 1 : 0

  security_group_name = local.resource_name
  description         = local.resource_description
  vpc_id              = alicloud_vpc.agent[count.index].id
  resource_group_id   = alicloud_resource_manager_resource_group.agent[count.index].id

  tags = var.default_tags

  lifecycle {
    create_before_destroy = true
  }
}

# Ingress - Archivist TCP
resource "alicloud_security_group_rule" "archivist_tcp" {
  count = local.create && local.agent_p2p_archivist_tcp_ports != null ? 1 : 0

  type        = "ingress"
  description = "Archivist TCP - Any"
  port_range  = "${element(split("-", local.agent_p2p_archivist_tcp_ports), 0)}/${element(split("-", local.agent_p2p_archivist_tcp_ports), 1)}"
  ip_protocol = "tcp"
  cidr_ip     = "0.0.0.0/0"

  security_group_id = alicloud_security_group.agent[count.index].id
}

# Ingress - Archivist UDP
resource "alicloud_security_group_rule" "archivist_udp" {
  count = local.create && local.agent_p2p_archivist_udp_ports != null ? 1 : 0

  type        = "ingress"
  description = "Archivist UDP - Any"
  port_range  = "${element(split("-", local.agent_p2p_archivist_udp_ports), 0)}/${element(split("-", local.agent_p2p_archivist_udp_ports), 1)}"
  ip_protocol = "udp"
  cidr_ip     = "0.0.0.0/0"

  security_group_id = alicloud_security_group.agent[count.index].id
}

# Ingress - IPFS TCP
resource "alicloud_security_group_rule" "ipfs_tcp" {
  count = local.create && local.agent_p2p_ipfs_tcp_ports != null ? 1 : 0

  type        = "ingress"
  description = "IPFS TCP - Any"
  port_range  = "${element(split("-", local.agent_p2p_ipfs_tcp_ports), 0)}/${element(split("-", local.agent_p2p_ipfs_tcp_ports), 1)}"
  ip_protocol = "tcp"
  cidr_ip     = "0.0.0.0/0"

  security_group_id = alicloud_security_group.agent[count.index].id
}

# Ingress - IPFS UDP
resource "alicloud_security_group_rule" "ipfs_udp" {
  count = local.create && local.agent_p2p_ipfs_udp_ports != null ? 1 : 0

  type        = "ingress"
  description = "IPFS UDP - Any"
  port_range  = "${element(split("-", local.agent_p2p_ipfs_udp_ports), 0)}/${element(split("-", local.agent_p2p_ipfs_udp_ports), 1)}"
  ip_protocol = "udp"
  cidr_ip     = "0.0.0.0/0"

  security_group_id = alicloud_security_group.agent[count.index].id
}

# Ingress - Radicle TCP
resource "alicloud_security_group_rule" "radicle_tcp" {
  count = local.create && local.agent_p2p_radicle_tcp_ports != null ? 1 : 0

  type        = "ingress"
  description = "Radicle TCP - Any"
  port_range  = "${element(split("-", local.agent_p2p_radicle_tcp_ports), 0)}/${element(split("-", local.agent_p2p_radicle_tcp_ports), 1)}"
  ip_protocol = "tcp"
  cidr_ip     = "0.0.0.0/0"

  security_group_id = alicloud_security_group.agent[count.index].id
}

# Ingress - Radicle UDP
resource "alicloud_security_group_rule" "radicle_udp" {
  count = local.create && local.agent_p2p_radicle_udp_ports != null ? 1 : 0

  type        = "ingress"
  description = "Radicle UDP - Any"
  port_range  = "${element(split("-", local.agent_p2p_radicle_udp_ports), 0)}/${element(split("-", local.agent_p2p_radicle_udp_ports), 1)}"
  ip_protocol = "udp"
  cidr_ip     = "0.0.0.0/0"

  security_group_id = alicloud_security_group.agent[count.index].id
}

# Ingress - TON Storage TCP
resource "alicloud_security_group_rule" "ton_tcp" {
  count = local.create && local.agent_p2p_ton_tcp_ports != null ? 1 : 0

  type        = "ingress"
  description = "TON Storage TCP - Any"
  port_range  = "${element(split("-", local.agent_p2p_ton_tcp_ports), 0)}/${element(split("-", local.agent_p2p_ton_tcp_ports), 1)}"
  ip_protocol = "tcp"
  cidr_ip     = "0.0.0.0/0"

  security_group_id = alicloud_security_group.agent[count.index].id
}

# Ingress - TON Storage UDP
resource "alicloud_security_group_rule" "ton_udp" {
  count = local.create && local.agent_p2p_ton_udp_ports != null ? 1 : 0

  type        = "ingress"
  description = "TON Storage UDP - Any"
  port_range  = "${element(split("-", local.agent_p2p_ton_udp_ports), 0)}/${element(split("-", local.agent_p2p_ton_udp_ports), 1)}"
  ip_protocol = "udp"
  cidr_ip     = "0.0.0.0/0"

  security_group_id = alicloud_security_group.agent[count.index].id
}

# Ingress - Torrent TCP
resource "alicloud_security_group_rule" "torrent_tcp" {
  count = local.create && local.agent_p2p_torrent_tcp_ports != null ? 1 : 0

  type        = "ingress"
  description = "Torrent TCP - Any"
  port_range  = "${element(split("-", local.agent_p2p_torrent_tcp_ports), 0)}/${element(split("-", local.agent_p2p_torrent_tcp_ports), 1)}"
  ip_protocol = "tcp"
  cidr_ip     = "0.0.0.0/0"

  security_group_id = alicloud_security_group.agent[count.index].id
}

# Ingress - Torrent UDP
resource "alicloud_security_group_rule" "torrent_udp" {
  count = local.create && local.agent_p2p_torrent_udp_ports != null ? 1 : 0

  type        = "ingress"
  description = "Torrent UDP - Any"
  port_range  = "${element(split("-", local.agent_p2p_torrent_udp_ports), 0)}/${element(split("-", local.agent_p2p_torrent_udp_ports), 1)}"
  ip_protocol = "udp"
  cidr_ip     = "0.0.0.0/0"

  security_group_id = alicloud_security_group.agent[count.index].id
}

# Ingress - Custom TCP
resource "alicloud_security_group_rule" "custom_tcp" {
  count = local.create && local.agent_custom_tcp_ports != null ? 1 : 0

  type        = "ingress"
  description = "Custom TCP - Any"
  port_range  = "${element(split("-", local.agent_custom_tcp_ports), 0)}/${element(split("-", local.agent_custom_tcp_ports), 1)}"
  ip_protocol = "tcp"
  cidr_ip     = "0.0.0.0/0"

  security_group_id = alicloud_security_group.agent[count.index].id
}

# Ingress - Custom UDP
resource "alicloud_security_group_rule" "custom_udp" {
  count = local.create && local.agent_custom_udp_ports != null ? 1 : 0

  type        = "ingress"
  description = "Custom UDP - Any"
  port_range  = "${element(split("-", local.agent_custom_udp_ports), 0)}/${element(split("-", local.agent_custom_udp_ports), 1)}"
  ip_protocol = "udp"
  cidr_ip     = "0.0.0.0/0"

  security_group_id = alicloud_security_group.agent[count.index].id
}

# Ingress - SSH
resource "alicloud_security_group_rule" "ssh" {
  for_each = toset(local.allow_ssh)

  type        = "ingress"
  description = "SSH - ${each.key}"
  port_range  = "22/22"
  ip_protocol = "tcp"
  policy      = "accept"
  cidr_ip     = each.key

  security_group_id = alicloud_security_group.agent[0].id
}

# Egress
resource "alicloud_security_group_rule" "egress" {
  count = local.create ? 1 : 0

  type        = "egress"
  description = "All - Any"
  ip_protocol = "all"
  policy      = "accept"
  cidr_ip     = "0.0.0.0/0"

  security_group_id = alicloud_security_group.agent[count.index].id
}
