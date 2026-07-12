# Kazakhstan
module "kz1" {
  source = "./modules/agent"

  providers = {
    yandex = yandex.kz1
  }

  folder_id                   = var.folder_id
  region                      = "kz1"
  agent_create                = var.agent_create
  agent_name                  = var.agent_name
  agent_watcher               = var.agent_watcher
  agent_logs                  = var.agent_logs
  agent_metrics               = var.agent_metrics
  agent_logs_retention        = var.agent_logs_retention
  default_labels              = var.default_labels
  cidr_block                  = var.cidr_block
  az_list                     = ["a"]
  open_ports                  = var.open_ports
  allow_ssh                   = var.allow_ssh
  public_keys                 = local.public_keys
  os_name                     = var.os_name
  instance_type               = var.instance_type
  os_volume_type              = var.os_volume_type
  os_volume_size              = var.os_volume_size
  desired_capacity            = var.desired_capacity
  start_time                  = var.start_time
  enable_ipv6                 = var.enable_ipv6
  agent_cron_schedule         = var.agent_cron_schedule
  agent_commands              = var.agent_commands
  agent_commands_defaults     = var.agent_commands_defaults
  agent_cc_hosts              = var.agent_cc_hosts
  agent_cc_commands           = var.agent_cc_commands
  agent_cc_commands_prefix    = var.agent_cc_commands_prefix
  agent_repository_ssh_key    = local.agent_repository_ssh_key
  watcher_name                = var.watcher_name
  watcher_file                = var.watcher_file
  watcher_runtime             = var.watcher_runtime
  watcher_cc_agent_prefix     = var.watcher_cc_agent_prefix
  watcher_cc_scheduler_prefix = var.watcher_cc_scheduler_prefix
  scheduler_name              = var.scheduler_name
  scheduler_expression        = var.scheduler_expression
  radar_url                   = var.radar_url
  radar_url_file              = var.radar_url_file
}
