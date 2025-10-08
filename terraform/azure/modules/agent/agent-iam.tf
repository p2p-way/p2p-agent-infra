# IAM Role - Agent
resource "azurerm_role_definition" "agent" {
  count = local.agent_iam_create ? 1 : 0

  name        = local.resource_name
  description = local.resource_description
  scope       = azurerm_resource_group.agent[count.index].id

  permissions {
    actions = [
      "Microsoft.Insights/autoscaleSettings/read",
      "Microsoft.Insights/autoscaleSettings/write",
      "Microsoft.Compute/virtualMachineScaleSets/write"
    ]
  }

  assignable_scopes = [
    azurerm_resource_group.agent[count.index].id
  ]
}

# Virtual machine scale set - get principal_id
data "azurerm_virtual_machine_scale_set" "agent" {
  count = local.agent_iam_create ? 1 : 0

  name                = azurerm_linux_virtual_machine_scale_set.agent[count.index].name
  resource_group_name = azurerm_resource_group.agent[count.index].name
}

# IAM Role Assignment - Agent
resource "azurerm_role_assignment" "agent" {
  count = local.agent_iam_create ? 1 : 0

  scope              = azurerm_resource_group.agent[count.index].id
  role_definition_id = azurerm_role_definition.agent[count.index].role_definition_resource_id
  principal_id       = data.azurerm_virtual_machine_scale_set.agent[count.index].identity[0].principal_id
}
