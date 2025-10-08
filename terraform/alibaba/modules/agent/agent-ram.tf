# RAM Role - Agent
resource "alicloud_ram_role" "agent" {
  count = local.agent_ram_create ? 1 : 0

  role_name                   = local.resource_name
  description                 = local.resource_description
  force                       = true
  assume_role_policy_document = <<EOF
  {
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Effect": "Allow",
        "Principal": {
          "Service": [
            "ecs.aliyuncs.com"
          ]
        }
      }
    ],
    "Version": "1"
  }
  EOF
}

# RAM Policy - Agent watcher
resource "alicloud_ram_policy" "agent_watcher" {
  count = local.agent_watcher ? 1 : 0

  policy_name     = "${local.resource_name}-watcher"
  description     = "${local.resource_description} - watcher policy"
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
          "ecs:DescribeInstances"
        ],
        "Effect": "Allow",
        "Resource": "acs:ecs:${local.region}:${local.account}:instance/*"
      },
      {
        "Action": [
          "ess:ModifyScalingGroup"
        ],
        "Effect": "Allow",
        "Resource": "acs:ess:${local.region}:${local.account}:scalinggroup/${alicloud_ess_scaling_group.agent[count.index].id}"
      }
    ],
      "Version": "1"
  }
  EOF
}

# RAM Role policy attachment - Agent watcher
resource "alicloud_ram_role_policy_attachment" "agent_watcher" {
  count = local.agent_watcher ? 1 : 0

  policy_name = alicloud_ram_policy.agent_watcher[count.index].policy_name
  policy_type = alicloud_ram_policy.agent_watcher[count.index].type
  role_name   = alicloud_ram_role.agent[count.index].name
}
