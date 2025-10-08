# IAM Role - Agent
resource "aws_iam_role" "agent" {
  count = local.agent_iam_create ? 1 : 0

  name        = local.resource_name
  description = local.resource_description
  path        = "/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

# IAM Instance Profile - Agent
resource "aws_iam_instance_profile" "agent" {
  count = local.agent_iam_create ? 1 : 0

  name = local.resource_name
  role = aws_iam_role.agent[count.index].name
}

# IAM Policy - Agent watcher
resource "aws_iam_role_policy" "agent_watcher" {
  count = local.agent_watcher ? 1 : 0

  name = "watcher"
  role = aws_iam_role.agent[count.index].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "autoscaling:DescribeScheduledActions"
        ]
        Effect   = "Allow"
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:RequestedRegion" = "${local.region}"
          }
        }
      },
      {
        Action = [
          "autoscaling:UpdateAutoScalingGroup"
        ]
        Effect   = "Allow"
        Resource = "${aws_autoscaling_group.agent[count.index].arn}"
      }
    ]
  })
}

# IAM Policy - Cloud logs
resource "aws_iam_role_policy" "agent_logs" {
  count = local.agent_logs ? 1 : 0

  name = "logs"
  role = aws_iam_role.agent[count.index].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:PutLogEvents",
          "logs:CreateLogStream",
        ]
        Effect   = "Allow"
        Resource = "${aws_cloudwatch_log_group.agent[count.index].arn}:*"
      }
    ]
  })
}

# IAM Policy - Cloud metrics
resource "aws_iam_role_policy" "agent_metrics" {
  count = local.agent_metrics ? 1 : 0

  name = "metrics"
  role = aws_iam_role.agent[count.index].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "cloudwatch:PutMetricData"
        ]
        Effect   = "Allow"
        Resource = "*"
        Condition = {
          StringEquals = {
            "cloudwatch:namespace" = "CWAgent"
          }
        }
      },
      {
        Action = [
          "ec2:DescribeTags"
        ]
        Effect   = "Allow"
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:RequestedRegion" = "${local.region}"
          }
        }
      }
    ]
  })
}
