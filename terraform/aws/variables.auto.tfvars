# Common
default_tags = {
  Name    = "P2P"
  Project = "P2P agent"
  Cloud   = "aws"
}

# Control center
cc_create = false
cc_name   = "P2P control center"
cc_commands = {
  cc-w-scheduler          = "*/10 * * * *"
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
waf_enable      = false
waf_rate_limit  = 1000
waf_logs_enable = false

# Agent
region               = "eu-central-1"
agent_create         = true
agent_name           = "P2P agent"
agent_watcher        = true
agent_logs           = false
agent_metrics        = false
agent_logs_retention = 7
agent_open_ports     = ["1024-65535", "1024-65535"]
cidr_block           = "10.20.30.0/24"
az_number            = 3
allow_ssh            = []
public_keys          = []
os_name              = "ubuntu"
instance_type        = "t3.micro" # t3a.micro
volume_size          = null
volume_type          = "gp3"
volume_iops          = null
volume_throughput    = null
initial_deploy       = true
desired_capacity     = 1
start_time           = "now"
start_offset         = "15 minutes"
run_duration         = "7 days"
time_offset_version  = 1
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
  DEFAULT_REPOSITORY_RADICLE = "rad:z3gqcJUoA1n9HaHKufZs5FCSGazv5"
  DEFAULT_TYPE               = "ansible"
}
agent_cc_hosts           = ["https://d2d0z7lax5amc3.cloudfront.net"]
agent_cc_commands        = "delay desired-capacity force-run main-run post-run pre-run repository type"
agent_cc_commands_prefix = "cc-a"
agent_repository_ssh_key = null
watcher_name             = "P2P watcher"
scheduler_name           = "P2P scheduler"
scheduler_expression     = "rate(15 minutes)"
lambda_architecture      = ["x86_64"]
