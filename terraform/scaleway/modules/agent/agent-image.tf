# Image
locals {
  os_name_map = {
    "ubuntu-26.04" = "ubuntu_resolute"
    "ubuntu-24.04" = "ubuntu_noble"
    ubuntu         = "ubuntu_noble"
  }

  os_name = lookup(local.os_name_map, var.os_name, var.os_name)
}
