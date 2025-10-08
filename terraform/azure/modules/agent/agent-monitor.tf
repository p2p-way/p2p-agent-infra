# Monitor Autoscale setting
resource "azurerm_monitor_autoscale_setting" "agent" {
  count = var.start_time == "watcher" || !local.create ? 0 : 1

  name                = local.autoscaler_name
  resource_group_name = azurerm_resource_group.agent[count.index].name
  location            = local.region
  target_resource_id  = azurerm_linux_virtual_machine_scale_set.agent[count.index].id

  profile {
    name = "initial_start"

    capacity {
      default = var.desired_capacity
      minimum = var.desired_capacity
      maximum = var.desired_capacity
    }

    fixed_date {
      start = local.start_start_time
      end   = local.start_stop_time
    }
  }

  profile {
    name = "initial_stop"

    capacity {
      default = 0
      minimum = 0
      maximum = 0
    }

    fixed_date {
      start = local.stop_start_time
      end   = local.stop_stop_time
    }
  }

  tags = var.default_tags
}

# Start time - Now
resource "time_offset" "start_start_now" {
  count = var.start_time == "now" && local.create ? 1 : 0

  offset_months  = contains(local.start_offset, "months") ? element(local.start_offset, 0) : null
  offset_days    = contains(local.start_offset, "days") ? element(local.start_offset, 0) : null
  offset_hours   = contains(local.start_offset, "hours") ? element(local.start_offset, 0) : null
  offset_minutes = contains(local.start_offset, "minutes") ? element(local.start_offset, 0) : null
  triggers       = { version = var.time_offset_version }
}

resource "time_offset" "start_stop_now" {
  count = var.start_time == "now" && local.create ? 1 : 0

  base_rfc3339   = var.start_time == "now" ? time_offset.start_start_now[count.index].rfc3339 : var.start_time
  offset_months  = contains(local.run_duration, "months") ? element(local.run_duration, 0) : null
  offset_days    = contains(local.run_duration, "days") ? element(local.run_duration, 0) : null
  offset_hours   = contains(local.run_duration, "hours") ? element(local.run_duration, 0) : null
  offset_minutes = contains(local.run_duration, "minutes") ? element(local.run_duration, 0) : null
  triggers       = { version = var.time_offset_version }
}

# Stop time
resource "time_offset" "stop_start" {
  count = var.start_time == "watcher" || !local.create ? 0 : 1

  base_rfc3339   = time_offset.start_stop_now[count.index].rfc3339
  offset_minutes = 1
  triggers       = { version = var.time_offset_version }
}

resource "time_offset" "stop_stop" {
  count = var.start_time == "watcher" || !local.create ? 0 : 1

  base_rfc3339   = time_offset.stop_start[count.index].rfc3339
  offset_minutes = 1
  triggers       = { version = var.time_offset_version }
}
