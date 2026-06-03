# Image
locals {
  os_name_map = {
    "ubuntu-24.04" = "Linux Ubuntu 24.04 LTS 64-bit"
    "ubuntu-26.04" = "Linux Ubuntu 26.04 LTS 64-bit"
    ubuntu         = "Linux Ubuntu 24.04 LTS 64-bit"
  }

  os_name = lookup(local.os_name_map, var.os_name, var.os_name)
}
