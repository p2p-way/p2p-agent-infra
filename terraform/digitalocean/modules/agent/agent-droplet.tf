# Droplet
resource "digitalocean_droplet" "agent" {
  count = local.create ? var.desired_capacity : 0

  # Datacenter
  region = local.region

  # VPC
  vpc_uuid = resource.digitalocean_vpc.agent[count.index].id

  # OS
  image = data.digitalocean_image.agent[count.index].slug

  # Size
  size = var.droplet_size

  # Authentication
  ssh_keys = var.ssh_keys

  # Enable IPv6
  ipv6 = var.enable_ipv6

  # Initialization scripts
  user_data = data.cloudinit_config.agent[count.index].rendered

  # Hostname
  name = "${local.resource_name}-${count.index + 1}"

  # Tags
  tags = [resource.digitalocean_tag.agent[count.index].id]

  # Other
  resize_disk = false
}
