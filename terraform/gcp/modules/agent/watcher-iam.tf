# IAM Service account - Watcher
resource "google_service_account" "watcher" {
  count = local.watcher_create ? 1 : 0

  account_id   = local.watcher_account_id
  display_name = local.watcher_name
}

# IAM Role - Watcher - Agent update
resource "google_project_iam_custom_role" "watcher_agent_update" {
  count = local.watcher_create ? 1 : 0

  role_id = "${local.watcher_role_name}AgentUpdate${local.watcher_role_suffix}"
  title   = "${local.watcher_name}-agent-update"
  permissions = [
    "compute.autoscalers.get",
    "compute.autoscalers.update",
    "compute.instanceGroupManagers.get"
  ]
}

# IAM Policy - Watcher - Agent update
resource "google_project_iam_member" "watcher_agent_update" {
  count = local.watcher_create ? 1 : 0

  project = data.google_project.common[count.index].number
  role    = google_project_iam_custom_role.watcher_agent_update[count.index].name
  member  = "serviceAccount:${google_service_account.watcher[count.index].email}"

  # condition {
  #   title       = "watcher-agent-update"
  #   description = "Get and update instance group"
  #   expression  = "resource.name == '${google_compute_region_instance_group_manager.agent[count.index].id}'"
  # }
}

# IAM Role - Watcher - Scheduler update
resource "google_project_iam_custom_role" "watcher_scheduler_update" {
  count = local.watcher_create ? 1 : 0

  role_id = "${local.watcher_role_name}SchedulerUpdate${local.watcher_role_suffix}"
  title   = "${local.watcher_name}-scheduler-update"
  permissions = [
    "cloudscheduler.jobs.get",
    "cloudscheduler.jobs.update",
    "iam.serviceAccounts.actAs"
  ]
}

# IAM Policy - Watcher - Scheduler update
resource "google_project_iam_member" "watcher_scheduler_update" {
  count = local.watcher_create ? 1 : 0

  project = data.google_project.common[count.index].number
  role    = google_project_iam_custom_role.watcher_scheduler_update[count.index].name
  member  = "serviceAccount:${google_service_account.watcher[count.index].email}"

  # condition {
  #   title       = "watcher-scheduler-update"
  #   description = "Get and update scheduler"
  #   expression  = "resource.name == '${google_cloud_scheduler_job.scheduler[count.index].id}'"
  # }
}

# IAM Policy - Watcher - Debug
resource "google_cloud_run_service_iam_member" "watcher_debug" {
  count = local.watcher_create && local.watcher_debug ? 1 : 0

  location = google_cloudfunctions2_function.watcher[count.index].location
  service  = google_cloudfunctions2_function.watcher[count.index].name
  role     = "roles/run.invoker"
  member   = "allUsers"
}
