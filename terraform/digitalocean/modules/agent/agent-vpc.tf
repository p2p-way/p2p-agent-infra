# VPC
resource "digitalocean_vpc" "agent" {
  count = local.create ? 1 : 0

  name        = local.resource_name
  description = local.resource_description
  region      = local.region
}
