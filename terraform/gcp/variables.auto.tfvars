# Labels
default_labels = {
  Name    = "P2P"
  Project = "P2P agent"
  Cloud   = "gcp"
}

# Agent
region                  = "europe-west3"
agent_create            = true
agent_name              = "P2P agent"
agent_watcher           = true
agent_logs              = false
agent_metrics           = false
agent_open_ports        = ["1024-65535", "1024-65535"]
global_network          = { "create" : true }
global_health_check     = { "create" : true }
ip_cidr_range           = "10.128.0.0/9"
allow_ssh               = []
public_keys             = []
os_name                 = "ubuntu"
machine_type            = "e2-micro"
disk_type               = "pd-balanced"
disk_size_gb            = null
unique_iam_roles        = false
initial_deploy          = true
autoscaling_policy_mode = "ON"
desired_capacity        = 1
start_time              = "now"
start_offset            = "15 minutes"
run_duration            = "7 days"
time_offset_version     = 1
agent_cron_schedule     = "*/30"
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
