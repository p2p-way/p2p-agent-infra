# Agent
region                    = "fra1"
agent_create              = true
agent_name                = "P2P agent"
agent_p2p_archivist_ports = [8090, 8090]
agent_p2p_ipfs_ports      = [4001, 4001]
agent_p2p_radicle_ports   = [8776, null]
agent_p2p_ton_ports       = [null, 3333]
agent_p2p_torrent_ports   = [2345, 2345]
agent_custom_ports        = []
allow_ssh                 = []
public_keys               = []
os_name                   = "ubuntu"
droplet_size              = "s-1vcpu-1gb" # s-1vcpu-1gb-intel, s-1vcpu-1gb-amd
desired_capacity          = 1
enable_ipv6               = false
agent_cron_schedule       = "*/15"
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
