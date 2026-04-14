# Control center
module "control-center" {
  source = "./modules/control-center"

  cc_create       = var.cc_create
  cc_name         = var.cc_name
  cc_commands     = var.cc_commands
  cc_uri          = var.cc_uri
  cc_uri_version  = var.cc_uri_version
  waf_enable      = var.waf_enable
  waf_rate_limit  = var.waf_rate_limit
  waf_logs_enable = var.waf_logs_enable
}
