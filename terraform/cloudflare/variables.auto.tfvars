# Control center
cc_create         = true
account_name      = null
domain_name       = "<domain tld>"
cc_prefix         = null
cc_prefix_version = 1
cc_name           = "P2P control center"
cc_commands = {
  cc-a-delay            = 60
  cc-a-desired-capacity = "-"
  cc-a-force-run        = "false"
  cc-a-main-run         = "ansible/playbook.yml"
  cc-a-pre-run          = "echo \"Start: $(date)\""
  cc-a-post-run         = "echo \"Finish: $(date)\""
  cc-a-repository       = "https://github.com/p2p-way/p2p-agent-infra"
  cc-a-type             = "ansible"
}
bucket_jurisdiction   = "default"
bucket_location       = null
bucket_suffix_version = 1
