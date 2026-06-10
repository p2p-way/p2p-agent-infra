# Auto Scaling Configuration
resource "oci_autoscaling_auto_scaling_configuration" "initial_start_stop" {
  count = local.create ? 1 : 0

  compartment_id = local.compartment_id
  display_name   = local.resource_name
  freeform_tags  = local.freeform_tags
  is_enabled     = "true"

  cool_down_in_seconds = 300

  # Start
  policies {
    display_name = "initial-start"
    policy_type  = "scheduled"

    execution_schedule {
      expression = "0 ${local.start_time_parse["minute"]} ${local.start_time_parse["hour"]} ${local.start_time_parse["day"]} ${local.start_time_parse["month"]} ? ${local.start_time_parse["year"]}"
      timezone   = "UTC"
      type       = "cron"
    }
    capacity {
      initial = var.desired_capacity
    }
  }

  # Stop
  policies {
    capacity {
      initial = 0
    }
    display_name = "initial-stop"
    policy_type  = "scheduled"

    execution_schedule {
      expression = "0 ${local.stop_time_parse["minute"]} ${local.stop_time_parse["hour"]} ${local.stop_time_parse["day"]} ${local.stop_time_parse["month"]} ? ${local.stop_time_parse["year"]}"
      timezone   = "UTC"
      type       = "cron"
    }
  }

  auto_scaling_resources {
    id   = oci_core_instance_pool.agent[count.index].id
    type = "instancePool"
  }
}

# Start time - Now
resource "time_offset" "start_now" {
  count = var.start_time == "now" && local.create ? 1 : 0

  offset_months  = contains(local.start_offset, "months") ? element(local.start_offset, 0) : null
  offset_days    = contains(local.start_offset, "days") ? element(local.start_offset, 0) : null
  offset_hours   = contains(local.start_offset, "hours") ? element(local.start_offset, 0) : null
  offset_minutes = contains(local.start_offset, "minutes") ? element(local.start_offset, 0) : null
  triggers       = { version = var.time_offset_version }
}

# Stop time
resource "time_offset" "stop" {
  count = var.start_time == "watcher" || !local.create ? 0 : 1

  base_rfc3339   = var.start_time == "now" ? time_offset.start_now[count.index].rfc3339 : var.start_time
  offset_months  = contains(local.run_duration, "months") ? element(local.run_duration, 0) : null
  offset_days    = contains(local.run_duration, "days") ? element(local.run_duration, 0) : null
  offset_hours   = contains(local.run_duration, "hours") ? element(local.run_duration, 0) : null
  offset_minutes = contains(local.run_duration, "minutes") ? element(local.run_duration, 0) : null
  triggers       = { version = var.time_offset_version }
}
