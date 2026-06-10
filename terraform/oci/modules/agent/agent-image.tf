# Locals
locals {
  os_name_map = {
    "ubuntu-24.04" = "ubuntu-24.04"
    "ubuntu-26.04" = "ubuntu-26.04"
    ubuntu         = "ubuntu-24.04"
  }

  os_full_name_map = {
    ubuntu = "Canonical Ubuntu"
  }

  os_name      = element(split("-", lookup(local.os_name_map, var.os_name)), 0)
  os_full_name = lookup(local.os_full_name_map, local.os_name)
  os_version   = element(split("-", lookup(local.os_name_map, var.os_name)), 1)
}

# Image
data "oci_core_images" "agent" {
  count = local.create ? 1 : 0

  compartment_id           = local.compartment_id
  operating_system         = local.os_full_name
  operating_system_version = local.os_version
  shape                    = local.instance_type
  sort_by                  = "TIMECREATED"
  state                    = "AVAILABLE"
}
