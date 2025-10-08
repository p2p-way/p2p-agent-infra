# R2 - Bucket
resource "cloudflare_r2_bucket" "cc" {
  count = local.create ? 1 : 0

  name          = local.bucket_name
  location      = var.bucket_location
  jurisdiction  = var.bucket_location != null ? var.bucket_jurisdiction : null
  storage_class = "Standard"
  account_id    = try(data.cloudflare_account.current[count.index].account_id, "")
}

# R2 - Custom domain
resource "cloudflare_r2_custom_domain" "cc" {
  count = local.create ? 1 : 0

  bucket_name = cloudflare_r2_bucket.cc[count.index].name
  domain      = local.custom_domain
  enabled     = true
  min_tls     = "1.0"
  zone_id     = try(data.cloudflare_zone.cc[count.index].zone_id, "")
  account_id  = try(data.cloudflare_account.current[count.index].account_id, "")
}
