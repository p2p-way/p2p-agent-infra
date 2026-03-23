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
  architectures    = var.watcher_architecture
  source_code_hash = filebase64sha256(data.archive_file.watcher[count.index].output_path)

  environment {
    variables = {
      cloud                = var.default_tags["Cloud"]
      region               = var.region,
      cc_hosts             = join(" ", var.agent_cc_hosts),
      agent_name           = aws_autoscaling_group.agent[count.index].name
      agent_prefix         = var.watcher_cc_agent_prefix,
      scheduler_name       = local.scheduler_name
      scheduler_prefix     = var.watcher_cc_scheduler_prefix,
      scheduler_group_name = aws_scheduler_schedule_group.scheduler[count.index].name
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

# Lambda URL - Watcher (development/debug)
resource "aws_lambda_function_url" "watcher" {
  count = local.watcher_create && false ? 1 : 0

  function_name      = aws_lambda_function.watcher[count.index].function_name
  authorization_type = "NONE"

  region = local.region
}
