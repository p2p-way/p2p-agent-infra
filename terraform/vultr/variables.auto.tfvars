# Agent
region              = "fra"
agent_create        = true
agent_name          = "P2P agent"
open_ports          = ["1024-65535", "1024-65535"]
allow_ssh           = []
public_keys         = []
os_name             = "ubuntu"
plan                = "vc2-1c-1gb"
desired_capacity    = 1
enable_ipv6         = false
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
  DEFAULT_REPOSITORY_RADICLE = "rad:z3yXqAJjHXxqJ8ChJezGZRdkvU27"
  DEFAULT_TYPE               = "ansible"
}
agent_cc_hosts           = ["https://d2d0z7lax5amc3.cloudfront.net"]
agent_cc_commands        = "delay desired-capacity force-run main-run post-run pre-run repository type"
agent_cc_commands_prefix = "cc-a"
agent_repository_ssh_key = null
radar_url                = []
radar_url_file           = "p2p-radar.url"
