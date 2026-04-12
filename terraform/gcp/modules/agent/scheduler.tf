# Scheduler job - Scheduler
resource "google_cloud_scheduler_job" "scheduler" {
  count = local.scheduler_create ? 1 : 0

  name             = local.scheduler_name
  description      = local.scheduler_description
  schedule         = "*/5 * * * *"
  time_zone        = "Etc/UTC"
  attempt_deadline = "15s"

  http_target {
    http_method = "GET"
    uri         = google_cloudfunctions2_function.watcher[count.index].url

    oidc_token {
      audience              = google_cloudfunctions2_function.watcher[count.index].service_config[0].uri
      service_account_email = google_service_account.scheduler[count.index].email
    }
  }

  region = local.region
}
