# Image
locals {
  os_name_map = {
    ubuntu = "linode/ubuntu24.04"
  }

  os_name = lookup(local.os_name_map, var.os_name, var.os_name)
}
