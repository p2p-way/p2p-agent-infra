# Image
locals {
  os_name_map = {
    "ubuntu-24.04" = "linode/ubuntu24.04"
    "ubuntu-26.04" = "linode/ubuntu26.04"
    ubuntu         = "linode/ubuntu24.04"
  }

  os_name = lookup(local.os_name_map, var.os_name, var.os_name)
}
