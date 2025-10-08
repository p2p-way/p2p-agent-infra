# Lambda - Watcher
resource "aws_lambda_function" "watcher" {
  count = local.watcher_create ? 1 : 0

  function_name = local.watcher_name
  description   = local.watcher_description

  s3_bucket        = aws_s3_bucket.watcher[count.index].id
  s3_key           = aws_s3_object.watcher[count.index].key
  role             = aws_iam_role.watcher[count.index].arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.9"
  architectures    = var.lambda_architecture
  source_code_hash = filebase64sha256(data.archive_file.watcher[count.index].output_path)

  environment {
    variables = {
      agent_arn = aws_autoscaling_group.agent[count.index].arn,
      active    = true
    }
  }
}

# Lambda alias - Watcher
resource "aws_lambda_alias" "watcher" {
  count = local.watcher_create ? 1 : 0

  name             = "latest"
  description      = "Latest version of ${local.watcher_name} function"
  function_name    = aws_lambda_function.watcher[count.index].function_name
  function_version = "$LATEST"
}

# Bucket suffix - Watcher
resource "random_string" "watcher" {
  count = local.watcher_create ? 1 : 0

  length  = 10
  upper   = false
  special = false
}

# Bucket - Watcher
resource "aws_s3_bucket" "watcher" {
  count = local.watcher_create ? 1 : 0

  bucket        = "${local.watcher_name}-${random_string.watcher[count.index].result}"
  force_destroy = true
}

# Archive - Watcher
data "archive_file" "watcher" {
  count = local.watcher_create ? 1 : 0

  type        = "zip"
  source_file = "${path.module}/files/${local.watcher_file}"
  output_path = "${local.watcher_file}-${local.region}.zip"
}

# Upload to S3 - Watcher
resource "aws_s3_object" "watcher" {
  count = local.watcher_create ? 1 : 0

  bucket      = aws_s3_bucket.watcher[count.index].id
  key         = "${local.watcher_file}-${local.region}.zip"
  source      = data.archive_file.watcher[count.index].output_path
  source_hash = filemd5(data.archive_file.watcher[count.index].output_path)
}

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
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "${aws_cloudwatch_log_group.watcher[count.index].arn}"
        Sid      = "CloudWatch"
      }
    ]
  })
}

# CloudWatch - Watcher
resource "aws_cloudwatch_log_group" "watcher" {
  count = local.watcher_create ? 1 : 0

  name              = "/aws/lambda/${aws_lambda_function.watcher[count.index].function_name}"
  retention_in_days = 7
}
