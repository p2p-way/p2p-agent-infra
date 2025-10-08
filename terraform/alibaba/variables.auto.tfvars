# Common
default_tags = {
  Name    = "P2P"
  Project = "P2P agent"
  Cloud   = "aliyun"
}

# Agent
agent_create                  = true
agent_name                    = "P2P agent"
agent_watcher                 = true
agent_logs                    = false
agent_metrics                 = false
agent_logs_retention          = 7
agent_p2p_archivist_ports     = [8090, 8090]
agent_p2p_ipfs_ports          = [4001, 4001]
agent_p2p_radicle_ports       = [8776, null]
agent_p2p_ton_ports           = [null, 3333]
agent_p2p_torrent_ports       = [2345, 2345]
agent_custom_ports            = []
cidr_block                    = "10.20.30.0/24"
az_number                     = 3
allow_ssh                     = []
public_keys                   = []
os_name                       = "ubuntu"
instance_type                 = "ecs.e-c1m1.large" # ecs.t6-c1m1.large, ecs.u1-c1m1.large
instance_charge_type          = "PostPaid"
internet_charge_type          = "PayByBandwidth"
internet_max_bandwidth_in     = 5
internet_max_bandwidth_out    = 5
system_disk_category          = "cloud_essd"
system_disk_size              = 20
system_disk_performance_level = null
initial_deploy                = true
desired_capacity              = 1
start_time                    = "now"
start_offset                  = "15 minutes"
run_duration                  = "7 days"
time_offset_version           = 1
agent_cron_schedule           = "*/15"
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
