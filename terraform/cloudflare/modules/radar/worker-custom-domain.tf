# DNS - Radar
resource "cloudflare_workers_custom_domain" "radar" {
  count = local.radar_custom_domain ? 1 : 0

  account_id = local.account_id
  hostname   = local.radar_hostname
  service    = cloudflare_worker.radar[count.index].name
  zone_id    = data.cloudflare_zone.radar[count.index].id
  # environment = "production" # https://github.com/cloudflare/terraform-provider-cloudflare/issues/6907
}
