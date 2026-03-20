# Locals
locals {
  agent_cc_hosts       = concat(var.agent_cc_hosts, module.control-center.url)
  scheduler_expression = var.initial_deploy ? var.scheduler_expression : var.cc_commands["cc-w-s-expression"]
}
