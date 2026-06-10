# Instance Pool
resource "oci_core_instance_pool" "agent" {
  count = local.create ? 1 : 0

  # Add basic details
  display_name              = local.resource_name
  compartment_id            = local.compartment_id
  size                      = var.initial_deploy ? 0 : var.desired_capacity
  instance_configuration_id = oci_core_instance_configuration.agent[count.index].id

  instance_display_name_formatter = "${local.resource_name}-$${launchCount}"
  instance_hostname_formatter     = "${local.resource_name}-$${launchCount}"

  # Instance configuration details

  # Tags
  freeform_tags = local.freeform_tags

  # Configure pool placement
  dynamic "placement_configurations" {
    for_each = local.ad_list

    content {
      # Availability domains
      availability_domain = placement_configurations.value
      # Primary VNIC
      primary_subnet_id = oci_core_subnet.agent[0].id
    }
  }

  timeouts {
    create = "10m"
    update = "10m"
  }
}

# Availability domains
data "oci_identity_availability_domains" "current" {
  count = local.create ? 1 : 0

  compartment_id = local.compartment_id
}

