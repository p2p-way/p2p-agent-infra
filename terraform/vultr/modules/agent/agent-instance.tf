# Instance
resource "vultr_instance" "agent" {
  count = local.create ? var.desired_capacity : 0

  # Filter Locations
  region = var.region

  # Choose Type
  plan = var.plan

  # Operating System
  os_id = data.vultr_os.agent.id

  # Server Settings
  ssh_key_ids       = var.ssh_key_ids
  firewall_group_id = vultr_firewall_group.agent[count.index].id

  # Server Hostname and Label
  hostname = "${local.resource_name}-${count.index + 1}"
  label    = "${local.resource_name}-${count.index + 1}"

  # Additional Features
  enable_ipv6 = var.enable_ipv6
  backups     = "disabled"
  user_data   = data.cloudinit_config.agent[count.index].rendered
}
