# EC2 Launch template
resource "aws_launch_template" "agent" {
  count = local.create ? 1 : 0

  # Launch template name and version description
  name = local.resource_name

  # Application and OS Images (Amazon Machine Image)
  image_id = data.aws_ami.agent[count.index].id

  # Instance type
  instance_type = var.instance_type

  # Network settings
  network_interfaces {
    associate_public_ip_address = true
    delete_on_termination       = true
    security_groups             = [aws_security_group.agent[count.index].id]
  }

  # Storage (volumes)
  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size           = var.volume_size
      volume_type           = var.volume_type
      iops                  = var.volume_iops
      throughput            = var.volume_throughput
      encrypted             = true
      delete_on_termination = true
    }
  }

  # Resource tags
  dynamic "tag_specifications" {
    for_each = var.tag_specifications

    content {
      resource_type = tag_specifications.value

      tags = merge(
        var.default_tags,
        {
          Name          = "${local.resource_name}",
          agent-watcher = "${local.agent_watcher}"
        }
      )
    }
  }

  # Advanced details
  iam_instance_profile {
    name = local.agent_iam_create ? aws_iam_instance_profile.agent[count.index].name : null
  }

  maintenance_options {
    auto_recovery = "default"
  }

  instance_initiated_shutdown_behavior = "terminate"

  disable_api_termination = false
  disable_api_stop        = false

  ebs_optimized = true

  monitoring {
    enabled = true
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  user_data = data.cloudinit_config.agent[count.index].rendered

  # Other
  update_default_version = true

  # Region
  region = local.region
}
