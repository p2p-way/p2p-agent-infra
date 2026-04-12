# Autoscaler
resource "google_compute_region_autoscaler" "agent" {
  count = local.create ? 1 : 0

  name   = local.autoscaler_name
  region = local.region
  target = google_compute_region_instance_group_manager.agent[count.index].id

  autoscaling_policy {
    min_replicas    = var.start_time == "watcher" && var.initial_deploy || var.start_time != "watcher" ? 0 : var.desired_capacity
    max_replicas    = var.start_time == "watcher" && var.initial_deploy ? 0 : var.desired_capacity
    cooldown_period = 30
    mode            = "ON"

    # At least one scaling signal is auto created - adjust defaults
    dynamic "cpu_utilization" {
      for_each = var.start_time == "watcher" ? [1] : []

      content {
        target = 1
      }
    }

    dynamic "scaling_schedules" {
      for_each = var.start_time == "watcher" ? [] : [1]

      content {
        name                  = local.autoscaler_name
        description           = title(replace(local.autoscaler_name, "-", " "))
        min_required_replicas = var.desired_capacity
        schedule              = local.start_time
        time_zone             = "Etc/UTC"
        duration_sec          = try(time_offset.duration[count.index].unix, 0) - try(time_offset.start_now[count.index].unix, 0)
      }
    }
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
resource "time_offset" "duration" {
  count = var.start_time == "watcher" || !local.create ? 0 : 1

  base_rfc3339   = var.start_time == "now" ? time_offset.start_now[count.index].rfc3339 : var.start_time
  offset_months  = contains(local.run_duration, "months") ? element(local.run_duration, 0) : null
  offset_days    = contains(local.run_duration, "days") ? element(local.run_duration, 0) : null
  offset_hours   = contains(local.run_duration, "hours") ? element(local.run_duration, 0) : null
  offset_minutes = contains(local.run_duration, "minutes") ? element(local.run_duration, 0) : null
  triggers       = { version = var.time_offset_version }
}
