# Main
create_compartment = false

# Common
default_tags = {
  Name    = "P2P"
  Project = "P2P agent"
  Cloud   = "oci"
}

# Agent
region              = "eu-frankfurt-1"
agent_create        = true
agent_name          = "P2P agent"
agent_logs          = false
agent_metrics       = false
cidr_blocks         = ["10.20.30.0/24"]
ad_number           = 3
open_ports          = ["1024-65535", "1024-65535"]
allow_ssh           = []
public_keys         = []
os_name             = "ubuntu"
instance_type       = "VM.Standard.A4.Flex:1:2" # "VM.Standard.E6.Flex"
os_volume_size      = null
os_volume_perf      = null
initial_deploy      = true
desired_capacity    = 1
start_time          = "now"
start_offset        = "15 minutes"
run_duration        = "7 days"
time_offset_version = 1
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
