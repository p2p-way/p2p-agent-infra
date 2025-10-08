# WAFv2 Web ACL - Control center
resource "aws_wafv2_web_acl" "cc" {
  count = local.waf_create ? 1 : 0

  name        = local.name
  description = local.description
  scope       = "CLOUDFRONT"

  default_action {
    allow {}
  }

  rule {
    name     = "rate-based-limit-by-ip"
    priority = 1

    action {
      captcha {
        custom_request_handling {
          insert_header {
            name  = "test"
            value = "test"
          }
        }
      }
    }

    statement {
      rate_based_statement {
        limit              = 1000
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "rate-based-limit-by-ip"
      sampled_requests_enabled   = false
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "rate-based-limit-by-ip"
    sampled_requests_enabled   = false
  }

  lifecycle {
    create_before_destroy = true
  }
}

# WAFv2 Web ACL Logging
resource "aws_wafv2_web_acl_logging_configuration" "common" {
  count = local.waf_logs_enable ? 1 : 0

  log_destination_configs = [aws_cloudwatch_log_group.waf[count.index].arn]
  resource_arn            = aws_wafv2_web_acl.cc[count.index].arn

  logging_filter {
    default_behavior = "DROP"

    filter {
      behavior = "KEEP"

      condition {
        action_condition {
          action = "CAPTCHA"
        }
      }

      requirement = "MEETS_ALL"
    }
  }
}

# CloudWatch
resource "aws_cloudwatch_log_group" "waf" {
  count = local.waf_logs_enable ? 1 : 0

  name              = "aws-waf-logs-${local.name}"
  retention_in_days = 7
}
