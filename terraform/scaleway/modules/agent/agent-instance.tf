# Placement Group
resource "scaleway_instance_placement_group" "agent" {
  count = local.create ? 1 : 0

  name        = local.resource_name
  policy_type = "max_availability"

  zone       = var.region
  project_id = var.project_id
}

# Instance
resource "scaleway_instance_server" "agent" {
  count = local.create ? var.desired_capacity : 0

  # Zone
  zone = var.region

  # Project
  project_id = var.project_id

  # Instance name
  name = "${local.resource_name}-${count.index + 1}"
  tags = local.default_tags
  type = var.type

  # Choose an image
  image = local.os_name

  # Add volumes
  root_volume {
    name                  = local.resource_name
    size_in_gb            = var.os_disk_size
    volume_type           = var.os_disk_type
    sbs_iops              = var.os_disk_sbs_iops
    delete_on_termination = true
  }

  # Configure network and security
  enable_dynamic_ip = true

  # Cloud-init (optional)
  user_data = {
    cloud-init = data.cloudinit_config.agent[0].rendered
  }

  # Other
  security_group_id  = scaleway_instance_security_group.agent[0].id
  placement_group_id = scaleway_instance_placement_group.agent[0].id
}
