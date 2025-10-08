# Instance template
resource "google_compute_instance_template" "agent" {
  count = local.create ? 1 : 0

  name_prefix = "${local.resource_name}-"

  # Labels

  #  Machine configuration
  machine_type = var.machine_type

  #  Boot disk
  disk {
    source_image = data.google_compute_image.agent[count.index].id
    auto_delete  = true
    disk_type    = var.disk_type
    disk_size_gb = var.disk_size_gb
    boot         = true
  }

  #  Identity and API access
  dynamic "service_account" {
    for_each = local.agent_iam_create ? [1] : []
    content {
      email  = google_service_account.agent[count.index].email
      scopes = local.sa_scope
    }
  }

  # Advanced options

  # Networking
  dynamic "network_interface" {
    for_each = local.regional_network_create ? [] : [1]
    content {
      network = lookup(var.global_network, "name")
      access_config {
      }
    }
  }

  dynamic "network_interface" {
    for_each = local.regional_network_create ? [1] : []
    content {
      subnetwork = google_compute_subnetwork.agent[count.index].id
      access_config {
      }
    }
  }

  # Management
  metadata = merge(
    var.default_labels,
    {
      enable-oslogin = "TRUE"
      user-data      = data.cloudinit_config.agent[count.index].rendered
      agent-watcher  = "${local.agent_watcher}"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}
