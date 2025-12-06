# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "agent" {
  count = local.agent_logs ? 1 : 0

  name                = local.resource_name
  location            = local.rg_region
  resource_group_name = azurerm_resource_group.agent[count.index].name
  sku                 = "PerGB2018"
  retention_in_days   = var.agent_logs_retention
  tags                = var.default_tags
}

# Extension - AzureMonitorLinuxAgent
resource "azurerm_virtual_machine_scale_set_extension" "azure_monitor_linux_agent" {
  count = local.agent_logs || local.agent_metrics ? 1 : 0

  name                         = "azure-monitor-linux-agent"
  virtual_machine_scale_set_id = azurerm_linux_virtual_machine_scale_set.agent[count.index].id
  publisher                    = "Microsoft.Azure.Monitor"
  type                         = "AzureMonitorLinuxAgent"
  type_handler_version         = "1.38" # https://learn.microsoft.com/en-us/azure/azure-monitor/agents/azure-monitor-agent-extension-versions
  automatic_upgrade_enabled    = false
  auto_upgrade_minor_version   = true
  settings = jsonencode({
    "workspaceId" = "${azurerm_log_analytics_workspace.agent[count.index].workspace_id}"
  })
}

# Data Collection Endpoint
resource "azurerm_monitor_data_collection_endpoint" "agent" {
  count = local.agent_logs || local.agent_metrics ? 1 : 0

  name                = local.resource_name
  description         = local.resource_description
  resource_group_name = azurerm_resource_group.agent[count.index].name
  location            = local.rg_region
  kind                = "Linux"
  tags                = var.default_tags
}

# Wait for Workspace
resource "time_sleep" "wait_for_workspace" {
  count = local.agent_logs ? 1 : 0

  create_duration = "60s"

  depends_on = [azurerm_log_analytics_workspace.agent]
}

# Custom Log Table - cloud-init.log
resource "azurerm_log_analytics_workspace_table_custom_log" "cloud_init" {
  count = local.agent_logs ? 1 : 0

  name         = "cloud_init_CL"
  display_name = "cloud-init.log"
  description  = "cloud-init.log log file"
  workspace_id = azurerm_log_analytics_workspace.agent[count.index].id

  retention_in_days       = 7
  total_retention_in_days = 7

  column {
    name        = "TimeGenerated"
    type        = "dateTime"
    description = "The time at which the data was generated"
  }

  column {
    name        = "Computer"
    type        = "string"
    description = "Computer which send the logs"
  }

  column {
    name        = "FilePath"
    type        = "string"
    description = "Log file path"
  }

  column {
    name        = "RawData"
    type        = "string"
    description = "Log raw data"
  }

  depends_on = [time_sleep.wait_for_workspace]
}

# Custom Log Table - cloud-init-output.log
resource "azurerm_log_analytics_workspace_table_custom_log" "cloud_init_output" {
  count = local.agent_logs ? 1 : 0

  name         = "cloud_init_output_CL"
  display_name = "cloud-init-output.log"
  description  = "cloud-init-output.log log file"
  workspace_id = azurerm_log_analytics_workspace.agent[count.index].id

  retention_in_days       = 7
  total_retention_in_days = 7

  column {
    name        = "TimeGenerated"
    type        = "dateTime"
    description = "The time at which the data was generated"
  }

  column {
    name        = "Computer"
    type        = "string"
    description = "Computer which send the logs"
  }

  column {
    name        = "FilePath"
    type        = "string"
    description = "Log file path"
  }

  column {
    name        = "RawData"
    type        = "string"
    description = "Log raw data"
  }

  depends_on = [time_sleep.wait_for_workspace]
}

