# Image
locals {
  os_name_ubuntu_24_04 = "linode/ubuntu24.04"
  os_name_ubuntu_26_04 = "linode/ubuntu26.04"

  os_name_map = {
    "ubuntu-24.04" = local.os_name_ubuntu_24_04
    "ubuntu-26.04" = local.os_name_ubuntu_26_04
    ubuntu         = local.os_name_ubuntu_24_04
  }

  os_name = lookup(local.os_name_map, var.os_name, var.os_name)
}
