# VPC
resource "aws_vpc" "agent" {
  count = local.create ? 1 : 0

  cidr_block = var.cidr_block

  tags = {
    Name = local.resource_name
  }

  region = local.region
}

# Internet Gateway
resource "aws_internet_gateway" "agent" {
  count = local.create ? 1 : 0

  vpc_id = aws_vpc.agent[count.index].id

  tags = {
    Name = local.resource_name
  }

  region = local.region
}

# AZ
data "aws_availability_zones" "agent" {
  count = local.create ? 1 : 0

  state = "available"

  region = local.region
}

# Subnets
resource "aws_subnet" "agent" {
  for_each = { for idx, az in local.az_list : idx => az }

  vpc_id            = aws_vpc.agent[0].id
  cidr_block        = cidrsubnet(var.cidr_block, local.subnet_newbits, each.key)
  availability_zone = each.value

  tags = {
    Name = "${local.agent_name}-${each.value}"
  }

  region = local.region
}

# Route table
resource "aws_route_table" "agent" {
  count = local.create ? 1 : 0

  vpc_id = aws_vpc.agent[count.index].id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.agent[count.index].id
  }

  tags = {
    Name = local.resource_name
  }

  region = local.region
}

# Route table association
resource "aws_route_table_association" "agent" {
  for_each = { for idx, subnet in aws_subnet.agent : idx => subnet.id }

  route_table_id = aws_route_table.agent[0].id
  subnet_id      = each.value

  region = local.region
}

# Route table - Default
resource "aws_default_route_table" "agent" {
  count = local.create ? 1 : 0

  default_route_table_id = aws_vpc.agent[count.index].default_route_table_id
  route                  = []

  tags = {
    Name = "${local.resource_name} - default"
  }

  region = local.region
}

# Security group
resource "aws_security_group" "agent" {
  count = local.create ? 1 : 0

  name        = local.resource_name
  description = "${local.resource_name} access"
  vpc_id      = aws_vpc.agent[count.index].id

  tags = {
    Name = local.resource_name
  }

  lifecycle {
    create_before_destroy = true
  }

  region = local.region
}

# Ingress - Security Group
resource "aws_vpc_security_group_ingress_rule" "security_group" {
  count = local.create ? 1 : 0

  description                  = "All - Security Group"
  ip_protocol                  = -1
  referenced_security_group_id = aws_security_group.agent[count.index].id

  security_group_id = aws_security_group.agent[count.index].id

  tags = {
    Name = "All - Security Group"
  }

  region = local.region
}

# Ingress - Archivist TCP
resource "aws_vpc_security_group_ingress_rule" "archivist_tcp" {
  count = local.create && local.agent_p2p_archivist_tcp_ports != null ? 1 : 0

  description = "Archivist TCP - Any"
  from_port   = element(split("-", local.agent_p2p_archivist_tcp_ports), 0)
  to_port     = element(split("-", local.agent_p2p_archivist_tcp_ports), 1)
  ip_protocol = "tcp"
  cidr_ipv4   = "0.0.0.0/0"

  security_group_id = aws_security_group.agent[count.index].id

  tags = {
    Name = "Archivist TCP - Any"
  }

  region = local.region
}

# Ingress - Archivist UDP
resource "aws_vpc_security_group_ingress_rule" "archivist_udp" {
  count = local.create && local.agent_p2p_archivist_udp_ports != null ? 1 : 0

  description = "Archivist UDP - Any"
  from_port   = element(split("-", local.agent_p2p_archivist_udp_ports), 0)
  to_port     = element(split("-", local.agent_p2p_archivist_udp_ports), 1)
  ip_protocol = "udp"
  cidr_ipv4   = "0.0.0.0/0"

  security_group_id = aws_security_group.agent[count.index].id

  tags = {
    Name = "Archivist UDP - Any"
  }

  region = local.region
}

# Ingress - IPFS TCP
resource "aws_vpc_security_group_ingress_rule" "ipfs_tcp" {
  count = local.create && local.agent_p2p_ipfs_tcp_ports != null ? 1 : 0

  description = "IPFS TCP - Any"
  from_port   = element(split("-", local.agent_p2p_ipfs_tcp_ports), 0)
  to_port     = element(split("-", local.agent_p2p_ipfs_tcp_ports), 1)
  ip_protocol = "tcp"
  cidr_ipv4   = "0.0.0.0/0"

  security_group_id = aws_security_group.agent[count.index].id

  tags = {
    Name = "IPFS TCP - Any"
  }

  region = local.region
}

# Ingress - IPFS UDP
resource "aws_vpc_security_group_ingress_rule" "ipfs_udp" {
  count = local.create && local.agent_p2p_ipfs_udp_ports != null ? 1 : 0

  description = "IPFS UDP - Any"
  from_port   = element(split("-", local.agent_p2p_ipfs_udp_ports), 0)
  to_port     = element(split("-", local.agent_p2p_ipfs_udp_ports), 1)
  ip_protocol = "udp"
  cidr_ipv4   = "0.0.0.0/0"

  security_group_id = aws_security_group.agent[count.index].id

  tags = {
    Name = "IPFS UDP - Any"
  }

  region = local.region
}

# Ingress - Radicle TCP
resource "aws_vpc_security_group_ingress_rule" "radicle_tcp" {
  count = local.create && local.agent_p2p_radicle_tcp_ports != null ? 1 : 0

  description = "Radicle TCP - Any"
  from_port   = element(split("-", local.agent_p2p_radicle_tcp_ports), 0)
  to_port     = element(split("-", local.agent_p2p_radicle_tcp_ports), 1)
  ip_protocol = "tcp"
  cidr_ipv4   = "0.0.0.0/0"

  security_group_id = aws_security_group.agent[count.index].id

  tags = {
    Name = "Radicle TCP - Any"
  }

  region = local.region
}