# Custom Log Table - p2p-agent.log
resource "azurerm_log_analytics_workspace_table_custom_log" "p2p_agent" {
  count = local.agent_logs ? 1 : 0

  name         = "${replace(element(split(".", var.agent_log_file), 0), "-", "_")}_CL"
  display_name = basename(var.agent_log_file)
  description  = "${basename(var.agent_log_file)} log file"
  workspace_id = azurerm_log_analytics_workspace.agent[count.index].id

  retention_in_days       = 7
  total_retention_in_days = 7

  column {
    name        = "TimeGenerated"
    type        = "dateTime"
    description = "The time at which the data was generated"
  }

  column {
    name        = "Computer"
    type        = "string"
    description = "Computer which send the logs"
  }

  column {
    name        = "FilePath"
    type        = "string"
    description = "Log file path"
  }

  column {
    name        = "RawData"
    type        = "string"
    description = "Log raw data"
  }

  depends_on = [time_sleep.wait_for_workspace]
}

# Data Collection Rule
resource "azurerm_monitor_data_collection_rule" "agent" {
  count = local.agent_logs || local.agent_metrics ? 1 : 0

  name                        = local.resource_name
  description                 = local.resource_description
  resource_group_name         = azurerm_resource_group.agent[count.index].name
  location                    = local.rg_region
  data_collection_endpoint_id = azurerm_monitor_data_collection_endpoint.agent[count.index].id
  kind                        = "Linux"
  tags                        = var.default_tags

  identity {
    type = "SystemAssigned"
  }

  # Destinations
  destinations {
    # Destination - Logs Analytics
    dynamic "log_analytics" {
      for_each = local.agent_logs ? [1] : []
      content {
        name                  = local.resource_name
        workspace_resource_id = azurerm_log_analytics_workspace.agent[count.index].id
      }
    }

    # Destination - Monitor Insights
    dynamic "azure_monitor_metrics" {
      for_each = local.agent_metrics ? [1] : []
      content {
        name = "${local.resource_name}-metrics"
      }
    }
  }

  # Data flow - Metrics
  dynamic "data_flow" {
    for_each = local.agent_metrics ? [1] : []
    content {
      streams      = ["Microsoft-InsightsMetrics"]
      destinations = ["${local.resource_name}-metrics"]
    }
  }

  # Data flow - Syslog
  dynamic "data_flow" {
    for_each = local.agent_logs ? [1] : []
    content {
      streams       = ["Microsoft-Syslog"]
      destinations  = [azurerm_log_analytics_workspace.agent[count.index].name]
      output_stream = "Microsoft-Syslog"
      # transform_kql = "source | project TimeGenerated = Time, Computer, Message = AdditionalContext"
    }
  }

  # Data flow - cloud-init.log
  dynamic "data_flow" {
    for_each = local.agent_logs ? [1] : []
    content {
      streams       = ["Custom-${azurerm_log_analytics_workspace_table_custom_log.cloud_init[count.index].name}"]
      destinations  = [azurerm_log_analytics_workspace.agent[count.index].name]
      output_stream = "Custom-${azurerm_log_analytics_workspace_table_custom_log.cloud_init[count.index].name}"
    }
  }

  # Data flow - cloud-init-output.log
  dynamic "data_flow" {
    for_each = local.agent_logs ? [1] : []
    content {
      streams       = ["Custom-${azurerm_log_analytics_workspace_table_custom_log.cloud_init_output[count.index].name}"]
      destinations  = [azurerm_log_analytics_workspace.agent[count.index].name]
      output_stream = "Custom-${azurerm_log_analytics_workspace_table_custom_log.cloud_init_output[count.index].name}"
    }
  }

  # Data flow - p2p-agent.log
  dynamic "data_flow" {
    for_each = local.agent_logs ? [1] : []
    content {
      streams       = ["Custom-${azurerm_log_analytics_workspace_table_custom_log.p2p_agent[count.index].name}"]
      destinations  = [azurerm_log_analytics_workspace.agent[count.index].name]
      output_stream = "Custom-${azurerm_log_analytics_workspace_table_custom_log.p2p_agent[count.index].name}"
    }
  }

  # Data sources
  data_sources {
    # Data source - metrics
    dynamic "performance_counter" {
      for_each = local.agent_metrics ? [1] : []
      content {
        name                          = local.resource_name
        streams                       = ["Microsoft-Perf", "Microsoft-InsightsMetrics"]
        sampling_frequency_in_seconds = 60
        counter_specifiers            = ["*"]
      }
    }

    # Data source - syslog
    dynamic "syslog" {
      for_each = local.agent_logs ? [1] : []
      content {
        name           = "syslog"
        facility_names = ["*"]
        log_levels     = ["*"]
        streams        = ["Microsoft-Syslog"]
      }
    }

    # Data source - cloud-init.log
    dynamic "log_file" {
      for_each = local.agent_logs ? [1] : []
      content {
        name          = "cloud-init.log"
        format        = "text"
        streams       = ["Custom-${azurerm_log_analytics_workspace_table_custom_log.cloud_init[count.index].name}"]
        file_patterns = ["/var/log/cloud-init.log"]
        settings {
          text {
            record_start_timestamp_format = "ISO 8601"
          }
        }
      }
    }

    # Data source - cloud-init-output.log
    dynamic "log_file" {
      for_each = local.agent_logs ? [1] : []
      content {
        name          = "cloud-init-output.log"
        format        = "text"
        streams       = ["Custom-${azurerm_log_analytics_workspace_table_custom_log.cloud_init_output[count.index].name}"]
        file_patterns = ["/var/log/cloud-init-output.log"]
        settings {
          text {
            record_start_timestamp_format = "ISO 8601"
          }
        }
      }
    }

    # Data source - p2p-agent.log
    dynamic "log_file" {
      for_each = local.agent_logs ? [1] : []
      content {
        name          = var.agent_log_file
        format        = "text"
        streams       = ["Custom-${azurerm_log_analytics_workspace_table_custom_log.p2p_agent[count.index].name}"]
        file_patterns = ["${dirname(var.agent_base_folder)}/${var.agent_log_file}"]
        settings {
          text {
            record_start_timestamp_format = "ISO 8601"
          }
        }
      }
    }
  }

  # Stream - cloud-init
  dynamic "stream_declaration" {
    for_each = local.agent_logs ? [1] : []
    content {
      stream_name = "Custom-${azurerm_log_analytics_workspace_table_custom_log.cloud_init[count.index].name}"
      column {
        name = "TimeGenerated"
        type = "datetime"
      }
      column {
        name = "Log"
        type = "string"
      }
    }
  }

  # Stream - cloud-init-output
  dynamic "stream_declaration" {
    for_each = local.agent_logs ? [1] : []
    content {
      stream_name = "Custom-${azurerm_log_analytics_workspace_table_custom_log.cloud_init_output[count.index].name}"
      column {
        name = "TimeGenerated"
        type = "datetime"
      }
      column {
        name = "Log"
        type = "string"
      }
    }
  }

  # Stream - p2p-agent.log
  dynamic "stream_declaration" {
    for_each = local.agent_logs ? [1] : []
    content {
      stream_name = "Custom-${azurerm_log_analytics_workspace_table_custom_log.p2p_agent[count.index].name}"
      column {
        name = "TimeGenerated"
        type = "datetime"
      }
      column {
        name = "Log"
        type = "string"
      }
    }
  }
}

# Data Collection Rule Association - Data Collection Rule
resource "azurerm_monitor_data_collection_rule_association" "agent_dcr" {
  count = local.agent_logs || local.agent_metrics ? 1 : 0

  name                    = local.resource_name
  description             = "${local.resource_description} - Data Collection Rule"
  target_resource_id      = azurerm_linux_virtual_machine_scale_set.agent[count.index].id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.agent[count.index].id
}

# Data Collection Rule Association - Data Collection Endpoint
resource "azurerm_monitor_data_collection_rule_association" "agent_dce" {
  count = local.agent_logs || local.agent_metrics ? 1 : 0

  description                 = "${local.resource_description} - Data Collection Endpoint"
  target_resource_id          = azurerm_linux_virtual_machine_scale_set.agent[count.index].id
  data_collection_endpoint_id = azurerm_monitor_data_collection_endpoint.agent[count.index].id
}
