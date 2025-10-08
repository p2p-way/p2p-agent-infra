# Locals
locals {
  os_name_map = {
    ubuntu = "ubuntu-24.04"
  }

  os_name = replace(lookup(local.os_name_map, var.os_name, var.os_name), "/[-.]+/", "_")
}

# Image
data "alicloud_images" "agent" {
  count = local.create ? 1 : 0

  owners                = "system"
  name_regex            = "^${local.os_name}"
  most_recent           = true
  instance_type         = var.instance_type
  status                = "Available"
  is_support_cloud_init = true
}
