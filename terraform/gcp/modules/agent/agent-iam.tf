# IAM Service account - Agent
resource "google_service_account" "agent" {
  count = local.agent_iam_create ? 1 : 0

  account_id   = local.account_id
  display_name = local.resource_name
}

# IAM Role - Agent watcher - List
resource "google_project_iam_custom_role" "agent_watcher_list" {
  count = local.agent_watcher ? 1 : 0

  role_id = "${local.agent_role_name}WatcherList${local.agent_role_suffix}"
  title   = "${local.resource_name}-watcher-list"
  permissions = [
    "compute.autoscalers.list",
    "compute.instanceGroups.list",
    "compute.instanceGroupManagers.list"
  ]
}

# IAM Role - Agent watcher - Update
resource "google_project_iam_custom_role" "agent_watcher_update" {
  count = local.agent_watcher ? 1 : 0

  role_id = "${local.agent_role_name}WatcherUpdate${local.agent_role_suffix}"
  title   = "${local.resource_name}-watcher-update"
  permissions = [
    "compute.autoscalers.get",
    "compute.autoscalers.update",
    "compute.instanceGroupManagers.get"
  ]
}

# IAM Role - Ops Agent - Logs
resource "google_project_iam_custom_role" "agent_logs" {
  count = local.agent_logs ? 1 : 0

  role_id = "${local.agent_role_name}Logs${local.agent_role_suffix}"
  title   = "${local.resource_name}-logs"
  # https://cloud.google.com/iam/docs/understanding-roles#logging.logWriter
  permissions = [
    "logging.logEntries.create",
    "logging.logEntries.route"
  ]
}

# IAM Role - Ops Agent - Metrics
resource "google_project_iam_custom_role" "agent_metrics" {
  # Agent metrics can't be totally disabled
  count = local.agent_logs || local.agent_metrics ? 1 : 0

  role_id = "${local.agent_role_name}Metrics${local.agent_role_suffix}"
  title   = "${local.resource_name}-metrics"
  # https://cloud.google.com/iam/docs/understanding-roles#monitoring.metricWriter
  permissions = [
    "monitoring.metricDescriptors.create",
    "monitoring.metricDescriptors.get",
    "monitoring.metricDescriptors.list",
    "monitoring.monitoredResourceDescriptors.get",
    "monitoring.monitoredResourceDescriptors.list",
    "monitoring.timeSeries.create"
  ]
}

# IAM Policy - Agent watcher - List
resource "google_project_iam_member" "agent_watcher_list" {
  count = local.agent_iam_create ? 1 : 0

  project = data.google_project.agent[count.index].number
  role    = google_project_iam_custom_role.agent_watcher_list[count.index].name
  member  = "serviceAccount:${google_service_account.agent[count.index].email}"

  condition {
    title       = "watcher-list-all"
    description = "List all autoscalers and instance groups"
    expression  = "resource.name == '${data.google_project.agent[count.index].id}'"
  }
}

# IAM Policy - Agent watcher - Update
resource "google_project_iam_member" "agent_watcher_update" {
  count = local.agent_watcher ? 1 : 0

  project = data.google_project.agent[count.index].number
  role    = google_project_iam_custom_role.agent_watcher_update[count.index].name
  member  = "serviceAccount:${google_service_account.agent[count.index].email}"

  condition {
    title       = "watcher-update-${local.resource_name}"
    description = "Update autoscaler and instance group ${local.resource_name}"
    expression  = "(resource.name == '${google_compute_region_autoscaler.agent[count.index].id}' || resource.name == '${google_compute_region_instance_group_manager.agent[count.index].id}')"
  }
}

# IAM Policy - Ops Agent - Logs
resource "google_project_iam_member" "agent_logs" {
  count = local.agent_logs ? 1 : 0

  project = data.google_project.agent[count.index].number
  role    = google_project_iam_custom_role.agent_logs[count.index].name
  member  = "serviceAccount:${google_service_account.agent[count.index].email}"

  condition {
    title       = "logs-${local.resource_name}"
    description = "Logs ${local.resource_name}"
    expression  = "resource.name.startsWith ('${data.google_project.agent[count.index].id}/logs/')"
  }
}

# IAM Policy - Ops Agent - Metrics
resource "google_project_iam_member" "agent_metrics" {
  # Agent metrics can't be totally disabled
  count = local.agent_metrics || local.agent_logs ? 1 : 0

  project = data.google_project.agent[count.index].number
  role    = google_project_iam_custom_role.agent_metrics[count.index].name
  member  = "serviceAccount:${google_service_account.agent[count.index].email}"
}
