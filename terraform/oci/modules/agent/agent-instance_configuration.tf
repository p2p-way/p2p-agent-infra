# Instance Configuration
resource "oci_core_instance_configuration" "agent" {
  count = local.create ? 1 : 0

  # Instance configuration information
  display_name   = local.resource_name
  compartment_id = local.compartment_id

  source = "NONE"

  # Tagging options
  freeform_tags = var.default_tags

  instance_details {
    instance_type = "compute"

    launch_details {
      compartment_id = local.compartment_id

      # Placement

      # Advanced options

      # Image and shape
      source_details {
        source_type = "image"
        image_id    = data.oci_core_images.agent[count.index].images[0].id

        boot_volume_size_in_gbs = var.os_volume_size
        boot_volume_vpus_per_gb = var.os_volume_perf
      }
      is_pv_encryption_in_transit_enabled = true

      shape = local.instance_type
      shape_config {
        ocpus         = local.instance_ocpus
        memory_in_gbs = local.instance_memory
        # baseline_ocpu_utilization = "BASELINE_1_2"
      }

      # Advanced options
      # Management
      # Instance metadata service
      instance_options {
        are_legacy_imds_endpoints_disabled = true
      }

      metadata = {
        user_data = data.cloudinit_config.agent[count.index].rendered
      }

      # Tagging
      freeform_tags = local.freeform_tags

      # Availability configuration
      availability_config {
        is_live_migration_preferred = true
        recovery_action             = "RESTORE_INSTANCE"
      }

      # Oracle Cloud Agent
      agent_config {
        are_all_plugins_disabled = false
        is_management_disabled   = false
        is_monitoring_disabled   = false
        plugins_config {
          name          = "Compute Instance Monitoring"
          desired_state = var.agent_metrics ? "ENABLED" : "DISABLED"
        }
        plugins_config {
          name          = "Compute Instance Run Command"
          desired_state = "ENABLED"
        }
        plugins_config {
          name          = "Custom Logs Monitoring"
          desired_state = var.agent_logs ? "ENABLED" : "DISABLED"
        }
        plugins_config {
          name          = "Management Agent"
          desired_state = "ENABLED"
        }
        plugins_config {
          name          = "OS Management Hub Agent"
          desired_state = "ENABLED"
        }
      }

      # Security

      # Advanced options
      # Security attributes

      # Primary VNIC
      create_vnic_details {
        display_name = local.resource_name
        subnet_id    = oci_core_subnet.agent[count.index].id

        # Private IPv4 address assignment
        # subnet_cidr = oci_core_subnet.agent[count.index].ipv4cidr_blocks[0]

        # Public IPv4 address assignment
        assign_public_ip = true

        # IPv6 address assignment
        assign_ipv6ip = var.enable_ipv6 ? true : false

        # Advanced options
        nsg_ids                   = [oci_core_network_security_group.agent[count.index].id]
        assign_private_dns_record = true

        # Launch options
        hostname_label         = local.resource_name
        skip_source_dest_check = true
        freeform_tags          = local.freeform_tags
      }

      # Add SSH keys - in metadata above

      # Secondary VNIC

      # Boot volume - set above in # Image and shape

      # Other
      display_name = local.resource_name
    }

    # Block volumes
  }

  lifecycle {
    create_before_destroy = true
  }
}
