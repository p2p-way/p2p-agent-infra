# FC - Watcher
resource "alicloud_fcv3_function" "watcher" {
  count = local.watcher_create ? 1 : 0

  # Basic Configurations
  function_name = local.watcher_name
  description   = local.watcher_description

  # Scaling configuration
  cpu         = 0.05
  memory_size = 128
  disk_size   = 512
  # instance_concurrency = 0

  # Code
  runtime = var.watcher_runtime

  code {
    zip_file = filebase64(data.archive_file.watcher[count.index].output_path)
    checksum = data.alicloud_file_crc64_checksum.watcher[count.index].checksum
  }

  handler = "${trimsuffix(var.watcher_file, format(".%s", element(split(".", var.watcher_file), -1)))}.main_handler"
  timeout = 5

  # Permissions
  role = alicloud_ram_role.watcher[count.index].arn

  # Network
  internet_access = true

  # Storage

  # Logging & Tracing
  log_config {
    project                 = alicloud_log_project.common[count.index].project_name
    logstore                = alicloud_log_store.watcher[count.index].logstore_name
    log_begin_rule          = "None"
    enable_instance_metrics = true
    enable_request_metrics  = true
  }

  # More configuration
  resource_group_id = alicloud_resource_manager_resource_group.common[count.index].id
  tags              = var.default_tags

  environment_variables = {
    cloud            = var.default_tags["Cloud"]
    region           = local.region
    account          = local.account
    cc_hosts         = join(" ", var.agent_cc_hosts)
    agent_name       = alicloud_ess_scaling_group.agent[count.index].scaling_group_name
    agent_prefix     = var.watcher_cc_agent_prefix
    scheduler_prefix = var.watcher_cc_scheduler_prefix
    scheduler_name   = local.scheduler_name
    PYTHONPATH       = "/opt/python"
    PATH             = "/var/fc/lang/${var.watcher_runtime}/bin:/usr/local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/bin"
  }

  layers = [
    alicloud_fcv3_layer_version.watcher[count.index].layer_version_arn
  ]
}

resource "alicloud_fcv3_layer_version" "watcher" {
  count = local.watcher_create ? 1 : 0

  description        = format("%s-%s", local.watcher_description, var.watcher_runtime)
  layer_name         = format("%s-%s", local.watcher_name, replace(var.watcher_runtime, ".", "-"))
  compatible_runtime = [var.watcher_runtime]
  acl                = 0
  code {
    oss_bucket_name = alicloud_oss_bucket_object.watcher[count.index].bucket
    oss_object_name = alicloud_oss_bucket_object.watcher[count.index].key
  }
}

# Archive - Watcher
data "archive_file" "watcher" {
  count = local.watcher_create ? 1 : 0

  type        = "zip"
  source_file = "${path.module}/files/${var.watcher_file}"
  output_path = "${var.watcher_file}-${local.region}.zip"
}

# crc64 checksum - Watcher
data "alicloud_file_crc64_checksum" "watcher" {
  count = local.watcher_create ? 1 : 0

  filename = data.archive_file.watcher[count.index].output_path
}

# FC version - Watcher
resource "alicloud_fcv3_function_version" "watcher" {
  count = local.watcher_create ? 1 : 0

  description   = "LATEST"
  function_name = alicloud_fcv3_function.watcher[count.index].id
}

# FC alias - Watcher
resource "alicloud_fcv3_alias" "watcher" {
  count = local.watcher_create ? 1 : 0

  alias_name    = "latest"
  description   = "Latest version of ${local.watcher_name} function"
  version_id    = alicloud_fcv3_function_version.watcher[count.index].version_id
  function_name = alicloud_fcv3_function.watcher[count.index].id
}

# FC Trigger - Scheduler (development/debug)
resource "alicloud_fcv3_trigger" "scheduler" {
  count = local.scheduler_create ? 1 : 0

  trigger_type   = "timer"
  trigger_name   = local.scheduler_name
  description    = local.scheduler_description
  qualifier      = alicloud_fcv3_alias.watcher[count.index].alias_name
  trigger_config = jsonencode({ "cronExpression" : "${local.scheduler_expression}", "enable" : true, "payload" : "" })
  function_name  = alicloud_fcv3_function.watcher[count.index].function_name
}

# FC Trigger - Debug (development/debug)
resource "alicloud_fcv3_trigger" "debug" {
  count = local.watcher_create && false ? 1 : 0

  trigger_type   = "http"
  trigger_name   = "debug"
  description    = "debug only"
  qualifier      = alicloud_fcv3_alias.watcher[count.index].alias_name
  trigger_config = jsonencode({ "authType" : "anonymous", "disableURLInternet" : false, "methods" : ["GET"] })
  function_name  = alicloud_fcv3_function.watcher[count.index].function_name
}