# Ingress - Radicle UDP
resource "aws_vpc_security_group_ingress_rule" "radicle_udp" {
  count = local.create && local.agent_p2p_radicle_udp_ports != null ? 1 : 0

  description = "Radicle UDP - Any"
  from_port   = element(split("-", local.agent_p2p_radicle_udp_ports), 0)
  to_port     = element(split("-", local.agent_p2p_radicle_udp_ports), 1)
  ip_protocol = "udp"
  cidr_ipv4   = "0.0.0.0/0"

  security_group_id = aws_security_group.agent[count.index].id

  tags = {
    Name = "Radicle UDP - Any"
  }

  region = local.region
}

# Ingress - TON Storage TCP
resource "aws_vpc_security_group_ingress_rule" "ton_tcp" {
  count = local.create && local.agent_p2p_ton_tcp_ports != null ? 1 : 0

  description = "TON Storage TCP - Any"
  from_port   = element(split("-", local.agent_p2p_ton_tcp_ports), 0)
  to_port     = element(split("-", local.agent_p2p_ton_tcp_ports), 1)
  ip_protocol = "tcp"
  cidr_ipv4   = "0.0.0.0/0"

  security_group_id = aws_security_group.agent[count.index].id

  tags = {
    Name = "TON Storage TCP - Any"
  }

  region = local.region
}

# Ingress - TON Storage UDP
resource "aws_vpc_security_group_ingress_rule" "ton_udp" {
  count = local.create && local.agent_p2p_ton_udp_ports != null ? 1 : 0

  description = "TON Storage UDP - Any"
  from_port   = element(split("-", local.agent_p2p_ton_udp_ports), 0)
  to_port     = element(split("-", local.agent_p2p_ton_udp_ports), 1)
  ip_protocol = "udp"
  cidr_ipv4   = "0.0.0.0/0"

  security_group_id = aws_security_group.agent[count.index].id

  tags = {
    Name = "TON Storage UDP - Any"
  }

  region = local.region
}

# Ingress - Torrent TCP
resource "aws_vpc_security_group_ingress_rule" "torrent_tcp" {
  count = local.create && local.agent_p2p_torrent_tcp_ports != null ? 1 : 0

  description = "Torrent TCP - Any"
  from_port   = element(split("-", local.agent_p2p_torrent_tcp_ports), 0)
  to_port     = element(split("-", local.agent_p2p_torrent_tcp_ports), 1)
  ip_protocol = "tcp"
  cidr_ipv4   = "0.0.0.0/0"

  security_group_id = aws_security_group.agent[count.index].id

  tags = {
    Name = "Torrent TCP - Any"
  }

  region = local.region
}

# Ingress - Torrent UDP
resource "aws_vpc_security_group_ingress_rule" "torrent_udp" {
  count = local.create && local.agent_p2p_torrent_udp_ports != null ? 1 : 0

  description = "Torrent UDP - Any"
  from_port   = element(split("-", local.agent_p2p_torrent_udp_ports), 0)
  to_port     = element(split("-", local.agent_p2p_torrent_udp_ports), 1)
  ip_protocol = "udp"
  cidr_ipv4   = "0.0.0.0/0"

  security_group_id = aws_security_group.agent[count.index].id

  tags = {
    Name = "Torrent UDP - Any"
  }

  region = local.region
}

# Ingress - Custom TCP
resource "aws_vpc_security_group_ingress_rule" "custom_tcp" {
  count = local.create && local.agent_custom_tcp_ports != null ? 1 : 0

  description = "Custom TCP - Any"
  from_port   = element(split("-", local.agent_custom_tcp_ports), 0)
  to_port     = element(split("-", local.agent_custom_tcp_ports), 1)
  ip_protocol = "tcp"
  cidr_ipv4   = "0.0.0.0/0"

  security_group_id = aws_security_group.agent[count.index].id

  tags = {
    Name = "Custom TCP - Any"
  }

  region = local.region
}

# Ingress - Custom UDP
resource "aws_vpc_security_group_ingress_rule" "custom_udp" {
  count = local.create && local.agent_custom_udp_ports != null ? 1 : 0

  description = "Custom UDP - Any"
  from_port   = element(split("-", local.agent_custom_udp_ports), 0)
  to_port     = element(split("-", local.agent_custom_udp_ports), 1)
  ip_protocol = "udp"
  cidr_ipv4   = "0.0.0.0/0"

  security_group_id = aws_security_group.agent[count.index].id

  tags = {
    Name = "Custom UDP - Any"
  }

  region = local.region
}

# Ingress - SSH
resource "aws_vpc_security_group_ingress_rule" "ssh" {
  for_each = toset(local.allow_ssh)

  description = "SSH - ${each.key}"
  from_port   = 22
  to_port     = 22
  ip_protocol = "tcp"
  cidr_ipv4   = each.key

  security_group_id = aws_security_group.agent[0].id

  tags = {
    Name = "SSH - ${each.key}"
  }

  region = local.region
}

# Egress
resource "aws_vpc_security_group_egress_rule" "agent" {
  count = local.create ? 1 : 0

  description = "All - Any"
  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"

  security_group_id = aws_security_group.agent[count.index].id

  tags = {
    Name = "All - Any"
  }

  region = local.region
}

# Security group - Default
resource "aws_default_security_group" "agent" {
  count = local.create ? 1 : 0

  vpc_id = aws_vpc.agent[count.index].id

  tags = {
    Name = "${local.resource_name} - default"
  }

  region = local.region
}
