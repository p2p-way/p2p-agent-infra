# Cloudinit
module "cloudinit" {
  source = abspath("${path.root}/../common/modules/cloudinit")

  count = local.create ? 1 : 0

  gzip          = true
  base64_encode = true

  # Init
  agent_cron_schedule = var.agent_cron_schedule

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
  cloud_config_files = local.netplan_routes_cloudinit_config

  # x-shellscript files
  shellscript_files = local.netplan_script
}

locals {
  # Netplan files
  netplan_init   = "netplan-init.sh"
  netplan_routes = "netplan-routes.yaml"

  # Netplan init
  netplan_script = [{
    filename     = local.netplan_init
    content_type = "text/x-shellscript"
    content = templatefile("${path.module}/files/${local.netplan_init}", {
      base_folder = dirname(var.agent_base_folder)
    })
  }]

  # Netplan routes
  netplan_routes_cloudinit_config = [{
    encoding    = "b64"
    path        = "${dirname(var.agent_base_folder)}/${local.netplan_routes}"
    owner       = "root:root"
    permissions = "0600"
    content     = base64encode(file("${path.module}/files/${local.netplan_routes}"))
  }]
}
