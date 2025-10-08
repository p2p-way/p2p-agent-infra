# Health check
resource "google_compute_health_check" "agent" {
  count = local.global_health_check_create ? 1 : 0

  name        = "${local.resource_name}-ssh-tcp-check"
  description = "${local.resource_description} - SSH TCP health check"

  timeout_sec         = 3
  check_interval_sec  = 10
  healthy_threshold   = 1
  unhealthy_threshold = 3
  tcp_health_check {
    port = 22
  }

  log_config {
    enable = true
  }

  lifecycle {
    create_before_destroy = true
  }
}
