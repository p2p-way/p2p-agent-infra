# Cloud init
data "cloudinit_config" "agent" {
  count = local.create ? 1 : 0

  gzip          = false
  base64_encode = false

  # Init
  part {
    filename     = "init.sh"
    content_type = "text/x-shellscript"
    content = templatefile("${path.root}/../common/files/init.sh", {
      file_path     = "${dirname(var.agent_base_folder)}/${var.agent_file}",
      cron_schedule = join(" ", concat(split(" ", var.agent_cron_schedule), [for i in range(5 - length(split(" ", var.agent_cron_schedule))) : format("%s", replace(i, "/[0-9]/", "*"))]))
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

  # P2P agent
  part {
    content_type = "text/cloud-config"
    content = yamlencode({
      write_files = concat(local.agent_file_cloudinit, local.radar_url_file_cloudinit)
    })
  }
}
