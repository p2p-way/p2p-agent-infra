# Saudi Arabia Central, Riyadh
module "me-riyadh-1" {
  source = "./modules/agent"

  providers = {
    oci = oci.me-riyadh-1
  }

  compartment_id           = local.compartment_id
  region                   = "me-riyadh-1"
  agent_create             = var.agent_create
  agent_name               = var.agent_name
  agent_logs               = var.agent_logs
  agent_metrics            = var.agent_metrics
  default_tags             = var.default_tags
  cidr_blocks              = var.cidr_blocks
  ad_number                = var.ad_number
  open_ports               = var.open_ports
  allow_ssh                = var.allow_ssh
  public_keys              = local.public_keys
  os_name                  = var.os_name
  instance_type            = var.instance_type
  os_volume_size           = var.os_volume_size
  os_volume_perf           = var.os_volume_perf
  initial_deploy           = var.initial_deploy
  desired_capacity         = var.desired_capacity
  enable_ipv6              = var.enable_ipv6
  start_time               = var.start_time
  start_offset             = var.start_offset
  run_duration             = var.run_duration
  time_offset_version      = var.time_offset_version
  agent_cron_schedule      = var.agent_cron_schedule
  agent_commands           = var.agent_commands
  agent_commands_defaults  = var.agent_commands_defaults
  agent_cc_hosts           = var.agent_cc_hosts
  agent_cc_commands        = var.agent_cc_commands
  agent_cc_commands_prefix = var.agent_cc_commands_prefix
  agent_repository_ssh_key = local.agent_repository_ssh_key
  radar_url                = var.radar_url
  radar_url_file           = var.radar_url_file
}
