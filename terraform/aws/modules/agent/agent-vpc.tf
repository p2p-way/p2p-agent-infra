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

# Ingress - Open TCP
resource "aws_vpc_security_group_ingress_rule" "agent_tcp" {
  count = local.create && local.agent_open_tcp_ports != null ? 1 : 0

  description = "Open TCP - Any"
  from_port   = element(split("-", local.agent_open_tcp_ports), 0)
  to_port     = element(split("-", local.agent_open_tcp_ports), 1)
  ip_protocol = "tcp"
  cidr_ipv4   = "0.0.0.0/0"

  security_group_id = aws_security_group.agent[count.index].id

  tags = {
    Name = "Open TCP - Any"
  }

  region = local.region
}

# Ingress - Open UDP
resource "aws_vpc_security_group_ingress_rule" "agent_udp" {
  count = local.create && local.agent_open_udp_ports != null ? 1 : 0

  description = "Open UDP - Any"
  from_port   = element(split("-", local.agent_open_udp_ports), 0)
  to_port     = element(split("-", local.agent_open_udp_ports), 1)
  ip_protocol = "udp"
  cidr_ipv4   = "0.0.0.0/0"

  security_group_id = aws_security_group.agent[count.index].id

  tags = {
    Name = "Open UDP - Any"
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
