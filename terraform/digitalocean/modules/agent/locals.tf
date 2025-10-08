# Locals
locals {
  create                        = var.agent_create
  agent_name                    = lower(replace(var.agent_name, " ", "-"))
  region                        = var.region
  location_description          = try(data.digitalocean_region.current[0].name, "")
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
  resource_name                 = "${local.agent_name}-${local.region}"
  resource_description          = "${var.agent_name} - ${local.location_description}"
}

# Region
data "digitalocean_region" "current" {
  count = local.create ? 1 : 0

  slug = local.region
}
