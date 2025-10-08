# Droplet
resource "digitalocean_droplet" "agent" {
  count = local.create ? var.desired_capacity : 0

  # Datacenter
  region = local.region

  # VPC
  vpc_uuid = resource.digitalocean_vpc.agent[0].id

  # OS
  image = data.digitalocean_image.agent[0].slug

  # Size
  size = var.droplet_size

  # Authentication
  ssh_keys = var.ssh_keys

  # Enable IPv6
  ipv6 = var.enable_ipv6

  # Initialization scripts
  user_data = data.cloudinit_config.agent[0].rendered

  # Hostname
  name = "${local.resource_name}-${count.index + 1}"

  # Tags
  tags = [resource.digitalocean_tag.agent[0].id]

  # Other
  resize_disk = false
}
