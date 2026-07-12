# Main
create_folder = false

# Common
default_labels = {
  Name    = "P2P"
  Project = "P2P agent"
  Cloud   = "yandex"
}

# Agent
region               = "ru-central1"
agent_create         = true
agent_name           = "P2P agent"
agent_watcher        = true
agent_logs           = false
agent_metrics        = false
agent_logs_retention = "168h0m0s"
cidr_block           = "10.20.30.0/24"
az_list              = ["a", "b", "d", "e"]
open_ports           = ["1024-65535", "1024-65535"]
allow_ssh            = []
public_keys          = []
os_name              = "ubuntu"
instance_type        = "standard-v3" # "standard-v3:2:1:50"
os_volume_type       = "network-ssd"
os_volume_size       = 10
desired_capacity     = 1
start_time           = "now"
enable_ipv6          = false
agent_cron_schedule  = "*/15"
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
agent_cc_hosts              = ["https://d2d0z7lax5amc3.cloudfront.net"]
agent_cc_commands           = "delay desired-capacity force-run main-run post-run pre-run repository type"
agent_cc_commands_prefix    = "cc-a"
agent_repository_ssh_key    = null
watcher_name                = "P2P watcher"
watcher_file                = "watcher.py"
watcher_runtime             = "python3.14"
watcher_cc_agent_prefix     = "cc-w-a"
watcher_cc_scheduler_prefix = "cc-w-s"
scheduler_name              = "P2P scheduler"
scheduler_expression        = "15 minutes"
radar_url                   = []
radar_url_file              = "p2p-radar.url"
