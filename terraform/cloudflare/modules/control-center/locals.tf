# Locals
locals {
  create        = var.cc_create
  name          = "${var.cc_name} - ${local.custom_domain}"
  bucket_name   = "${local.custom_prefix}-${replace(var.domain_name, ".", "-")}-${local.custom_suffix}"
  custom_prefix = var.cc_prefix == null ? try(random_string.cc_prefix[0].result, "") : var.cc_prefix
  custom_suffix = try(random_string.bucket_suffix[0].result, "")
  custom_domain = "${local.custom_prefix}.${var.domain_name}"
  headers = merge([for command in keys(var.cc_commands) : {
    "${command}" = {
      operation = "set"
      value     = lookup(var.cc_commands, command)
    }
  }]...)
}

# Account
data "cloudflare_account" "current" {
  count = local.create ? 1 : 0

  filter = {
    name = var.account_name
  }
}

# Zone
data "cloudflare_zone" "cc" {
  count = local.create ? 1 : 0

  filter = {
    name = var.domain_name
  }
}

# Bucket suffix
resource "random_string" "bucket_suffix" {
  count = local.create ? 1 : 0

  length  = 5
  upper   = false
  special = false
  keepers = { version = var.bucket_suffix_version }
}

# Bucket suffix
resource "random_string" "cc_prefix" {
  count = local.create && var.cc_prefix == null ? 1 : 0

  length  = 5
  upper   = false
  special = false
  keepers = { version = var.cc_prefix_version }
}
