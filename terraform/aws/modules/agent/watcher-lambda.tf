# Lambda - Watcher
resource "aws_lambda_function" "watcher" {
  count = local.watcher_create ? 1 : 0

  function_name = local.watcher_name
  description   = local.watcher_description

  s3_bucket        = aws_s3_bucket.watcher[count.index].id
  s3_key           = aws_s3_object.watcher[count.index].key
  role             = aws_iam_role.watcher[count.index].arn
  handler          = "${trimsuffix(var.watcher_file, format(".%s", element(split(".", var.watcher_file), -1)))}.lambda_handler"
  runtime          = var.watcher_runtime
  architectures    = var.lambda_architecture
  source_code_hash = filebase64sha256(data.archive_file.watcher[count.index].output_path)

  environment {
    variables = {
      agent_arn = aws_autoscaling_group.agent[count.index].arn,
      active    = true
    }
  }

  region = local.region
}

# Lambda alias - Watcher
resource "aws_lambda_alias" "watcher" {
  count = local.watcher_create ? 1 : 0

  name             = "latest"
  description      = "Latest version of ${local.watcher_name} function"
  function_name    = aws_lambda_function.watcher[count.index].function_name
  function_version = "$LATEST"

  region = local.region
}

# Lambda permission - Watcher-Scheduler
resource "aws_lambda_permission" "watcher_scheduler" {
  count = local.watcher_create && local.scheduler_create ? 1 : 0

  statement_id  = local.scheduler_name
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.watcher[count.index].function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_scheduler_schedule.scheduler[count.index].arn

  region = local.region
}

# Lambda permission - Watcher-Scheduler alias
resource "aws_lambda_permission" "watcher_scheduler_alias" {
  count = local.watcher_create && local.scheduler_create ? 1 : 0

  statement_id  = local.scheduler_name
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.watcher[count.index].function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_scheduler_schedule.scheduler[count.index].arn
  qualifier     = aws_lambda_alias.watcher[count.index].name

  region = local.region
}
