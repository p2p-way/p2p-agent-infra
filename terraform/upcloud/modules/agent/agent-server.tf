# Server group
resource "upcloud_server_group" "agent" {
  count = local.create ? var.desired_capacity : 0

  title                = local.resource_name
  anti_affinity_policy = "yes"
  track_members        = false
  labels               = var.default_labels
}

# Server
resource "upcloud_server" "agent" {
  count = local.create ? var.desired_capacity : 0

  # Location
  zone = local.region

  # Plan
  plan = var.plan

  # Storage / Operating system
  template {
    address = "virtio"
    title   = local.resource_name
    storage = local.os_name
    size    = var.storage_size
  }

  # Network
  network_interface {
    index             = 1
    type              = "public"
    ip_address_family = "IPv4"
  }

  dynamic "network_interface" {
    for_each = var.enable_ipv6 ? [1] : []

    content {
      index             = 2
      type              = "public"
      ip_address_family = "IPv6"
    }
  }

  # Optionals
  metadata     = true
  server_group = upcloud_server_group.agent[count.index].id

  # Login Method
  login {
    user = "root"
    keys = var.keys
  }

  # Initialization script
  user_data = data.cloudinit_config.agent[0].rendered

  # Server configuration
  hostname = "${local.resource_name}-${count.index + 1}"
  title    = "${local.resource_name}-${count.index + 1}"

  labels = var.default_labels

  # Other
  firewall = true
}
