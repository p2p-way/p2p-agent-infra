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

  # Ops Agent
  dynamic "part" {
    for_each = local.agent_logs || local.agent_metrics ? [1] : []
    content {
      filename     = "01-ops-agent.sh"
      content_type = "text/x-shellscript"
      content = templatefile("${path.module}/files/ops-agent.sh", {
        base_folder = dirname(var.agent_base_folder)
      })
    }
  }

  # P2P agent
  dynamic "part" {
    for_each = local.agent_logs && local.agent_metrics ? [] : [1]
    content {
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
          }
        ]
      })
    }
  }

  # P2P agent and logs
  dynamic "part" {
    for_each = local.agent_logs ? [1] : []
    content {
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
            encoding = "b64"
            content = base64encode(templatefile("${path.module}/files/ops-agent-logs.yaml", {
              log_files = local.agent_log_files
            }))
            path        = "${dirname(var.agent_base_folder)}/ops-agent-logs.yaml"
            owner       = "root:root"
            permissions = "0644"
          },
          {
            encoding    = "b64"
            content     = base64encode(file("${path.module}/files/ops-agent-metrics-disable.yaml"))
            path        = "${dirname(var.agent_base_folder)}/ops-agent-metrics-disable.yaml"
            owner       = "root:root"
            permissions = "0644"
          }
        ]
      })
    }
  }

  # P2P agent and metrics
  dynamic "part" {
    for_each = local.agent_metrics ? [1] : []
    content {
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
            content     = base64encode(file("${path.module}/files/ops-agent-metrics.yaml"))
            path        = "${dirname(var.agent_base_folder)}/ops-agent-metrics.yaml"
            owner       = "root:root"
            permissions = "0644"
          },
          {
            encoding    = "b64"
            content     = base64encode(file("${path.module}/files/ops-agent-logs-disable.yaml"))
            path        = "${dirname(var.agent_base_folder)}/ops-agent-logs-disable.yaml"
            owner       = "root:root"
            permissions = "0644"
          }
        ]
      })
    }
  }

  # P2P agent, logs and metrics
  dynamic "part" {
    for_each = local.agent_logs && local.agent_metrics ? [1] : []
    content {
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
            encoding = "b64"
            content = base64encode(templatefile("${path.module}/files/ops-agent-logs.yaml", {
              log_files = local.agent_log_files
            }))
            path        = "${dirname(var.agent_base_folder)}/ops-agent-logs.yaml"
            owner       = "root:root"
            permissions = "0644"
          },
          {
            encoding    = "b64"
            content     = base64encode(file("${path.module}/files/ops-agent-metrics.yaml"))
            path        = "${dirname(var.agent_base_folder)}/ops-agent-metrics.yaml"
            owner       = "root:root"
            permissions = "0644"
          }
        ]
      })
    }
  }
}
