# CloudWatch - Watcher
resource "aws_cloudwatch_log_group" "watcher" {
  count = local.watcher_create ? 1 : 0

  name              = "/aws/lambda/${aws_lambda_function.watcher[count.index].function_name}"
  retention_in_days = 7

  region = local.region
}
