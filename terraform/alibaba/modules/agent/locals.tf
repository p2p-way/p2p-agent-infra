# https://registry.terraform.io/providers/aliyun/alicloud/latest

# Locals
locals {
  create                        = var.agent_create
  agent_name                    = lower(replace(var.agent_name, " ", "-"))
  agent_watcher                 = local.create && var.agent_watcher
  agent_logs                    = local.create && var.agent_logs
  agent_log_files               = ["/var/log/cloud-init.log", "/var/log/cloud-init-output.log", "/var/log/syslog", "${dirname(var.agent_base_folder)}/${var.agent_log_file}"]
  agent_metrics                 = local.create && var.agent_metrics
  agent_ram_create              = local.agent_watcher
  agent_p2p_archivist_tcp_ports = try(element(var.agent_p2p_archivist_ports, 0), null)
  agent_p2p_archivist_udp_ports = try(element(var.agent_p2p_archivist_ports, 1), null)
  agent_p2p_ipfs_tcp_ports      = try(element(var.agent_p2p_ipfs_ports, 0), null)
  agent_p2p_ipfs_udp_ports      = try(element(var.agent_p2p_ipfs_ports, 1), null)
  agent_p2p_radicle_tcp_ports   = try(element(var.agent_p2p_radicle_ports, 0), null)
  agent_p2p_radicle_udp_ports   = try(element(var.agent_p2p_radicle_ports, 1), null)
  agent_p2p_ton_tcp_ports       = try(element(var.agent_p2p_ton_ports, 0), null)
  agent_p2p_ton_udp_ports       = try(element(var.agent_p2p_ton_ports, 1), null)
  agent_p2p_torrent_tcp_ports   = try(element(var.agent_p2p_torrent_ports, 0), null)
  agent_p2p_torrent_udp_ports   = try(element(var.agent_p2p_torrent_ports, 1), null)
  agent_custom_tcp_ports        = try(element(var.agent_custom_ports, 0), null)
  agent_custom_udp_ports        = try(element(var.agent_custom_ports, 1), null)
  allow_ssh                     = local.create ? var.allow_ssh : []
  account                       = try(data.alicloud_account.current[0].id, "")
  resource_name                 = "${local.agent_name}-${local.region}"
  resource_description          = "${var.agent_name} - ${local.region_description}"
  region                        = try(data.alicloud_regions.current[0].regions.0.id, "")
  region_description            = try(data.alicloud_regions.current[0].regions.0.id, "")
  start_time                    = var.start_time == "now" ? try(time_offset.start_now[0].rfc3339, "") : var.start_time
  stop_time                     = try(time_offset.stop[0].rfc3339, "")
  start_offset                  = split(" ", var.start_offset)
  run_duration                  = split(" ", var.run_duration)
  az_names                      = try(data.alicloud_zones.agent[0].ids, [])
  az_list                       = [for az in slice(local.az_names, 0, local.az_number) : az]
  az_number                     = local.az_available < var.az_number ? local.az_available : var.az_number
  az_available                  = length(local.az_names)
  subnet_newbits_max            = 29 - element(split("/", var.cidr_block), -1)
  subnet_newbits                = local.az_number > local.subnet_newbits_max ? local.subnet_newbits_max : local.az_number - 1
}

# Account
data "alicloud_account" "current" {
  count = local.create ? 1 : 0
}

# Region
data "alicloud_regions" "current" {
  count = local.create ? 1 : 0

  current = true
}
