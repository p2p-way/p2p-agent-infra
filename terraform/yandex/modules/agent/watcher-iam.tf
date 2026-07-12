# IAM - Watcher SA
resource "yandex_iam_service_account" "watcher" {
  count = local.watcher_create ? 1 : 0

  name        = local.watcher_name
  description = local.watcher_description
  labels      = local.default_labels
  folder_id   = local.folder_id
}

# IAM - Watcher binding
resource "yandex_function_iam_binding" "watcher" {
  count = local.watcher_create ? 1 : 0

  function_id = yandex_function.watcher[count.index].id
  role        = "serverless.functions.invoker"

  members = local.watcher_debug ? [
    "system:allUsers",
    "serviceAccount:${yandex_iam_service_account.watcher[count.index].id}"
    ] : [
    "serviceAccount:${yandex_iam_service_account.watcher[count.index].id}"
  ]
}

# IAM - Watcher logging role
resource "yandex_resourcemanager_folder_iam_member" "watcher_logging_writer" {
  count = local.watcher_create ? 1 : 0

  folder_id = local.folder_id
  role      = "logging.writer"
  member    = "serviceAccount:${yandex_iam_service_account.watcher[count.index].id}"
}

# IAM - Watcher Instance group role
resource "yandex_resourcemanager_folder_iam_member" "watcher_compute_editor" {
  count = local.watcher_create ? 1 : 0

  folder_id = local.folder_id
  role      = "compute.editor"
  member    = "serviceAccount:${yandex_iam_service_account.watcher[count.index].id}"
}

# IAM - Watcher scheduler trigger functions
resource "yandex_resourcemanager_folder_iam_member" "watcher_functions_editor" {
  count = local.watcher_create ? 1 : 0

  folder_id = local.folder_id
  role      = "functions.editor"
  member    = "serviceAccount:${yandex_iam_service_account.watcher[count.index].id}"
}

# IAM - Watcher scheduler trigger iam
resource "yandex_resourcemanager_folder_iam_member" "watcher_iam_serviceAccounts_user" {
  count = local.watcher_create ? 1 : 0

  folder_id = local.folder_id
  role      = "iam.serviceAccounts.user"
  member    = "serviceAccount:${yandex_iam_service_account.watcher[count.index].id}"
}
