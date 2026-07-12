# IAM - scheduler SA
resource "yandex_iam_service_account" "scheduler" {
  count = local.scheduler_create ? 1 : 0

  name        = local.scheduler_name
  description = local.scheduler_description
  labels      = local.default_labels
  folder_id   = local.folder_id
}

# IAM - Scheduler functionInvoker role
resource "yandex_resourcemanager_folder_iam_member" "scheduler_functions_invoker" {
  count = local.scheduler_create ? 1 : 0

  folder_id = local.folder_id
  role      = "functions.functionInvoker"
  member    = "serviceAccount:${yandex_iam_service_account.scheduler[count.index].id}"
}
