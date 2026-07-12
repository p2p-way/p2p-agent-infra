# Locals
locals {
  os_name_map = {
    "ubuntu-24.04" = "ubuntu-2404-lts"
    "ubuntu-26.04" = "ubuntu-2604-lts"
    ubuntu         = "ubuntu-2404-lts"
  }

  os_name = lookup(local.os_name_map, var.os_name, var.os_name)
}

# Image
data "yandex_compute_image" "agent" {
  count = local.create ? 1 : 0

  family = local.os_name
}
