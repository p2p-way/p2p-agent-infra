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

# Firewall - Open TCP/UDP
resource "google_compute_firewall" "agent" {
  count = local.global_network_create && (local.agent_open_tcp_ports != null || local.agent_open_udp_ports != null) ? 1 : 0

  name        = "${local.resource_name}-allow-open-ports"
  description = "Open TCP/UDP - Any"
  network     = google_compute_network.agent[count.index].name

  dynamic "allow" {
    for_each = local.agent_open_tcp_ports != null ? [1] : []

    content {
      protocol = "tcp"
      ports    = [for ports in split(",", local.agent_open_tcp_ports) : trimspace(ports)]
    }
  }

  dynamic "allow" {
    for_each = local.agent_open_udp_ports != null ? [1] : []

    content {
      protocol = "udp"
      ports    = [for ports in split(",", local.agent_open_udp_ports) : trimspace(ports)]
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
