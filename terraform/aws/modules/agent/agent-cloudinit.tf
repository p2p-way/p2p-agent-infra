# Cloud init
data "cloudinit_config" "agent" {
  count = local.create ? 1 : 0

  gzip          = true
  base64_encode = true

  # Init
  part {
    filename     = "init.sh"
    content_type = "text/x-shellscript"
    content = templatefile("${path.root}/../common/files/init.sh", {
      file_path     = "${dirname(var.agent_base_folder)}/${var.agent_file}",
      cron_schedule = join(" ", concat(split(" ", var.agent_cron_schedule), [for i in range(5 - length(split(" ", var.agent_cron_schedule))) : format("%s", replace(i, "/[0-9]/", "*"))]))
    })
  }

  # SSH - Agent
  part {
    filename     = "ssh-agent.yaml"
    content_type = "text/cloud-config"
    content = templatefile("${path.root}/../common/files/ssh-agent.yaml", {
      public_keys = var.public_keys
    })
  }

  # SSH - Repository
  part {
    filename     = "ssh-repository.sh"
    content_type = "text/x-shellscript"
    content = templatefile("${path.root}/../common/files/ssh-repository.sh", {
      ssh_private_key = var.agent_repository_ssh_key
    })
  }

  # CloudWatch agent
  dynamic "part" {
    for_each = local.agent_logs || local.agent_metrics ? [1] : []

    content {
      filename     = "01-cloudwatch-agent.sh"
      content_type = "text/x-shellscript"
      content = templatefile("${path.module}/files/cloudwatch-agent.sh", {
        base_folder = dirname(var.agent_base_folder)
      })
    }
  }

  # P2P agent
  part {
    content_type = "text/cloud-config"
    content = yamlencode({
      write_files = concat(
        local.agent_file_cloudinit,
        local.radar_url_file_cloudinit,
        local.agent_logs_cloudinit,
        local.agent_metrics_cloudinit
      )
    })
  }
}
