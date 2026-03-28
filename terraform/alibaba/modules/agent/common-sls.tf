# SLS project - Common
resource "alicloud_log_project" "common" {
  count = local.agent_logs || local.watcher_create ? 1 : 0

  project_name      = "${local.resource_name}-${random_string.log_project_suffix[count.index].result}"
  description       = "${local.resource_description} - ${random_string.log_project_suffix[count.index].result}"
  resource_group_id = alicloud_resource_manager_resource_group.common[count.index].id

  tags = var.default_tags
}

# SLS project suffix - Common
resource "random_string" "log_project_suffix" {
  count = local.agent_logs || local.watcher_create ? 1 : 0

  length  = 5
  upper   = false
  special = false
  keepers = { version = 1 }
}
