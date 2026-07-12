# IAM - Agent SA
resource "yandex_iam_service_account" "agent" {
  count = local.agent_iam_create ? 1 : 0

  name        = local.resource_name
  description = local.resource_description
  labels      = local.default_labels
  folder_id   = local.folder_id
}

# IAM - Agent metrics role
resource "yandex_resourcemanager_folder_iam_member" "agent_monitoring_editor" {
  count = local.agent_metrics ? 1 : 0

  folder_id = local.folder_id
  role      = "monitoring.editor"
  member    = "serviceAccount:${yandex_iam_service_account.agent[count.index].id}"
}

# IAM - Agent logging role
resource "yandex_resourcemanager_folder_iam_member" "agent_logging_writer" {
  count = local.agent_logs ? 1 : 0

  folder_id = local.folder_id
  role      = "logging.writer"
  member    = "serviceAccount:${yandex_iam_service_account.agent[count.index].id}"
}

# IAM - Agent autoscaler SA
resource "yandex_resourcemanager_folder_iam_member" "agent_compute_editor" {
  count = local.agent_iam_create ? 1 : 0

  folder_id = local.folder_id
  role      = "compute.editor"
  member    = "serviceAccount:${yandex_iam_service_account.agent[count.index].id}"
}

# IAM - Instance group SA
resource "yandex_iam_service_account" "instance_group" {
  count = local.create ? 1 : 0

  name        = "${local.resource_name}-instance-group"
  description = "${local.resource_description} - Instance group"
  labels      = local.default_labels
  folder_id   = local.folder_id
}

# IAM - Instance group role
resource "yandex_resourcemanager_folder_iam_member" "instance_group" {
  count = local.create ? 1 : 0

  folder_id = local.folder_id
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.instance_group[count.index].id}"
}
