# IAM Role - Watcher
resource "aws_iam_role" "watcher" {
  count = local.watcher_create ? 1 : 0

  name        = local.watcher_name
  description = local.watcher_description

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = "AssumeRole"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

# IAM Policy - Watcher
resource "aws_iam_role_policy" "watcher" {
  count = local.watcher_create ? 1 : 0

  name = "${local.watcher_name}-${local.region}"
  role = aws_iam_role.watcher[count.index].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeScheduledActions",
        ]
        Effect   = "Allow"
        Resource = "*"
        Sid      = "AutoScalingGroups"
      },
      {
        Action = [
          "autoscaling:BatchDeleteScheduledAction",
          "autoscaling:BatchPutScheduledUpdateGroupAction",
          "autoscaling:DeleteScheduledAction",
          "autoscaling:PutScheduledUpdateGroupAction"
        ]
        Effect   = "Allow"
        Resource = "${aws_autoscaling_group.agent[count.index].arn}"
        Sid      = "AutoScalingGroup"
      },
      {
        Action = [
          "lambda:UpdateFunctionConfiguration"
        ]
        Effect   = "Allow"
        Resource = "${aws_lambda_function.watcher[count.index].arn}"
        Sid      = "LambdaFunction"
      },
      {
        Action = [
          "scheduler:UpdateSchedule"
        ]
        Effect   = "Allow"
        Resource = "${aws_scheduler_schedule.scheduler[count.index].arn}"
        Sid      = "EventBridge"
      },
      {
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "${aws_cloudwatch_log_group.watcher[count.index].arn}:*"
        Sid      = "CloudWatch"
      }
    ]
  })
}
