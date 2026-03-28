# SLS Log Store - Watcher
resource "alicloud_log_store" "watcher" {
  count = local.watcher_create ? 1 : 0

  project_name     = alicloud_log_project.common[count.index].name
  logstore_name    = "watcher"
  retention_period = 7
  append_meta      = true
  metering_mode    = "ChargeByFunction"
}

# SLS Log Store full-text indexing - Watcher
resource "alicloud_log_store_index" "watcher" {
  count = local.watcher_create ? 1 : 0

  project  = alicloud_log_project.common[count.index].project_name
  logstore = alicloud_log_store.watcher[count.index].logstore_name

  max_text_len          = 0
  log_reduce_black_list = []
  log_reduce_white_list = []
  log_reduce            = false

  full_text {
    case_sensitive = false
    token          = ", '\";=()[]{}?@&<>/:\t\r\n"
  }
  field_search {
    name             = "aggPeriodSeconds"
    alias            = ""
    enable_analytics = true
    type             = "long"
    token            = ""
  }
  field_search {
    alias            = ""
    name             = "concurrentRequests"
    enable_analytics = true
    type             = "long"
  }
  field_search {
    name             = "cpuPercent"
    alias            = ""
    enable_analytics = true
    token            = ""
    type             = "double"
  }
  field_search {
    name             = "cpuQuotaPercent"
    alias            = ""
    enable_analytics = true
    type             = "double"
    token            = ""
  }
  field_search {
    name             = "durationMs"
    alias            = ""
    enable_analytics = true
    type             = "double"
    token            = ""
  }
  field_search {
    name             = "errorType"
    alias            = ""
    enable_analytics = true
    type             = "text"
    token            = ", '\";=()[]{}?@&<>/:\t\r\n"
  }
  field_search {
    name             = "functionName"
    alias            = ""
    case_sensitive   = true
    enable_analytics = true
    type             = "text"
    token            = ", '\";=()[]{}?@&<>/:\t\r\n"
  }
  field_search {
    name             = "hasFunctionError"
    alias            = ""
    enable_analytics = true
    type             = "text"
    token            = ", '\";=()[]{}?@&<>/:\t\r\n"
  }
  field_search {
    name             = "hostname"
    alias            = ""
    enable_analytics = true
    type             = "text"
    token            = ", '\";=()[]{}?@&<>/:\t\r\n"
  }
  field_search {
    name             = "instanceID"
    alias            = ""
    enable_analytics = true
    type             = "text"
    token            = ", '\";=()[]{}?@&<>/:\t\r\n"
  }
  field_search {
    name             = "ipAddress"
    alias            = ""
    enable_analytics = true
    type             = "text"
    token            = ", '\";=()[]{}?@&<>/:\t\r\n"
  }
  field_search {
    name             = "isColdStart"
    alias            = ""
    enable_analytics = true
    type             = "text"
    token            = ", '\";=()[]{}?@&<>/:\t\r\n"
  }
  field_search {
    name             = "memoryLimitMB"
    alias            = ""
    enable_analytics = true
    type             = "double"
    token            = ""
  }
  field_search {
    name             = "memoryUsageMB"
    alias            = ""
    enable_analytics = true
    type             = "double"
    token            = ""
  }
  field_search {
    name             = "memoryUsagePercent"
    alias            = ""
    enable_analytics = true
    type             = "double"
    token            = ""
  }
  field_search {
    name             = "operation"
    alias            = ""
    enable_analytics = true
    type             = "text"
    token            = ", '\";=()[]{}?@&<>/:\t\r\n"
  }
  field_search {
    name             = "qualifier"
    alias            = ""
    case_sensitive   = true
    enable_analytics = true
    type             = "text"
    token            = ", '\";=()[]{}?@&<>/:\t\r\n"
  }
  field_search {
    name             = "rxBytes"
    alias            = ""
    enable_analytics = true
    type             = "long"
    token            = ""
  }
  field_search {
    name             = "rxTotalBytes"
    alias            = ""
    enable_analytics = true
    type             = "long"
    token            = ""
  }
  field_search {
    name             = "serviceName"
    alias            = ""
    case_sensitive   = true
    enable_analytics = true
    type             = "text"
    token            = ", '\";=()[]{}?@&<>/:\t\r\n"
  }
  field_search {
    name             = "statusCode"
    alias            = ""
    enable_analytics = true
    type             = "long"
    token            = ""
  }
  field_search {
    name             = "triggerType"
    alias            = ""
    enable_analytics = true
    type             = "text"
    token            = ", '\";=()[]{}?@&<>/:\t\r\n"
  }
  field_search {
    name             = "txBytes"
    alias            = ""
    enable_analytics = true
    type             = "long"
    token            = ""
  }
  field_search {
    name             = "txTotalBytes"
    alias            = ""
    enable_analytics = true
    type             = "long"
    token            = ""
  }
  field_search {
    name             = "versionId"
    alias            = ""
    enable_analytics = true
    type             = "text"
    token            = ", '\";=()[]{}?@&<>/:\t\r\n"
  }
}
