# Worker - Radar
resource "cloudflare_worker" "radar" {
  count = local.radar_create ? 1 : 0

  name       = local.radar_name
  account_id = data.cloudflare_account.current[count.index].account_id

  observability = {
    enabled            = true
    head_sampling_rate = 1
    logs = {
      enabled            = true
      head_sampling_rate = 1
      invocation_logs    = true
    }
  }
  subdomain = {
    enabled          = true
    previews_enabled = false
  }
}

resource "cloudflare_worker_version" "radar" {
  count = local.radar_create ? 1 : 0

  account_id         = data.cloudflare_account.current[count.index].account_id
  worker_id          = cloudflare_worker.radar[count.index].id
  compatibility_date = local.radar_compatibility_date
  main_module        = var.radar_file
  modules = [
    {
      name         = var.radar_file
      content_type = local.radar_content_type
      content_file = "${path.module}/files/${var.radar_file}"
    }
  ]
  bindings = concat([
    {
      type    = "analytics_engine"
      name    = "ANALYTICS_DATASET"
      dataset = local.radar_dataset
    }
    ],
  local.radar_auth_env)
}

resource "cloudflare_workers_deployment" "radar" {
  count = local.radar_create ? 1 : 0

  account_id  = data.cloudflare_account.current[count.index].account_id
  script_name = cloudflare_worker.radar[count.index].name
  strategy    = "percentage"
  versions = [{
    percentage = 100
    version_id = cloudflare_worker_version.radar[count.index].id
  }]
}
