# Agent
region              = "eu-central"
agent_create        = true
agent_name          = "P2P agent"
agent_open_ports    = ["1024-65535", "1024-65535"]
allow_ssh           = []
public_keys         = []
os_name             = "ubuntu"
type                = "g6-nanode-1"
desired_capacity    = 1
agent_cron_schedule = "*/15"
agent_commands = {
  CC       = true
  PRE_RUN  = true
  POST_RUN = true
}
agent_commands_defaults = {
  DEFAULT_DELAY              = 60
  DEFAULT_FORCE_RUN          = "true"
  DEFAULT_MAIN_RUN           = "ansible/playbook.yml"
  DEFAULT_POST_RUN           = "echo \"Finish: $(date)\""
  DEFAULT_PRE_RUN            = "echo \"Start: $(date)\""
  DEFAULT_REPOSITORY         = "https://github.com/p2p-way/p2p-agent-infra"
  DEFAULT_REPOSITORY_MODE    = "client-server"
  DEFAULT_REPOSITORY_RADICLE = "rad:z3gqcJUoA1n9HaHKufZs5FCSGazv5"
  DEFAULT_TYPE               = "ansible"
}
agent_cc_hosts           = ["https://d2d0z7lax5amc3.cloudfront.net"]
agent_cc_commands        = "delay desired-capacity force-run main-run post-run pre-run repository type"
agent_cc_commands_prefix = "cc-a"
agent_repository_ssh_key = null
