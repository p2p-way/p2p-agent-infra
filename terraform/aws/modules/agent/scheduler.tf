# EventBridge - Scheduler
resource "aws_scheduler_schedule" "scheduler" {
  count = local.scheduler_create ? 1 : 0

  name        = local.scheduler_name
  description = local.scheduler_description

  group_name = aws_scheduler_schedule_group.scheduler[count.index].name

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression = var.scheduler_expression

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
        Condition = {
          StringEquals = {
            "aws:SourceArn" : aws_scheduler_schedule_group.scheduler[count.index].arn
          }
        },
      },
    ]
  })
}

# IAM Policy - Scheduler
resource "aws_iam_role_policy" "scheduler" {
  count = local.scheduler_create ? 1 : 0

  name = "${local.scheduler_name}-${local.region}"
  role = aws_iam_role.scheduler[count.index].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "lambda:InvokeFunction"
        ]
        Effect   = "Allow"
        Resource = aws_lambda_function.watcher[count.index].arn
        Sid      = "Lambda"
      }
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

  region = local.region
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

  region = local.region
}
