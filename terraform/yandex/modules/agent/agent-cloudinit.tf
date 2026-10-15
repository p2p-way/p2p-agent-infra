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

  # P2P agent meta
  agent_meta_file = var.agent_meta_file

  # P2P radar
  radar_url      = var.radar_url
  radar_url_file = var.radar_url_file

  # cloud-config files
  cloud_config_files = concat(
    local.agent_logs_cloudinit_config,
    local.agent_metrics_cloudinit_config
  )

  # x-shellscript files
  shellscript_files = local.unified_agent_script
}

locals {
  # Unified Agent files
  unified_agent_init    = "unified-agent.sh"
  unified_agent_logs    = "unified-agent-logs.yml"
  unified_agent_metrics = "unified-agent-metrics.yml"

  # Unified Agent
  unified_agent_script = local.agent_logs || local.agent_metrics ? [{
    filename     = local.unified_agent_init
    content_type = "text/x-shellscript"
    content = templatefile("${path.module}/files/${local.unified_agent_init}", {
      base_folder = dirname(var.agent_base_folder)
    })
  }] : []

  # Agent logs
  agent_logs_cloudinit_config = local.agent_logs ? [{
    encoding    = "b64"
    path        = "${dirname(var.agent_base_folder)}/${local.unified_agent_logs}"
    owner       = "root:root"
    permissions = "0644"
    content = base64encode(templatefile("${path.module}/files/${local.unified_agent_logs}", {
      log_files    = local.agent_log_files,
      log_group_id = try(yandex_logging_group.agent[0].id, "")
      folder_id    = local.folder_id
    }))
  }] : []

  # Agent metrics
  agent_metrics_cloudinit_config = local.agent_metrics ? [{
    encoding    = "b64"
    path        = "${dirname(var.agent_base_folder)}/${local.unified_agent_metrics}"
    owner       = "root:root"
    permissions = "0644"
    content = base64encode(templatefile("${path.module}/files/${local.unified_agent_metrics}", {
      base_folder = var.agent_base_folder,
      log_file    = var.agent_log_file
    }))
  }] : []
}
