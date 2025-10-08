# Ruleset - Header Transform
resource "cloudflare_ruleset" "cc" {
  count = local.create ? 1 : 0

  name        = local.name
  description = local.name
  kind        = "zone"
  phase       = "http_response_headers_transform"
  zone_id     = try(data.cloudflare_zone.cc[count.index].zone_id, "")

  rules = [{
    ref         = "control_center_headers_${local.custom_suffix}"
    enabled     = true
    description = local.name
    expression  = "(http.host eq \"${local.custom_domain}\")"
    action      = "rewrite"
    action_parameters = {
      headers = local.headers
    }
  }]

  lifecycle {
    ignore_changes = [
      name
    ]
  }
}
