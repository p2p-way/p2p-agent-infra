# Resource Group
resource "azurerm_resource_group" "agent" {
  count = local.create ? 1 : 0

  name     = local.resource_name
  location = local.rg_region
  tags     = var.default_tags
}
