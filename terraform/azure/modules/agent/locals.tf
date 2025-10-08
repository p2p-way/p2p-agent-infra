# Locals
locals {
  create                        = var.agent_create
  agent_name                    = lower(replace(var.agent_name, " ", "-"))
  agent_watcher                 = local.create && var.agent_watcher
  agent_logs                    = local.create && var.agent_logs
  agent_metrics                 = local.create && var.agent_metrics
  agent_iam_create              = local.agent_watcher || local.agent_logs || local.agent_metrics
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
  autoscaler_name               = "initial_start_stop"
  region                        = var.region
  rg_region                     = var.rg_region == null ? local.region : var.rg_region
  resource_name                 = "${local.agent_name}-${lower(replace(local.region, " ", "-"))}"
  resource_description          = "${var.agent_name} - ${local.region}"
  admin_username                = var.admin_username
  start_start_time              = var.start_time == "now" ? try(time_offset.start_start_now[0].rfc3339, "") : var.start_time
  start_stop_time               = try(time_offset.start_stop_now[0].rfc3339, "")
  stop_start_time               = try(time_offset.stop_start[0].rfc3339, "")
  stop_stop_time                = try(time_offset.stop_stop[0].rfc3339, "")
  start_offset                  = split(" ", var.start_offset)
  run_duration                  = split(" ", var.run_duration)
}
