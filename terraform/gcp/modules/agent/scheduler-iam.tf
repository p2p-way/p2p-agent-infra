# IAM Service account - Scheduler
resource "google_service_account" "scheduler" {
  count = local.scheduler_create ? 1 : 0

  account_id   = local.scheduler_account_id
  display_name = local.scheduler_name
}

# IAM Policy - Scheduler - Watcher invoke
resource "google_cloudfunctions2_function_iam_member" "invoker" {
  count = local.scheduler_create ? 1 : 0

  project        = google_cloudfunctions2_function.watcher[count.index].project
  location       = google_cloudfunctions2_function.watcher[count.index].location
  cloud_function = google_cloudfunctions2_function.watcher[count.index].name
  role           = "roles/cloudfunctions.invoker"
  member         = "serviceAccount:${google_service_account.scheduler[count.index].email}"
}

# IAM Policy - Scheduler - Watcher service invoke
resource "google_cloud_run_service_iam_member" "cloud_run_invoker" {
  count = local.scheduler_create ? 1 : 0

  project  = google_cloudfunctions2_function.watcher[count.index].project
  location = google_cloudfunctions2_function.watcher[count.index].location
  service  = google_cloudfunctions2_function.watcher[count.index].name
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.scheduler[count.index].email}"
}
