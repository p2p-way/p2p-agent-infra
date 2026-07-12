# Function - Watcher
resource "yandex_function" "watcher" {
  count = local.watcher_create ? 1 : 0

  # Main
  name        = local.watcher_name
  description = local.watcher_description
  folder_id   = local.folder_id
  labels      = local.default_labels

  # Function code
  runtime = replace(var.watcher_runtime, ".", "")
  content { zip_filename = data.archive_file.watcher[count.index].output_path }
  user_hash  = filemd5(data.archive_file.watcher[count.index].output_path)
  entrypoint = "${trimsuffix(var.watcher_file, format(".%s", element(split(".", var.watcher_file), -1)))}.main_handler"

  # Parameters
  execution_timeout  = 5
  memory             = 128
  service_account_id = yandex_iam_service_account.watcher[count.index].id

  # Environment variables
  environment = {
    cloud            = var.default_labels["Cloud"]
    region           = var.region
    folder_id        = local.folder_id
    name             = local.watcher_name
    cc_hosts         = join(" ", var.agent_cc_hosts)
    agent_name       = yandex_compute_instance_group.agent[count.index].name
    agent_prefix     = var.watcher_cc_agent_prefix
    scheduler_name   = local.scheduler_name
    scheduler_prefix = var.watcher_cc_scheduler_prefix
  }

  # Yandex Lockbox secrets

  # Logging
  log_options {
    log_group_id = yandex_logging_group.watcher[count.index].id
    min_level    = null
  }

  # Additional settings

  # Memory

  # Mounted buckets

  # Asynchronous call

  # Concurrent function instance calls

  # Metadata service parameters
  metadata_options {
    gce_http_endpoint = 1
  }
}

# Archive - Watcher
data "archive_file" "watcher" {
  count = local.watcher_create ? 1 : 0

  type        = "zip"
  source_dir  = "${path.module}/files/${var.watcher_file}"
  output_path = "${var.watcher_file}-${var.region}.zip"
}
