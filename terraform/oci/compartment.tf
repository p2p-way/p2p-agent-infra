# Locals
locals {
  create_compartment = var.agent_create && var.create_compartment
  compartment_id     = var.create_compartment ? try(oci_identity_compartment.common[0].id, null) : var.tenancy_ocid
}

# Compartment
resource "oci_identity_compartment" "common" {
  count = local.create_compartment ? 1 : 0

  name           = replace(var.agent_name, "/\\W/", "-")
  description    = var.agent_name
  compartment_id = var.tenancy_ocid
  enable_delete  = true
  freeform_tags  = var.default_tags
}
