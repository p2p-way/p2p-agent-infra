# Anti-Affinity Group
resource "exoscale_anti_affinity_group" "agent" {
  count = local.create ? 1 : 0

  name        = local.resource_name
  description = local.resource_description
}

# Template
data "exoscale_template" "agent" {
  count = local.create ? 1 : 0

  zone = var.region
  name = local.os_name
}

# Instance
resource "exoscale_compute_instance" "agent" {
  count = local.create ? var.desired_capacity : 0

  # Name
  name = "${local.resource_name}-${count.index + 1}"

  # Template
  template_id = data.exoscale_template.agent[0].id

  # Zone
  zone = var.region

  # Instance type
  type = var.instance_type

  # Disk size
  disk_size = var.disk_size

  # SSH Keys
  ssh_keys = var.ssh_keys

  # Public IP Assignment
  ipv6 = var.ipv6

  # Security groups
  security_group_ids = [exoscale_security_group.agent[0].id]

  # Anti affinity groups
  anti_affinity_group_ids = [exoscale_anti_affinity_group.agent[0].id]

  # TPM enabled
  enable_tpm = false

  # Secureboot enabled
  enable_secure_boot = false

  # User Data
  user_data = data.cloudinit_config.agent[0].rendered

  # Other
  labels = var.default_labels
}
