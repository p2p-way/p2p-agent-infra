# Cloudinit
module "cloudinit" {
  source = abspath("${path.root}/../common/modules/cloudinit")

  count = local.create ? 1 : 0

  gzip          = false
  base64_encode = false

  # Init
  agent_cron_schedule = var.agent_cron_schedule

  # SSH - Agent
  public_keys = var.public_keys

  # SSH - Repository
  agent_repository_ssh_key = var.agent_repository_ssh_key

  # P2P agent
  agent_base_folder        = var.agent_base_folder
  agent_file               = var.agent_file
  agent_log_file           = var.agent_log_file
  agent_commands           = var.agent_commands
  agent_commands_defaults  = var.agent_commands_defaults
  agent_cc_hosts           = var.agent_cc_hosts
  agent_cc_commands        = var.agent_cc_commands
  agent_cc_commands_prefix = var.agent_cc_commands_prefix

  # P2P radar
  radar_url      = var.radar_url
  radar_url_file = var.radar_url_file

  # cloud-config files
  cloud_config_files = concat(
    local.agent_logs_cloudinit_config,
    local.agent_logs_disable_cloudinit_config,
    local.agent_metrics_cloudinit_config,
    local.agent_metrics_disable_cloudinit_config
  )

  # x-shellscript files
  shellscript_files = local.ops_agent_script
}

locals {
  # Ops Agent files
  ops_agent_init            = "ops-agent.sh"
  ops_agent_logs            = "ops-agent-logs.yaml"
  ops_agent_logs_disable    = "ops-agent-logs-disable.yaml"
  ops_agent_metrics         = "ops-agent-metrics.yaml"
  ops_agent_metrics_disable = "ops-agent-metrics-disable.yaml"

  # Ops Agent
  ops_agent_script = local.agent_logs || local.agent_metrics ? [{
    filename     = local.ops_agent_init
    content_type = "text/x-shellscript"
    content = templatefile("${path.module}/files/${local.ops_agent_init}", {
      base_folder = dirname(var.agent_base_folder)
    })
  }] : []

  # Agent logs
  agent_logs_cloudinit_config = local.agent_logs ? [{
    encoding    = "b64"
    path        = "${dirname(var.agent_base_folder)}/${local.ops_agent_logs}"
    owner       = "root:root"
    permissions = "0644"
    content = base64encode(templatefile("${path.module}/files/${local.ops_agent_logs}", {
      log_files = local.agent_log_files
    }))
  }] : []

  # Agent logs - disable
  agent_logs_disable_cloudinit_config = !local.agent_logs ? [{
    encoding    = "b64"
    path        = "${dirname(var.agent_base_folder)}/${local.ops_agent_logs_disable}"
    owner       = "root:root"
    permissions = "0644"
    content     = base64encode(file("${path.module}/files/${local.ops_agent_logs_disable}"))
  }] : []

  # Agent metrics
  agent_metrics_cloudinit_config = local.agent_metrics ? [{
    encoding    = "b64"
    path        = "${dirname(var.agent_base_folder)}/${local.ops_agent_metrics}"
    owner       = "root:root"
    permissions = "0644"
    content     = base64encode(file("${path.module}/files/${local.ops_agent_metrics}"))
  }] : []

  # Agent metrics - disable
  agent_metrics_disable_cloudinit_config = !local.agent_metrics ? [{
    encoding    = "b64"
    path        = "${dirname(var.agent_base_folder)}/${local.ops_agent_metrics_disable}"
    owner       = "root:root"
    permissions = "0644"
    content     = base64encode(file("${path.module}/files/${local.ops_agent_metrics_disable}"))
  }] : []
}
