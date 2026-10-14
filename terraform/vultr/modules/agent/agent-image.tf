# Locals
locals {
  os_name_ubuntu_24_04 = "Ubuntu 24.04 LTS x64"
  os_name_ubuntu_26_04 = "Ubuntu 26.04 LTS x64"

  os_name_map = {
    "ubuntu-24.04" = local.os_name_ubuntu_24_04
    "ubuntu-26.04" = local.os_name_ubuntu_26_04
    ubuntu         = local.os_name_ubuntu_24_04
  }

  os_name = lookup(local.os_name_map, var.os_name, var.os_name)
}

# Image
data "vultr_os" "agent" {
  filter {
    name   = "name"
    values = [local.os_name]
  }
}
