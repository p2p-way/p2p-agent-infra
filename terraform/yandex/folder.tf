# Locals
locals {
  create_folder  = var.agent_create && var.create_folder
  folder_id      = var.create_folder ? try(yandex_resourcemanager_folder.common[0].id, null) : var.folder_id
  default_labels = { for k, v in var.default_labels : lower(k) => replace(lower(v), " ", "-") }
}

# Folder
resource "yandex_resourcemanager_folder" "common" {
  count = local.create_folder ? 1 : 0

  name        = replace(var.agent_name, "/\\W/", "-")
  description = var.agent_name
  labels      = local.default_labels
}
