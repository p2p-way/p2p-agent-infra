# Locals
locals {
  create                        = var.agent_create
  agent_name                    = lower(replace(var.agent_name, " ", "-"))
  resource_name                 = local.agent_name
  resource_description          = var.agent_name
  global_network_create         = var.agent_create && lookup(var.global_network, "create")
  global_network_name           = try(google_compute_network.agent[0].name, null)
  global_network                = local.global_network_create ? merge(var.global_network, { name = local.global_network_name }) : var.global_network
  global_health_check_create    = var.agent_create && lookup(var.global_health_check, "create")
  global_health_check_id        = try(google_compute_health_check.agent[0].id, null)
  global_health_check           = local.global_health_check_create ? merge(var.global_health_check, { id = local.global_health_check_id }) : var.global_health_check
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
  allow_ssh                     = local.global_network_create ? var.allow_ssh : []
}
