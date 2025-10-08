# Autoscaler
resource "google_compute_region_autoscaler" "agent" {
  count = local.create ? 1 : 0

  name   = local.autoscaler_name
  region = local.region
  target = google_compute_region_instance_group_manager.agent[count.index].id

  autoscaling_policy {
    max_replicas    = var.desired_capacity
    min_replicas    = 0
    cooldown_period = 15
    mode            = var.autoscaling_policy_mode

    scaling_schedules {
      name                  = local.autoscaler_name
      description           = title(replace(local.autoscaler_name, "-", " "))
      min_required_replicas = var.desired_capacity
      schedule              = local.start_time
      time_zone             = "Etc/UTC"
      duration_sec          = time_offset.duration[count.index].unix - time_offset.start_now[count.index].unix
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
