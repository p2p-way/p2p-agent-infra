# Tags
resource "digitalocean_tag" "agent" {
  count = local.create ? 1 : 0

  name = local.resource_name
}
