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
