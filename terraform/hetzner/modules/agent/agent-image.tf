# Locals
locals {
  os_name_map = {
    ubuntu = "ubuntu-24.04"
  }

  os_name = lookup(local.os_name_map, var.os_name, var.os_name)
}

# Server
data "hcloud_server_type" "agent" {
  count = local.create ? 1 : 0

  name = var.server_type
}

# Image
data "hcloud_image" "agent" {
  count = local.create ? 1 : 0

  most_recent = true

  name              = local.os_name
  with_architecture = data.hcloud_server_type.agent[count.index].architecture

}
