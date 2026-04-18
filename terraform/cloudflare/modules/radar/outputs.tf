# Analytics URL
output "analytics_url" {
  value = try("https://api.cloudflare.com/client/v4/accounts/${local.account_id}/analytics_engine/sql", null)
}

# Radar Auth
output "radar_auth" {
  value = var.radar_auth ? try(random_id.radar_auth[0].hex, null) : null
}

# Radar URL
output "radar_url" {
  value = try(concat([local.radar_base_url], formatlist("%s%s", "https://", cloudflare_worker.radar[0].references.domains[*].hostname)), null)
}
