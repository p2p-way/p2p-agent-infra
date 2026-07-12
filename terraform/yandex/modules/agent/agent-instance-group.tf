# Instance group
resource "yandex_compute_instance_group" "agent" {
  count = local.create ? 1 : 0

  # Basic parameters
  name                = local.resource_name
  description         = local.resource_description
  service_account_id  = yandex_iam_service_account.instance_group[count.index].id
  deletion_protection = false
  folder_id           = local.folder_id
  labels              = local.default_labels

  # Allocation
  allocation_policy {
    zones = local.az_list
  }

  # Instance template
  instance_template {
    # Boot disk image
    boot_disk {
      mode = "READ_WRITE"
      name = local.resource_name
      initialize_params {
        # Disks and file storages
        image_id = data.yandex_compute_image.agent[count.index].image_id
        size     = var.os_volume_size
        type     = var.os_volume_type
      }
    }

    # Computing resources
    platform_id = local.instance_type
    resources {
      cores         = local.instance_cores
      memory        = local.instance_memory
      core_fraction = local.instance_core_fraction
      gpus          = 0
    }

    scheduling_policy {
      preemptible = false
    }

    # Network settings
    network_interface {
      network_id         = yandex_vpc_network.agent[count.index].id
      subnet_ids         = [for subnet in yandex_vpc_subnet.agent : subnet.id]
      security_group_ids = [yandex_vpc_security_group.agent[count.index].id]
      ipv4               = true
      ipv6               = var.enable_ipv6
      nat                = true
    }

    network_settings {
      type = "STANDARD"
    }

    placement_policy {
      placement_group_id = yandex_compute_placement_group.agent[count.index].id
    }

    # Access
    metadata = {
      user-data             = data.cloudinit_config.agent[count.index].rendered
      gce_http_endpoint     = "enabled"
      gce_http_token        = "enabled"
      serial-port-enable    = 1
      install-unified-agent = local.agent_logs || local.agent_metrics ? 1 : 0
    }

    # Additional
    service_account_id = yandex_iam_service_account.agent[count.index].id

    # Monitoring

    # Other
    name        = "${local.resource_name}-{instance.index}"
    description = local.resource_description
    hostname    = "${local.resource_name}-{instance.index}"
    labels = merge(
      local.default_labels,
      {
        agent-watcher  = local.agent_watcher
        instance-group = local.resource_name
      }
    )
  }

  # Changes during creation and updates
  deploy_policy {
    max_creating     = null
    max_deleting     = null
    max_unavailable  = 1
    max_expansion    = 1
    startup_duration = 10
    strategy         = "proactive"
  }

  # Scaling
  scale_policy {
    fixed_scale {
      size = var.desired_capacity
    }
  }

  # Integration with Network Load Balancer

  # Integration with Application Load Balancer

  # Health checks
  health_check {
    tcp_options {
      port = 22
    }
    timeout             = 3
    interval            = 10
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  # User-defined variables

  # Other
  timeouts {
    create = "5m"
    delete = "5m"
  }
}

# Placement group
resource "yandex_compute_placement_group" "agent" {
  count = local.create ? 1 : 0

  name                      = local.resource_name
  description               = local.resource_description
  placement_strategy_spread = true
  folder_id                 = local.folder_id
  labels                    = local.default_labels

  depends_on = [yandex_resourcemanager_folder_iam_member.instance_group]
}
