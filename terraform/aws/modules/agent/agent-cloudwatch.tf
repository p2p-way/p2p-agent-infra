# CloudWatch Log Group - Agent
resource "aws_cloudwatch_log_group" "agent" {
  count = local.agent_logs ? 1 : 0

  name              = local.resource_name
  retention_in_days = var.agent_logs_retention

  region = local.region
}
