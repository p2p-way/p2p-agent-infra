# Locals
locals {
  create                       = var.agent_create
  agent_name                   = lower(replace(var.agent_name, " ", "-"))
  agent_watcher                = local.create && var.agent_watcher
  agent_logs                   = local.create && var.agent_logs
  agent_log_files              = ["/var/log/cloud-init.log", "/var/log/cloud-init-output.log", "/var/log/syslog", "${dirname(var.agent_base_folder)}/${var.agent_log_file}"]
  agent_metrics                = local.create && var.agent_metrics
  agent_iam_create             = local.agent_watcher || local.agent_logs || local.agent_metrics
  agent_role_name              = "${title(replace(var.agent_name, " ", ""))}${replace(title(replace(local.region, "-", " ")), " ", "")}"
  agent_role_suffix            = var.unique_iam_roles ? title(try(random_string.agent[0].result, "")) : ""
  regional_network_create      = local.create && !lookup(var.global_network, "create")
  regional_health_check_create = local.create && !lookup(var.global_health_check, "create")
  agent_open_tcp_ports         = try(element(var.agent_open_ports, 0), null)
  agent_open_udp_ports         = try(element(var.agent_open_ports, 1), null)
  create_health_check          = local.create
  create_network               = local.create
  allow_ssh                    = local.regional_network_create ? var.allow_ssh : []
  autoscaler_name              = "initial-start-stop"
  account_id                   = "${local.agent_name}-${substr(local.region, -(30 - (length(local.agent_name) + 1)), 0)}"
  resource_name                = "${local.agent_name}-${local.region}"
  resource_description         = "${var.agent_name} - ${local.region}"
  region                       = var.region
  start_time                   = "${try(time_offset.start_now[0].minute, 0)} ${try(time_offset.start_now[0].hour, 0)} ${try(time_offset.start_now[0].day, 0)} ${try(time_offset.start_now[0].month, 0)} * ${try(time_offset.start_now[0].year, 0)}"
  start_offset                 = split(" ", var.start_offset)
  run_duration                 = split(" ", var.run_duration)
  sa_scope                     = matchkeys(["compute-rw", "logging-write", "monitoring-write"], [local.agent_watcher, local.agent_logs, local.agent_metrics], ["true"])
}

# Get project
data "google_project" "agent" {
  count = local.create || local.agent_iam_create ? 1 : 0
}

# IAM Role
resource "random_string" "agent" {
  count = local.agent_iam_create ? 1 : 0

  length  = 10
  numeric = false
  upper   = false
  special = false
}
