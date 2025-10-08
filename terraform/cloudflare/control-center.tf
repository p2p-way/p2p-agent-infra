# Control center
module "control-center" {
  source = "./modules/control-center"

  cc_create             = var.cc_create
  account_name          = var.account_name
  domain_name           = var.domain_name
  cc_prefix             = var.cc_prefix
  cc_prefix_version     = var.cc_prefix_version
  cc_name               = var.cc_name
  cc_commands           = var.cc_commands
  bucket_jurisdiction   = var.bucket_jurisdiction
  bucket_location       = var.bucket_location
  bucket_suffix_version = var.bucket_suffix_version
}
