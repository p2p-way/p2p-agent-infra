# Cloudinit
module "cloudinit" {
  source = abspath("${path.root}/../common/modules/cloudinit")

  count = local.create ? 1 : 0

  gzip          = true
  base64_encode = true

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
    local.agent_metrics_cloudinit_config
  )

  # x-shellscript files
  shellscript_files = local.cloudwatch_agent_script
}

locals {
  # CloudWatch agent files
  cloudwatch_agent_init = "cloudwatch-agent.sh"
  cloudwatch_logs       = "cloudwatch-logs.json"
  cloudwatch_metrics    = "cloudwatch-metrics.json"

  # CloudWatch agent
  cloudwatch_agent_script = local.agent_logs || local.agent_metrics ? [{
    filename     = local.cloudwatch_agent_init
    content_type = "text/x-shellscript"
    content = templatefile("${path.module}/files/${local.cloudwatch_agent_init}", {
      base_folder = dirname(var.agent_base_folder)
    })
  }] : []

  # Agent logs
  agent_logs_cloudinit_config = local.agent_logs ? [{
    encoding    = "b64"
    path        = "${dirname(var.agent_base_folder)}/${local.cloudwatch_logs}"
    owner       = "root:root"
    permissions = "0644"
    content = base64encode(templatefile("${path.module}/files/${local.cloudwatch_logs}", {
      log_files = local.agent_log_files,
      log_group = try(aws_cloudwatch_log_group.agent[0].name, "")
    }))
  }] : []

  # Agent metrics
  agent_metrics_cloudinit_config = local.agent_metrics ? [{
    encoding    = "b64"
    path        = "${dirname(var.agent_base_folder)}/${local.cloudwatch_metrics}"
    owner       = "root:root"
    permissions = "0644"
    content     = filebase64("${path.module}/files/${local.cloudwatch_metrics}")
  }] : []
}
