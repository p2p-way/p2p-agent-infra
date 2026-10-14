# Locals
locals {
  os_name_ubuntu_24_04 = "ubuntu-2404-lts"
  os_name_ubuntu_26_04 = "ubuntu-2604-lts"

  os_name_map = {
    "ubuntu-24.04" = local.os_name_ubuntu_24_04
    "ubuntu-26.04" = local.os_name_ubuntu_26_04
    ubuntu         = local.os_name_ubuntu_24_04
  }

  os_name = lookup(local.os_name_map, var.os_name, var.os_name)
}

# Image
data "yandex_compute_image" "agent" {
  count = local.create ? 1 : 0

  family = local.os_name
}
