# Locals
locals {
  os_name_map = {
    "ubuntu-24.04" = "Ubuntu Server 24.04 LTS (Noble Numbat)"
    "ubuntu-26.04" = "Ubuntu Server 26.04 LTS (Resolute Raccoon)"
    ubuntu         = "Ubuntu Server 24.04 LTS (Noble Numbat)"
  }

  os_name = lookup(local.os_name_map, var.os_name, var.os_name)
}
