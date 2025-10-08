# Image
locals {
  os_name_map = {
    ubuntu = "ubuntu-24-04"
  }

  os_name = lookup(local.os_name_map, var.os_name, var.os_name)
}

data "digitalocean_image" "agent" {
  count = local.create ? 1 : 0

  slug = "${local.os_name}-x64"
}
