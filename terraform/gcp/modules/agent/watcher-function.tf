# Cloud Run function - Watcher
resource "google_cloudfunctions2_function" "watcher" {
  count = local.watcher_create ? 1 : 0

  name        = local.watcher_name
  description = local.watcher_description
  location    = local.region

  build_config {
    runtime     = replace(var.watcher_runtime, ".", "")
    entry_point = "main_handler"
    source {
      storage_source {
        bucket     = google_storage_bucket.watcher[count.index].name
        object     = google_storage_bucket_object.watcher[count.index].name
        generation = google_storage_bucket_object.watcher[count.index].generation
      }
    }
  }

  service_config {
    min_instance_count = 0
    max_instance_count = 1
    available_cpu      = 0.1
    available_memory   = "384Mi"
    timeout_seconds    = 5

    environment_variables = {
      cloud            = var.default_labels["Cloud"]
      region           = local.region
      project          = data.google_project.common[count.index].project_id
      name             = local.watcher_name
      cc_hosts         = join(" ", var.agent_cc_hosts)
      agent_name       = google_compute_region_instance_group_manager.agent[count.index].name
      agent_prefix     = var.watcher_cc_agent_prefix
      scheduler_name   = local.scheduler_name
      scheduler_prefix = var.watcher_cc_scheduler_prefix
    }

    service_account_email = google_service_account.watcher[count.index].email
    ingress_settings      = local.watcher_debug ? "ALLOW_ALL" : "ALLOW_INTERNAL_ONLY"
  }

  labels = { for k, v in var.default_labels : lower(k) => lower(replace(v, " ", "-")) }
}
