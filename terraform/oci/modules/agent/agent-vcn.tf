# VCN
resource "oci_core_vcn" "agent" {
  count = local.create ? 1 : 0

  compartment_id = local.compartment_id
  cidr_blocks    = var.cidr_blocks
  display_name   = local.resource_name
  freeform_tags  = local.freeform_tags
  is_ipv6enabled = var.enable_ipv6
  dns_label      = substr(replace(local.region, "/(^[a-z]{2}-)([a-z]+)-(\\d+)$/", "$2$3"), -15, -1)
}

# Internet Gateway
resource "oci_core_internet_gateway" "agent" {
  count = local.create ? 1 : 0

  compartment_id = local.compartment_id
  vcn_id         = oci_core_vcn.agent[count.index].id
  display_name   = local.resource_name
  freeform_tags  = local.freeform_tags
  route_table_id = oci_core_vcn.agent[count.index].default_route_table_id
}

# Route Table
resource "oci_core_route_table" "agent" {
  count = local.create ? 1 : 0

  compartment_id = local.compartment_id
  vcn_id         = oci_core_vcn.agent[count.index].id
  display_name   = local.resource_name
  freeform_tags  = local.freeform_tags
  route_rules {
    network_entity_id = oci_core_internet_gateway.agent[count.index].id
    description       = "Default"
    destination       = "0.0.0.0/0"
  }
}

# Subnet
resource "oci_core_subnet" "agent" {
  count = local.create ? 1 : 0

  compartment_id = local.compartment_id
  vcn_id         = oci_core_vcn.agent[count.index].id
  cidr_block     = var.cidr_blocks[0]
  display_name   = local.resource_name
  freeform_tags  = local.freeform_tags
  dns_label      = "subnet"
}

# Subnet - Route Table
resource "oci_core_route_table_attachment" "agent" {
  count = local.create ? 1 : 0

  subnet_id      = oci_core_subnet.agent[count.index].id
  route_table_id = oci_core_route_table.agent[count.index].id
}

# Network Security Group
resource "oci_core_network_security_group" "agent" {
  count = local.create ? 1 : 0

  compartment_id = local.compartment_id
  vcn_id         = oci_core_vcn.agent[count.index].id
  display_name   = local.resource_name
  freeform_tags  = local.freeform_tags
}

# Ingress - Network Security Group
resource "oci_core_network_security_group_security_rule" "nsg" {
  count = local.create ? 1 : 0

  description = "All - Security Group"
  direction   = "INGRESS"
  protocol    = "all"
  source      = oci_core_network_security_group.agent[0].id
  source_type = "NETWORK_SECURITY_GROUP"
  stateless   = false

  network_security_group_id = oci_core_network_security_group.agent[0].id
}

# Ingress - TCP
resource "oci_core_network_security_group_security_rule" "ingress_tcp" {
  count = local.create && local.open_tcp_ports != "" ? 1 : 0

  description = "TCP - Any"
  direction   = "INGRESS"
  protocol    = "6"
  source      = "0.0.0.0/0"
  stateless   = false

  tcp_options {
    destination_port_range {
      min = element(split("-", local.open_tcp_ports), 0)
      max = element(split("-", local.open_tcp_ports), 1)
    }
  }

  network_security_group_id = oci_core_network_security_group.agent[count.index].id
}

# Ingress - UDP
resource "oci_core_network_security_group_security_rule" "ingress_udp" {
  count = local.create && local.open_udp_ports != "" ? 1 : 0

  description = "UDP - Any"
  direction   = "INGRESS"
  protocol    = "17"
  source      = "0.0.0.0/0"
  stateless   = false

  udp_options {
    destination_port_range {
      min = element(split("-", local.open_udp_ports), 0)
      max = element(split("-", local.open_udp_ports), 1)
    }
  }

  network_security_group_id = oci_core_network_security_group.agent[count.index].id
}

# Ingress - SSH
resource "oci_core_network_security_group_security_rule" "ingress_ssh" {
  for_each = toset(local.allow_ssh)

  description = "SSH - ${each.key}"
  direction   = "INGRESS"
  protocol    = "6"
  source      = each.key
  stateless   = false

  tcp_options {
    destination_port_range {
      min = 22
      max = 22
    }
  }

  network_security_group_id = oci_core_network_security_group.agent[0].id
}

# Egress
resource "oci_core_network_security_group_security_rule" "egress" {
  count = local.create ? 1 : 0

  description = "All - Any"
  direction   = "EGRESS"
  protocol    = "all"
  destination = "0.0.0.0/0"
  stateless   = false

  network_security_group_id = oci_core_network_security_group.agent[0].id
}
