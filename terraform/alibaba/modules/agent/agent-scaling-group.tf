# ESS scaling group
resource "alicloud_ess_scaling_group" "agent" {
  count = local.create ? 1 : 0

  scaling_group_name = local.resource_name

  group_type = "ECS"

  launch_template_id      = alicloud_ecs_launch_template.agent[count.index].id
  launch_template_version = "Default"

  min_size         = var.initial_deploy ? 0 : var.desired_capacity
  max_size         = var.initial_deploy ? 0 : var.desired_capacity
  default_cooldown = 60

  vswitch_ids = [for vswitch in alicloud_vswitch.agent : vswitch.id]

  tags = var.default_tags

  removal_policies = ["OldestScalingConfiguration", "NewestInstance"]

  health_check_type = "ECS"

  scaling_policy = "forceRelease"

  multi_az_policy = "COMPOSABLE"
  az_balance      = true

  capacity_options_on_demand_percentage_above_base_capacity = 100

  resource_group_id = alicloud_resource_manager_resource_group.agent[count.index].id
}

# Scheduled task - Start
resource "alicloud_ess_scheduled_task" "agent_start" {
  count = var.start_time == "watcher" || !local.create ? 0 : 1

  scheduled_task_name    = "${local.resource_name}-initial-start"
  min_value              = var.desired_capacity
  max_value              = var.desired_capacity
  launch_time            = formatdate("YYYY-MM-DD'T'hh:mmZ", local.start_time)
  launch_expiration_time = 180
  scaling_group_id       = try(alicloud_ess_scaling_group.agent[count.index].id, "")
}

# Scheduled task - Stop
resource "alicloud_ess_scheduled_task" "agent_stop" {
  count = var.start_time == "watcher" || !local.create ? 0 : 1

  scheduled_task_name    = "${local.resource_name}-initial-stop"
  min_value              = 0
  max_value              = 0
  launch_time            = formatdate("YYYY-MM-DD'T'hh:mmZ", local.stop_time)
  launch_expiration_time = 180
  scaling_group_id       = try(alicloud_ess_scaling_group.agent[count.index].id, "")
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
