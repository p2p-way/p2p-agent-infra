# Resource group
resource "alicloud_resource_manager_resource_group" "agent" {
  count = local.create ? 1 : 0

  resource_group_name = local.resource_name
  display_name        = local.resource_description

  tags = var.default_tags

  lifecycle {
    create_before_destroy = true
  }
}
