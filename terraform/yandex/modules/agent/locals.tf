# Locals
locals {
  create                 = var.agent_create
  folder_id              = var.folder_id
  agent_name             = lower(replace(var.agent_name, " ", "-"))
  agent_watcher          = local.create && var.agent_watcher
  agent_logs             = local.create && var.agent_logs
  agent_log_files        = ["/var/log/cloud-init.log", "/var/log/cloud-init-output.log", "/var/log/syslog", "${dirname(var.agent_base_folder)}/${var.agent_log_file}"]
  agent_metrics          = local.create && var.agent_metrics
  agent_iam_create       = var.agent_create
  watcher_create         = var.start_time == "watcher" && local.create
  watcher_name           = "${lower(replace(var.watcher_name, " ", "-"))}-${var.region}"
  watcher_description    = "${var.watcher_name} - ${var.region}"
  watcher_debug          = false
  scheduler_create       = local.watcher_create
  scheduler_name         = "${lower(replace(var.scheduler_name, " ", "-"))}-${var.region}"
  scheduler_description  = "${var.scheduler_name} - ${var.region}"
  open_tcp_ports         = try(element(var.open_ports, 0), "")
  open_udp_ports         = try(element(var.open_ports, 1), "")
  allow_ssh              = local.create ? var.allow_ssh : []
  resource_name          = "${local.agent_name}-${var.region}"
  resource_description   = "${var.agent_name} - ${var.region}"
  az_list                = local.create ? formatlist("${var.region}-%s", var.az_list) : []
  az_number              = length(local.az_list)
  subnet_newbits_max     = 28 - element(split("/", var.cidr_block), -1)
  subnet_newbits         = local.az_number > local.subnet_newbits_max ? local.subnet_newbits_max : local.az_number - 1
  default_labels         = { for k, v in var.default_labels : lower(k) => replace(lower(v), " ", "-") }
  instance_type_split    = split(":", var.instance_type)
  instance_type          = length(local.instance_type_split) > 1 ? element(local.instance_type_split, 0) : var.instance_type
  instance_cores         = length(local.instance_type_split) > 1 ? element(local.instance_type_split, 1) : 2
  instance_memory        = length(local.instance_type_split) > 1 ? element(local.instance_type_split, 2) : 1
  instance_core_fraction = length(local.instance_type_split) > 1 ? element(local.instance_type_split, 3) : 20

  scheduler_expression_map = {
    minutes = "*/${local.scheduler_expression_value} * * * ? *"
    hours   = "0 */${local.scheduler_expression_value} * * ? *"
    days    = "0 0 */${local.scheduler_expression_value} * ? *"
  }
  scheduler_expression_value = element(split(" ", var.scheduler_expression), 0)
  scheduler_expression_units = element(split(" ", var.scheduler_expression), 1)
  scheduler_expression       = lookup(local.scheduler_expression_map, local.scheduler_expression_units)
}
