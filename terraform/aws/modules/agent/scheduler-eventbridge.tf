# EventBridge - Scheduler
resource "aws_scheduler_schedule" "scheduler" {
  count = local.scheduler_create ? 1 : 0

  name        = local.scheduler_name
  description = local.scheduler_description

  group_name = aws_scheduler_schedule_group.scheduler[count.index].name

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression = "rate(${var.scheduler_expression})"

  target {
    arn      = aws_lambda_function.watcher[count.index].arn
    role_arn = aws_iam_role.scheduler[count.index].arn
    retry_policy {
      maximum_event_age_in_seconds = 60
      maximum_retry_attempts       = 0
    }
  }

  region = local.region
}

# EventBridge - Scheduler group
resource "aws_scheduler_schedule_group" "scheduler" {
  count = local.scheduler_create ? 1 : 0

  name = local.scheduler_name

  region = local.region
}
