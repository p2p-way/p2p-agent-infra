# SLS Log Store - Agent
resource "alicloud_log_store" "agent" {
  count = local.agent_logs ? 1 : 0

  project_name     = alicloud_log_project.common[count.index].name
  logstore_name    = "agent"
  retention_period = var.agent_logs_retention
  append_meta      = true
  metering_mode    = var.agent_logs_metering_mode
}

# SLS Log Store full-text indexing - Agent
resource "alicloud_log_store_index" "agent" {
  count = local.agent_logs ? 1 : 0

  project  = alicloud_log_project.common[count.index].project_name
  logstore = alicloud_log_store.agent[count.index].logstore_name
  full_text {
    case_sensitive = true
    token          = " #$^*\r\n\t"
  }
  field_search {
    name             = "__hostname__"
    alias            = "hostname"
    enable_analytics = true
    type             = "text"
    token            = " #$^*\r\n\t"
  }
  field_search {
    name             = "__path__"
    alias            = "path"
    enable_analytics = true
    type             = "text"
    token            = " #$^*\r\n\t"
  }
  field_search {
    name             = "__raw_log__"
    alias            = "log"
    enable_analytics = true
    type             = "text"
    token            = " #$^*\r\n\t"
  }
  field_search {
    name             = "__source__"
    alias            = "source"
    enable_analytics = true
    type             = "text"
    token            = " #$^*\r\n\t"
  }
}

# Logtail config - Agent
resource "alicloud_logtail_config" "agent" {
  for_each = local.agent_logs ? toset(local.agent_log_files) : []

  name         = basename(replace(each.key, ".", "-"))
  project      = alicloud_log_project.common[0].project_name
  logstore     = alicloud_log_store.agent[0].logstore_name
  input_type   = "file"
  output_type  = "LogService"
  input_detail = <<DEFINITION
      {
        "logPath": "${dirname(each.key)}",
        "filePattern": "${basename(each.key)}",
        "logType": "json_log",
        "topicFormat": "default",
        "discardUnmatch": false,
        "enableRawLog": true,
        "fileEncoding": "gbk",
        "maxDepth": 10
    }
  DEFINITION
}

# Logtail machine group - Agent
resource "alicloud_log_machine_group" "agent" {
  count = local.agent_logs ? 1 : 0

  name          = local.resource_name
  project       = alicloud_log_project.common[count.index].project_name
  identify_type = "userdefined"
  topic         = local.resource_name
  identify_list = [alicloud_log_project.common[count.index].project_name]
}

# Logtail config to a machine group - Agent
resource "alicloud_logtail_attachment" "agent" {
  for_each = local.agent_logs ? { for idx, config in alicloud_logtail_config.agent : idx => config.name } : {}

  project             = alicloud_log_project.common[0].project_name
  logtail_config_name = basename(replace(each.value, ".", "-"))
  machine_group_name  = alicloud_log_machine_group.agent[0].name
}
