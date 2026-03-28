# RAM Role - Watcher
resource "alicloud_ram_role" "watcher" {
  count = local.watcher_create ? 1 : 0

  role_name                   = local.role_random_suffix ? "${local.watcher_name}-${random_string.role_suffix[count.index].result}" : local.watcher_name
  description                 = local.watcher_description
  force                       = true
  assume_role_policy_document = <<EOF
  {
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Effect": "Allow",
        "Principal": {
          "Service": [
            "fc.aliyuncs.com"
          ]
        }
      }
    ],
    "Version": "1"
  }
  EOF
}

# RAM Policy - Watcher
resource "alicloud_ram_policy" "watcher" {
  count = local.watcher_create ? 1 : 0

  policy_name     = "${local.watcher_name}-watcher"
  description     = "${local.watcher_description} - watcher policy"
  rotate_strategy = "DeleteOldestNonDefaultVersionWhenLimitExceeded"
  force           = true
  policy_document = <<EOF
  {
    "Statement": [
      {
        "Action": [
          "ess:DescribeScheduledTasks"
        ],
        "Effect": "Allow",
        "Resource": "*"
      },
      {
        "Action": [
          "ess:DescribeScalingGroups"
        ],
        "Effect": "Allow",
        "Resource": "*"
      },
      {
        "Action": [
          "ess:ModifyScalingGroup"
        ],
        "Effect": "Allow",
        "Resource": "acs:ess:${local.region}:${local.account}:scalinggroup/${alicloud_ess_scaling_group.agent[count.index].id}"
      },
      {
        "Effect": "Allow",
        "Action": "fc:GetTrigger",
        "Resource": "*"
      },
      {
        "Effect": "Allow",
        "Action": "fc:UpdateTrigger",
        "Resource": "acs:fc:${local.region}:${local.account}:functions/${alicloud_fcv3_function.watcher[count.index].id}/triggers/${local.scheduler_name}"
      }
    ],
      "Version": "1"
  }
  EOF
}

# RAM Role policy attachment - Watcher
resource "alicloud_ram_role_policy_attachment" "watcher" {
  count = local.watcher_create ? 1 : 0

  policy_name = alicloud_ram_policy.watcher[count.index].policy_name
  policy_type = alicloud_ram_policy.watcher[count.index].type
  role_name   = alicloud_ram_role.watcher[count.index].name
}
