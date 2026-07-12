# Log group
resource "yandex_logging_group" "agent" {
  count = local.agent_logs ? 1 : 0

  name             = local.resource_name
  description      = local.resource_description
  folder_id        = local.folder_id
  retention_period = var.agent_logs_retention
  labels           = local.default_labels
}
