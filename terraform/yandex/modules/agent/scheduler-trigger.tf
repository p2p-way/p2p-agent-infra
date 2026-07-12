# Trigger - Scheduler
resource "yandex_function_trigger" "scheduler" {
  count = local.scheduler_create ? 1 : 0

  # Basic settings
  name        = local.scheduler_name
  description = local.scheduler_description
  folder_id   = local.folder_id
  labels      = local.default_labels

  # Timer settings
  timer {
    cron_expression = local.scheduler_expression
  }

  # Function settings
  function {
    id                 = yandex_function.watcher[count.index].id
    tag                = "$latest"
    service_account_id = yandex_iam_service_account.scheduler[count.index].id
    retry_attempts     = null
    retry_interval     = null
  }

  # Repeat request settings - set above
}
