# VPC
resource "google_compute_network" "agent" {
  count = local.global_network_create ? 1 : 0

  name                    = local.resource_name
  auto_create_subnetworks = true
  routing_mode            = "GLOBAL"
  mtu                     = 1460
}

# Firewall - Internal
resource "google_compute_firewall" "internal" {
  count = local.global_network_create ? 1 : 0

  name        = "${local.resource_name}-allow-internal"
  description = "All communications - VPC"
  network     = google_compute_network.agent[count.index].name

  allow {
    protocol = "all"
  }

  source_ranges = ["10.128.0.0/9"]
}

# Firewall - SSH Health check
resource "google_compute_firewall" "ssh_health_check" {
  count = local.global_network_create ? 1 : 0

  name        = "${local.resource_name}-allow-ssh-health-check"
  description = "SSH - GCP"
  network     = google_compute_network.agent[count.index].name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  # https://cloud.google.com/load-balancing/docs/health-check-concepts#ip-ranges
  source_ranges = ["35.191.0.0/16", "130.211.0.0/22"]
}

# Firewall - Archivist
resource "google_compute_firewall" "archivist" {
  count = local.global_network_create && (local.agent_p2p_archivist_tcp_ports != null || local.agent_p2p_archivist_udp_ports != null) ? 1 : 0

  name        = "${local.resource_name}-allow-archivist"
  description = "Archivist TCP/UDP - Any"
  network     = google_compute_network.agent[count.index].name

  dynamic "allow" {
    for_each = local.agent_p2p_archivist_tcp_ports != null ? [1] : []
    content {
      protocol = "tcp"
      ports    = [for ports in split(",", local.agent_p2p_archivist_tcp_ports) : trimspace(ports)]
    }
  }

  dynamic "allow" {
    for_each = local.agent_p2p_archivist_udp_ports != null ? [1] : []
    content {
      protocol = "udp"
      ports    = [for ports in split(",", local.agent_p2p_archivist_udp_ports) : trimspace(ports)]
    }
  }

  source_ranges = ["0.0.0.0/0"]
}

# Firewall - IPFS
resource "google_compute_firewall" "ipfs" {
  count = local.global_network_create && (local.agent_p2p_ipfs_tcp_ports != null || local.agent_p2p_ipfs_udp_ports != null) ? 1 : 0

  name        = "${local.resource_name}-allow-ipfs"
  description = "IPFS TCP/UDP - Any"
  network     = google_compute_network.agent[count.index].name

  dynamic "allow" {
    for_each = local.agent_p2p_ipfs_tcp_ports != null ? [1] : []
    content {
      protocol = "tcp"
      ports    = [for ports in split(",", local.agent_p2p_ipfs_tcp_ports) : trimspace(ports)]
    }
  }

  dynamic "allow" {
    for_each = local.agent_p2p_ipfs_udp_ports != null ? [1] : []
    content {
      protocol = "udp"
      ports    = [for ports in split(",", local.agent_p2p_ipfs_udp_ports) : trimspace(ports)]
    }
  }

  source_ranges = ["0.0.0.0/0"]
}

# Firewall - Radicle
resource "google_compute_firewall" "radicle" {
  count = local.global_network_create && (local.agent_p2p_radicle_tcp_ports != null || local.agent_p2p_radicle_udp_ports != null) ? 1 : 0

  name        = "${local.resource_name}-allow-radicle"
  description = "Radicle TCP/UDP - Any"
  network     = google_compute_network.agent[count.index].name

  dynamic "allow" {
    for_each = local.agent_p2p_radicle_tcp_ports != null ? [1] : []
    content {
      protocol = "tcp"
      ports    = [for ports in split(",", local.agent_p2p_radicle_tcp_ports) : trimspace(ports)]
    }
  }

  dynamic "allow" {
    for_each = local.agent_p2p_radicle_udp_ports != null ? [1] : []
    content {
      protocol = "udp"
      ports    = [for ports in split(",", local.agent_p2p_radicle_udp_ports) : trimspace(ports)]
    }
  }

  source_ranges = ["0.0.0.0/0"]
}

# Firewall - TON Storage
resource "google_compute_firewall" "ton" {
  count = local.global_network_create && (local.agent_p2p_ton_tcp_ports != null || local.agent_p2p_ton_udp_ports != null) ? 1 : 0

  name        = "${local.resource_name}-allow-ton-storage"
  description = "TON Storage TCP/UDP - Any"
  network     = google_compute_network.agent[count.index].name

  dynamic "allow" {
    for_each = local.agent_p2p_ton_tcp_ports != null ? [1] : []
    content {
      protocol = "tcp"
      ports    = [for ports in split(",", local.agent_p2p_ton_tcp_ports) : trimspace(ports)]
    }
  }

  dynamic "allow" {
    for_each = local.agent_p2p_ton_udp_ports != null ? [1] : []
    content {
      protocol = "udp"
      ports    = [for ports in split(",", local.agent_p2p_ton_udp_ports) : trimspace(ports)]
    }
  }

  source_ranges = ["0.0.0.0/0"]
}

# Firewall - Torrent
resource "google_compute_firewall" "torrent" {
  count = local.global_network_create && (local.agent_p2p_torrent_tcp_ports != null || local.agent_p2p_torrent_udp_ports != null) ? 1 : 0

  name        = "${local.resource_name}-allow-torrent"
  description = "Torrent TCP/UDP - Any"
  network     = google_compute_network.agent[count.index].name

  dynamic "allow" {
    for_each = local.agent_p2p_torrent_tcp_ports != null ? [1] : []
    content {
      protocol = "tcp"
      ports    = [for ports in split(",", local.agent_p2p_torrent_tcp_ports) : trimspace(ports)]
    }
  }

  dynamic "allow" {
    for_each = local.agent_p2p_torrent_udp_ports != null ? [1] : []
    content {
      protocol = "udp"
      ports    = [for ports in split(",", local.agent_p2p_torrent_udp_ports) : trimspace(ports)]
    }
  }

  source_ranges = ["0.0.0.0/0"]
}

# Firewall - Custom
resource "google_compute_firewall" "custom" {
  count = local.global_network_create && (local.agent_custom_tcp_ports != null || local.agent_custom_udp_ports != null) ? 1 : 0

  name        = "${local.resource_name}-allow-custom"
  description = "Custom TCP/UDP - Any"
  network     = google_compute_network.agent[count.index].name

  dynamic "allow" {
    for_each = local.agent_custom_tcp_ports != null ? [1] : []
    content {
      protocol = "tcp"
      ports    = [for ports in split(",", local.agent_custom_tcp_ports) : trimspace(ports)]
    }
  }

  dynamic "allow" {
    for_each = local.agent_custom_udp_ports != null ? [1] : []
    content {
      protocol = "udp"
      ports    = [for ports in split(",", local.agent_custom_udp_ports) : trimspace(ports)]
    }
  }

  source_ranges = ["0.0.0.0/0"]
}

# Firewall - SSH
resource "google_compute_firewall" "ssh" {
  for_each = toset(local.allow_ssh)

  name        = "${local.resource_name}-allow-ssh-${replace(each.key, "/[./]/", "-")}"
  description = "SSH - ${each.key}"
  network     = google_compute_network.agent[0].name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = [each.key]
}
