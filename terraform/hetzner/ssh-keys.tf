# Locals
locals {
  create_agent_ssh_key      = var.agent_create && length(var.public_keys) == 0 ? true : false
  public_keys               = local.create_agent_ssh_key ? try(split(",", chomp(tls_private_key.agent[0].public_key_openssh)), []) : compact(var.public_keys)
  ssh_keys                  = local.create_agent_ssh_key ? [for keys in hcloud_ssh_key.agent_generated : keys.id] : [for keys in hcloud_ssh_key.agent_passed : keys.id]
  create_repository_ssh_key = var.agent_create && var.agent_repository_ssh_key == null ? true : false
  agent_repository_ssh_key  = local.create_repository_ssh_key ? base64encode(try(tls_private_key.repository[0].private_key_openssh, "")) : var.agent_repository_ssh_key
}

# SSH key - Agent
resource "tls_private_key" "agent" {
  count = local.create_agent_ssh_key ? 1 : 0

  algorithm = "ED25519"
}

# SSH key - Repository
resource "tls_private_key" "repository" {
  count = local.create_repository_ssh_key ? 1 : 0

  algorithm = "ED25519"
}

# SSH key - User passed
resource "hcloud_ssh_key" "agent_passed" {
  for_each = toset(compact(var.public_keys))

  name       = "${lower(replace(var.agent_name, " ", "-"))}-${substr(element(split(" ", each.key), 1), -10, -1)}"
  public_key = each.key
}

# SSH key - Generated
resource "hcloud_ssh_key" "agent_generated" {
  count = local.create_agent_ssh_key ? 1 : 0

  name       = "${lower(replace(var.agent_name, " ", "-"))}-${substr(element(split(" ", join(" ", local.public_keys)), 1), -10, -1)}"
  public_key = join("", local.public_keys)
}
