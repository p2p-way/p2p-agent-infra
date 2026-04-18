# Locals
locals {
  account_id               = try(data.cloudflare_account.current[0].id, null)
  account_name             = try(data.cloudflare_account.current[0].name, "")
  radar_create             = var.radar_create
  radar_name               = try(format("%s-%s", lower(replace(var.radar_name, " ", "-")), local.radar_prefix), "")
  radar_auth               = local.radar_create && var.radar_auth
  radar_dataset            = lower(replace(var.radar_name, " ", "-"))
  radar_custom_domain      = var.radar_domain_name != null && local.radar_create ? true : false
  radar_hostname           = try(format("%s.%s", local.radar_prefix, var.radar_domain_name), "")
  radar_base_url           = try(format("%s%s.%s.%s", "https://", cloudflare_worker.radar[0].name, local.account_name, "workers.dev"), "")
  radar_content_type       = lookup(local.content_type_map, element(split(".", var.radar_file), -1))
  radar_compatibility_date = "2026-04-18"
  radar_prefix_generate    = local.radar_create && var.radar_prefix == null
  radar_prefix             = local.radar_prefix_generate ? random_string.radar_prefix[0].result : var.radar_prefix

  radar_auth_env = local.radar_auth ? [{
    type = "plain_text"
    name = "AUTH"
    text = random_id.radar_auth[0].hex
  }] : []

  content_type_map = {
    js = "application/javascript+module"
  }
}

# Account
data "cloudflare_account" "current" {
  count = local.radar_create ? 1 : 0

  filter = {
    name = var.account_name
  }
}

# Zone
data "cloudflare_zone" "radar" {
  count = local.radar_custom_domain ? 1 : 0

  filter = {
    name = var.radar_domain_name
  }
}

# Radar - Auth
resource "random_id" "radar_auth" {
  count = local.radar_auth ? 1 : 0

  byte_length = 15
  keepers     = { version = var.radar_auth_version }
}

# Resources suffix
resource "random_string" "radar_prefix" {
  count = local.radar_prefix_generate ? 1 : 0

  length  = 10
  upper   = false
  special = false
  keepers = { version = var.radar_prefix_version }
}
