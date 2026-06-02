# Placement Group
resource "linode_placement_group" "agent" {
  count = local.create ? 1 : 0

  label                = local.resource_name
  region               = local.region
  placement_group_type = "anti_affinity:local"
}

# Instance
resource "linode_instance" "agent" {
  count = local.create ? var.desired_capacity : 0

  # Region
  region = local.region

  # Choose an OS
  image = local.os_name

  # Linode Plan
  type = var.type

  # Details
  label = "${local.resource_name}-${count.index + 1}"
  tags  = local.tags
  placement_group {
    id = linode_placement_group.agent[0].id
  }

  # Security
  root_pass = null

  # SSH Keys
  authorized_keys = var.authorized_keys

  # Firewall
  firewall_id = linode_firewall.agent[0].id

  # Add User Data
  metadata {
    user_data = data.cloudinit_config.agent[0].rendered
  }

  # swap_size  = 0

  # Alerts
  alerts {
    cpu            = 0
    network_in     = 0
    network_out    = 0
    transfer_quota = 0
    io             = 0
  }
}
