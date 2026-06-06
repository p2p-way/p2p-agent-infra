# Locals
locals {
  create_project  = var.agent_create && var.project == null ? true : false
  default_project = var.agent_create && var.project == "" ? true : false
  project_id      = local.create_project ? scaleway_account_project.created[0].id : try(data.scaleway_account_project.existing[0].id, null)
}

# Project - Created
resource "scaleway_account_project" "created" {
  count = local.create_project ? 1 : 0

  name = var.agent_name
}

# Project - Existing
data "scaleway_account_project" "existing" {
  count = local.default_project ? 1 : 0

  name = var.project
}
