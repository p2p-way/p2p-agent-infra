# Cloudinit
data "cloudinit_config" "agent" {
  # Main
  gzip          = var.gzip
  base64_encode = var.base64_encode

  # Init
  part {
    filename     = "init.sh"
    content_type = "text/x-shellscript"
    content = templatefile("${path.module}/files/init.sh", {
      file_path     = "${dirname(var.agent_base_folder)}/${var.agent_file}"
      cron_schedule = join(" ", concat(split(" ", var.agent_cron_schedule), [for i in range(5 - length(split(" ", var.agent_cron_schedule))) : format("%s", replace(i, "/[0-9]/", "*"))]))
    })
  }

  # SSH - Agent
  dynamic "part" {
    for_each = length(var.public_keys) > 0 ? [1] : []

    content {
      filename     = "ssh-agent.yaml"
      content_type = "text/cloud-config"
      content = templatefile("${path.module}/files/ssh-agent.yaml", {
        public_keys = var.public_keys
      })
    }
  }

  # SSH - Repository
  part {
    filename     = "ssh-repository.sh"
    content_type = "text/x-shellscript"
    content = templatefile("${path.module}/files/ssh-repository.sh", {
      ssh_private_key = var.agent_repository_ssh_key
    })
  }

  # cloud-config files
  part {
    content_type = "text/cloud-config"
    content = yamlencode({
      write_files = concat(
        local.agent_file_cloudinit_config,
        local.agent_meta_file_cloudinit_config,
        local.radar_url_file_cloudinit_config,
        var.cloud_config_files
      )
    })
  }

  # x-shellscript files
  dynamic "part" {
    for_each = var.shellscript_files

    content {
      filename     = lookup(part.value, "filename")
      content_type = "text/x-shellscript"
      content      = lookup(part.value, "content")
    }
  }
}
