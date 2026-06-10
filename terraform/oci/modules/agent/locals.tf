# Locals
locals {
  create               = var.agent_create
  compartment_id       = var.compartment_id
  agent_name           = lower(replace(var.agent_name, " ", "-"))
  agent_logs           = local.create && var.agent_logs
  agent_log_files      = ["/var/log/cloud-init.log", "/var/log/cloud-init-output.log", "/var/log/syslog", "${dirname(var.agent_base_folder)}/${var.agent_log_file}"]
  agent_metrics        = local.create && var.agent_metrics
  open_tcp_ports       = try(element(var.open_ports, 0), "")
  open_udp_ports       = try(element(var.open_ports, 1), "")
  allow_ssh            = local.create ? var.allow_ssh : []
  resource_name        = "${local.agent_name}-${local.region}"
  resource_description = "${var.agent_name} - ${local.region_description}"
  region               = var.region
  region_description   = local.region
  start_time           = var.start_time == "now" ? try(time_offset.start_now[0].rfc3339, "") : var.start_time
  start_time_parse     = try(provider::time::rfc3339_parse(local.start_time), "")
  stop_time            = try(time_offset.stop[0].rfc3339, "")
  stop_time_parse      = try(provider::time::rfc3339_parse(local.stop_time), "")
  start_offset         = split(" ", var.start_offset)
  run_duration         = split(" ", var.run_duration)
  ad_names             = try(data.oci_identity_availability_domains.current[0].availability_domains[*].name, "")
  ad_list              = try(slice(local.ad_names, 0, local.ad_number), "")
  ad_number            = local.ad_available < var.ad_number ? local.ad_available : var.ad_number
  ad_available         = length(local.ad_names)
  freeform_tags        = merge(var.default_tags, { Region = local.region })
  instance_type_split  = split(":", var.instance_type)
  instance_type        = length(local.instance_type_split) > 1 ? element(local.instance_type_split, 0) : var.instance_type
  instance_ocpus       = length(local.instance_type_split) > 1 ? element(local.instance_type_split, 1) : 1
  instance_memory      = length(local.instance_type_split) > 1 ? element(local.instance_type_split, 2) : 1
}
