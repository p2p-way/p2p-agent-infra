# Log group - Watcher
resource "yandex_logging_group" "watcher" {
  count = local.watcher_create ? 1 : 0

  name             = local.watcher_name
  description      = local.watcher_description
  folder_id        = local.folder_id
  retention_period = var.agent_logs_retention
  labels           = local.default_labels
}
