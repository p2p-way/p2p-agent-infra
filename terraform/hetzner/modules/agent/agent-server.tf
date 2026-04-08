# Placement group
resource "hcloud_placement_group" "agent" {
  count = local.create ? 1 : 0

  name = local.resource_name
  type = "spread"
}

# Server
resource "hcloud_server" "agent" {
  count = local.create ? var.desired_capacity : 0

  # Location
  location = var.location

  # Image
  image = data.hcloud_image.agent[count.index].id

  # Type
  server_type = var.server_type

  # Networking
  public_net {
    ipv4_enabled = true
    ipv6_enabled = var.enable_ipv6
  }

  # SSH keys
  ssh_keys = var.ssh_keys

  # Placement groups
  placement_group_id = hcloud_placement_group.agent[count.index].id

  # Labels
  labels = local.default_labels

  # Cloud config
  user_data = data.cloudinit_config.agent[count.index].rendered

  # Name
  name = "${local.resource_name}-${count.index + 1}"

  # Other
  keep_disk = true
}
