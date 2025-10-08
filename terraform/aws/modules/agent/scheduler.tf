# EventBridge - Scheduler
resource "aws_scheduler_schedule" "scheduler" {
  count = local.scheduler_create ? 1 : 0

  name        = local.scheduler_name
  description = local.scheduler_description

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression = var.scheduler_expression

  target {
    arn      = aws_lambda_function.watcher[count.index].arn
    role_arn = aws_iam_role.scheduler[count.index].arn
  }
}

# IAM Role - Scheduler
resource "aws_iam_role" "scheduler" {
  count = local.scheduler_create ? 1 : 0

  name        = local.scheduler_name
  description = local.scheduler_description

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = "AssumeRole"
        Principal = {
          Service = "scheduler.amazonaws.com"
        }
      },
    ]
  })
}

# Lambda permission - Scheduler
resource "aws_lambda_permission" "scheduler" {
  count = local.scheduler_create ? 1 : 0

  statement_id  = local.scheduler_name
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.watcher[count.index].function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_scheduler_schedule.scheduler[count.index].arn
}

# Lambda permission - Scheduler alias
resource "aws_lambda_permission" "scheduler_alias" {
  count = local.scheduler_create ? 1 : 0

  statement_id  = local.scheduler_name
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.watcher[count.index].function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_scheduler_schedule.scheduler[count.index].arn
  qualifier     = aws_lambda_alias.watcher[count.index].name
}
