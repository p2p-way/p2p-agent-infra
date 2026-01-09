# Common
default_tags = {
  Name    = "P2P"
  Project = "P2P agent"
  Cloud   = "azure"
}

# Agent
region                  = "Germany West Central"
agent_create            = true
agent_name              = "P2P agent"
agent_watcher           = true
agent_logs              = false
agent_metrics           = false
agent_logs_retention    = 30
agent_open_ports        = ["1024-65535", "1024-65535"]
address_space           = ["10.20.30.0/24"]
address_prefixes        = ["10.20.30.0/24"]
allow_ssh               = []
public_keys             = []
admin_username          = "ubuntu"
zone                    = [1, 2, 3]
sku                     = "Standard_B1s" # Standard_B2ats_v2, Standard_B2ts_v2
os_name                 = "ubuntu"
os_disk_size_gb         = null
os_storage_account_type = "StandardSSD_LRS"
os_caching              = "ReadOnly"
initial_deploy          = true
desired_capacity        = 1
start_time              = "now"
start_offset            = "15 minutes"
run_duration            = "7 days"
time_offset_version     = 1
agent_cron_schedule     = "*/15"
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
