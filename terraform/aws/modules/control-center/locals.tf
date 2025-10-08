# Locals
locals {
  create             = var.cc_create
  name               = "${lower(replace(var.cc_name, " ", "-"))}-${try(random_string.cc_suffix[0].result, "")}"
  description        = "${var.cc_name} - ${try(random_string.cc_suffix[0].result, "")}"
  policy_name        = local.name
  function_name      = local.name
  waf_create         = local.create && var.waf_enable
  waf_logs_enable    = local.waf_create && var.waf_logs_enable
  cc_commands_indent = max([for k, v in var.cc_commands : length(format("'%s'", k))]...)
  cc_commands        = { for k, v in var.cc_commands : format("'%s'%${local.cc_commands_indent - length(format("'%s'", k))}s", k, "") => format("{ value: '%s' }", v) }
}

# Random suffix - Control center
resource "random_string" "cc_suffix" {
  count = local.create ? 1 : 0

  length  = 5
  upper   = false
  special = false
  keepers = { version = var.cc_suffix_version }
}
