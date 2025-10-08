# VPC
resource "digitalocean_vpc" "agent" {
  count = local.create ? 1 : 0

  name        = local.resource_name
  description = local.resource_description
  region      = local.region
}

# Workaround - https://github.com/digitalocean/terraform-provider-digitalocean/issues/446
resource "time_sleep" "wait_for_vpc_destroy" {
  count = local.create ? 1 : 0

  destroy_duration = "30s"

  depends_on = [digitalocean_vpc.agent]
}

resource "null_resource" "wait_for_vpc_destroy" {
  count = local.create ? 1 : 0

  depends_on = [time_sleep.wait_for_vpc_destroy]
}
