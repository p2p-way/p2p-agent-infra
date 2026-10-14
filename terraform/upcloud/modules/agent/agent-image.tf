# Locals
locals {
  os_name_ubuntu_24_04 = "Ubuntu Server 24.04 LTS (Noble Numbat)"
  os_name_ubuntu_26_04 = "Ubuntu Server 26.04 LTS (Resolute Raccoon)"

  os_name_map = {
    "ubuntu-24.04" = local.os_name_ubuntu_24_04
    "ubuntu-26.04" = local.os_name_ubuntu_26_04
    ubuntu         = local.os_name_ubuntu_24_04
  }

  os_name = lookup(local.os_name_map, var.os_name, var.os_name)
}
