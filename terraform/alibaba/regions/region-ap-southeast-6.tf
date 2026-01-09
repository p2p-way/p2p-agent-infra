# Philippines (Manila)
module "ap-southeast-6" {
  source = "./modules/agent"

  providers = {
    alicloud = alicloud.ap-southeast-6
  }

  agent_create                  = var.agent_create
  agent_name                    = var.agent_name
  agent_watcher                 = var.agent_watcher
  agent_logs                    = var.agent_logs
  agent_metrics                 = var.agent_metrics
  agent_open_ports              = var.agent_open_ports
  default_tags                  = var.default_tags
  cidr_block                    = var.cidr_block
  az_number                     = var.az_number
  allow_ssh                     = var.allow_ssh
  public_keys                   = local.public_keys
  os_name                       = var.os_name
  instance_type                 = var.instance_type
  instance_charge_type          = var.instance_charge_type
  internet_charge_type          = var.internet_charge_type
  internet_max_bandwidth_in     = var.internet_max_bandwidth_in
  internet_max_bandwidth_out    = var.internet_max_bandwidth_out
  system_disk_size              = var.system_disk_size
  system_disk_category          = var.system_disk_category
  system_disk_performance_level = var.system_disk_performance_level
  initial_deploy                = var.initial_deploy
  desired_capacity              = var.desired_capacity
  start_time                    = var.start_time
  start_offset                  = var.start_offset
  run_duration                  = var.run_duration
  time_offset_version           = var.time_offset_version
  agent_cron_schedule           = var.agent_cron_schedule
  agent_commands                = var.agent_commands
  agent_commands_defaults       = var.agent_commands_defaults
  agent_cc_hosts                = var.agent_cc_hosts
  agent_cc_commands             = var.agent_cc_commands
  agent_cc_commands_prefix      = var.agent_cc_commands_prefix
  agent_repository_ssh_key      = local.agent_repository_ssh_key
}
