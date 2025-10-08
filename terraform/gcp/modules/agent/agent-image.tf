# Locals
locals {
  arm_series = ["c4a", "t2a"]

  # https://cloud.google.com/compute/docs/instances/arm-on-compute
  # C4A machine series
  # Tau T2A machine series
  # Add amd64/arm64 auto detection, when will be available in google_compute_machine_types data source
  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_machine_types#attributes-reference
  # gcloud compute machine-types list
  # gcloud compute machine-types list --filter="name=t2a-standard-1"
  # gcloud compute machine-types describe --zone=europe-west4-b t2a-standard-1

  os_family_map = {
    ubuntu-22-04 = local.architecture == "amd64" ? "ubuntu-2204-lts" : "ubuntu-2204-lts-${local.architecture}"
    ubuntu-24-04 = "ubuntu-2404-lts-${local.architecture}"
    ubuntu       = "ubuntu-2404-lts-${local.architecture}"
  }

  os_project_map = {
    ubuntu = "ubuntu-os-cloud"
  }

  architecture = contains(local.arm_series, element(split("-", var.machine_type), 0)) ? "arm64" : "amd64"
  os_family    = lookup(local.os_family_map, replace(var.os_name, ".", "-"))
  os_project   = lookup(local.os_project_map, element(split("-", var.os_name), 0))
}

# Image
data "google_compute_image" "agent" {
  count = local.create ? 1 : 0

  most_recent = true
  family      = local.os_family
  project     = local.os_project
}
