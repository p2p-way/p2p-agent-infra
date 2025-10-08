# Cloud init
data "cloudinit_config" "agent" {
  count = local.create ? 1 : 0

  gzip          = true
  base64_encode = true

  # Netplan init
  part {
    filename     = "01-netplan-init.sh"
    content_type = "text/x-shellscript"
    content = templatefile("${path.module}/files/netplan-init.sh", {
      base_folder = dirname(var.agent_base_folder),
      file_path   = "${dirname(var.agent_base_folder)}/${var.agent_file}"
    })
  }

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
      write_files = [
        {
          encoding = "b64"
          content = base64encode(templatefile("${path.root}/../common/files/${var.agent_file}", {
            base_folder        = var.agent_base_folder,
            log_file           = var.agent_log_file,
            commands           = var.agent_commands,
            commands_defaults  = var.agent_commands_defaults,
            cc_hosts           = var.agent_cc_hosts,
            cc_commands        = var.agent_cc_commands,
            cc_commands_prefix = var.agent_cc_commands_prefix
          }))
          path        = "${dirname(var.agent_base_folder)}/${var.agent_file}"
          owner       = "root:root"
          permissions = "0755"
        },
        {
          encoding    = "b64"
          content     = base64encode(file("${path.module}/files/netplan-routes.yaml"))
          path        = "${dirname(var.agent_base_folder)}/netplan-routes.yaml"
          owner       = "root:root"
          permissions = "0600"
        }
      ]
    })
  }
}
