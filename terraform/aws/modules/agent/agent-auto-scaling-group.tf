# Auto Scaling group
resource "aws_autoscaling_group" "agent" {
  count = local.create ? 1 : 0

  name             = local.resource_name
  desired_capacity = var.initial_deploy ? 0 : var.desired_capacity
  max_size         = var.initial_deploy ? 0 : var.desired_capacity
  min_size         = var.initial_deploy ? 0 : var.desired_capacity

  vpc_zone_identifier = [for subnet in aws_subnet.agent : subnet.id]

  launch_template {
    id      = aws_launch_template.agent[count.index].id
    version = "$Default"
  }

  region = local.region
}

# Scheduled scaling - Start
resource "aws_autoscaling_schedule" "agent_start" {
  count = var.start_time == "watcher" || !var.initial_deploy || !local.create ? 0 : 1

  scheduled_action_name  = "initial-start"
  min_size               = var.desired_capacity
  max_size               = var.desired_capacity
  desired_capacity       = var.desired_capacity
  start_time             = local.start_time
  autoscaling_group_name = try(aws_autoscaling_group.agent[count.index].name, "")

  region = local.region
}

# Scheduled scaling - Stop
resource "aws_autoscaling_schedule" "agent_stop" {
  count = var.start_time == "watcher" || !local.create ? 0 : 1

  scheduled_action_name  = "initial-stop"
  min_size               = 0
  max_size               = 0
  desired_capacity       = 0
  start_time             = local.stop_time
  autoscaling_group_name = try(aws_autoscaling_group.agent[count.index].name, "")

  region = local.region
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
