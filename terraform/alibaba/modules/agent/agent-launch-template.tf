# ECS Launch Template
resource "alicloud_ecs_launch_template" "agent" {
  count = local.create ? 1 : 0

  launch_template_name = local.resource_name
  description          = local.resource_description

  # Billing Method
  instance_charge_type = var.instance_charge_type

  # Instance Type
  instance_type = var.instance_type

  # Image
  image_id = data.alicloud_images.agent[count.index].images.0.id

  # Storage
  system_disk {
    name                 = local.resource_name
    description          = local.resource_description
    size                 = var.system_disk_size
    category             = var.system_disk_category
    performance_level    = var.system_disk_performance_level
    delete_with_instance = true
  }

  # Network Type
  vpc_id = alicloud_vpc.agent[count.index].id

  # Public IP Address
  internet_charge_type       = var.internet_charge_type
  internet_max_bandwidth_in  = var.internet_max_bandwidth_in
  internet_max_bandwidth_out = var.internet_max_bandwidth_out

  # Security Group
  security_group_id = alicloud_security_group.agent[count.index].id

  # Advanced Configurations
  instance_name = local.resource_name
  host_name     = local.resource_name

  # Advanced Options (Instance RAM Role and User Data)
  ram_role_name = local.agent_ram_create ? alicloud_ram_role.agent[count.index].name : null

  http_endpoint               = "enabled"
  http_tokens                 = "required"
  http_put_response_hop_limit = 1

  user_data = data.cloudinit_config.agent[count.index].rendered

  # Tag
  tags          = merge(var.default_tags, { agent-watcher = "${local.agent_watcher}" })
  template_tags = var.default_tags

  # Resource Group
  resource_group_id          = alicloud_resource_manager_resource_group.agent[count.index].id
  template_resource_group_id = alicloud_resource_manager_resource_group.agent[count.index].id

  # Other
  update_default_version_number = true
}
