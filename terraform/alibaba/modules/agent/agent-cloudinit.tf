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

  # x-shellscript files
  shellscript_files = concat(
    local.cloudmonitor_agent_script,
    local.logtail_script
  )
}

locals {
  # Files
  cloudmonitor_agent_init = "cloudmonitor-agent.sh"
  logtail_init            = "logtail.sh"

  # CloudMonitor agent
  cloudmonitor_agent_script = local.agent_metrics ? [{
    filename     = local.cloudmonitor_agent_init
    content_type = "text/x-shellscript"
    content = templatefile("${path.module}/files/${local.cloudmonitor_agent_init}", {
      base_folder = dirname(var.agent_base_folder),
      region      = local.region
    })
  }] : []

  # Logtail agent
  logtail_script = local.agent_logs ? [{
    filename     = local.logtail_init
    content_type = "text/x-shellscript"
    content = templatefile("${path.module}/files/${local.logtail_init}", {
      region          = local.region,
      user_defined_id = alicloud_log_project.common[0].project_name
    })
  }] : []
}
