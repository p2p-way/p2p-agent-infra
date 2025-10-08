# Locals
locals {
  agent_cc_hosts = concat(var.agent_cc_hosts, module.control-center.url)
}
