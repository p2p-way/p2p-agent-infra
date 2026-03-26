# Control center
cc_create         = true
account_name      = null
domain_name       = "<domain tld>"
cc_prefix         = null
cc_prefix_version = 1
cc_name           = "P2P control center"
cc_commands = {
  cc-w-s-expression       = "15 minutes"
  cc-w-a-desired-capacity = 1
  cc-w-a-start            = "2022-11-28T13:00:00Z"
  cc-w-a-start-offset     = "15 minutes"
  cc-w-a-stop             = "2022-12-05T13:00:00Z"
  cc-a-delay              = 60
  cc-a-desired-capacity   = "-"
  cc-a-force-run          = "false"
  cc-a-main-run           = "ansible/playbook.yml"
  cc-a-pre-run            = "echo \"Start: $(date)\""
  cc-a-post-run           = "echo \"Finish: $(date)\""
  cc-a-repository         = "https://github.com/p2p-way/p2p-agent-infra"
  cc-a-type               = "ansible"
}
bucket_jurisdiction   = "default"
bucket_location       = null
bucket_suffix_version = 1
