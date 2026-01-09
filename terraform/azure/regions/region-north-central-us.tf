#  North Central US - Illinois
module "north-central-us" {
  source = "./modules/agent"

  region                   = "North Central US"
  agent_create             = var.agent_create
  agent_name               = var.agent_name
  agent_watcher            = var.agent_watcher
  agent_logs               = var.agent_logs
  agent_metrics            = var.agent_metrics
  agent_logs_retention     = var.agent_logs_retention
  agent_open_ports         = var.agent_open_ports
  default_tags             = var.default_tags
  address_space            = var.address_space
  address_prefixes         = var.address_prefixes
  allow_ssh                = var.allow_ssh
  public_keys              = local.public_keys
  admin_username           = var.admin_username
  zone                     = [] # var.zone
  sku                      = var.sku
  os_name                  = var.os_name
  os_disk_size_gb          = var.os_disk_size_gb
  os_storage_account_type  = var.os_storage_account_type
  os_caching               = var.os_caching
  initial_deploy           = var.initial_deploy
  desired_capacity         = var.desired_capacity
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
}
