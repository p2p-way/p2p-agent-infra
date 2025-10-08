# Instance group
resource "google_compute_region_instance_group_manager" "agent" {
  count = local.create ? 1 : 0

  name                      = local.resource_name
  description               = local.resource_name
  base_instance_name        = local.resource_name
  region                    = local.region
  distribution_policy_zones = data.google_compute_zones.available[count.index].names
  target_size               = var.initial_deploy ? 0 : var.desired_capacity

  version {
    instance_template = google_compute_instance_template.agent[count.index].id
  }

  auto_healing_policies {
    health_check      = local.regional_health_check_create ? google_compute_region_health_check.agent[count.index].id : lookup(var.global_health_check, "id")
    initial_delay_sec = 60
  }
}

# Get AZ
data "google_compute_zones" "available" {
  count = local.create ? 1 : 0

  region = local.region
  status = "UP"
}
