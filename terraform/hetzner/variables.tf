# Labels
variable "default_labels" {
  description = "Labels which should be applied to created resources."
  type        = map(any)
  default = {
    Name    = "P2P"
    Project = "P2P agent"
    Cloud   = "hetzner"
  }
}

# Agent
variable "location" {
  description = "Name of the Location."
  type        = string
  default     = "fsn1"
}

variable "agent_create" {
  description = "Whether to create agent."
  type        = bool
  default     = true
}

variable "agent_name" {
  description = "Name to be used for agent resources."
  type        = string
  default     = "P2P agent"
}

variable "agent_file" {
  description = "Agent file."
  type        = string
  default     = "p2p-agent.sh"
}

variable "agent_base_folder" {
  description = "Agent base folder."
  type        = string
  default     = "/opt/p2p"
}

variable "agent_log_file" {
  description = "Agent log file name."
  type        = string
  default     = "p2p-agent.log"
}

variable "agent_p2p_archivist_ports" {
  description = "P2P agent Archivist [TCP, UDP] ports. Set null to skip specific protocol or [] to disable rules creation."
  type        = list(any)
  default     = [8090, 8090]
}

variable "agent_p2p_ipfs_ports" {
  description = "P2P agent IPFS [TCP, UDP] ports. Set null to skip specific protocol or [] to disable rules creation."
  type        = list(any)
  default     = [4001, 4001]
}

variable "agent_p2p_radicle_ports" {
  description = "P2P agent Radicle [TCP, UDP] ports. Set null to skip specific protocol or [] to disable rules creation."
  type        = list(any)
  default     = [8776, null]
}

variable "agent_p2p_ton_ports" {
  description = "P2P agent TON [TCP, UDP] ports. Set null to skip specific protocol or [] to disable rules creation."
  type        = list(any)
  default     = [null, 3333]
}

variable "agent_p2p_torrent_ports" {
  description = "P2P agent Torrent [TCP, UDP] ports. Set null to skip specific protocol or [] to disable rules creation."
  type        = list(any)
  default     = [2345, 2345]
}

variable "agent_custom_ports" {
  description = "P2P agent custom [TCP-TCP, UDP-UDP] ports. Set null to skip specific protocol or [] to disable rules creation."
  type        = list(any)
  default     = []
}

# Firewall
variable "allow_ssh" {
  description = "List of IPv4 addresses allowed SSH access to the instance."
  type        = list(string)
  default     = []
}

# Servers
variable "public_keys" {
  description = "SSH public keys to be added to the instance."
  type        = list(string)
  default     = []
}

variable "os_name" {
  description = "OS name."
  type        = string
  default     = "ubuntu"
}

variable "server_type" {
  description = "Name of the server type this server should be created with."
  type        = string
  default     = "cpx11"
}

variable "desired_capacity" {
  description = "Number of servers to create."
  type        = number
  default     = 1
}

variable "enable_ipv6" {
  description = "Whether to enable IPv6."
  type        = bool
  default     = true
}

# P2P
variable "agent_cron_schedule" {
  description = "Agent cron schedule."
  type        = string
  default     = "*/15 * * * *"
}

variable "agent_commands" {
  description = "Whether to enable agent command."
  type        = map(bool)
  default = {
    CC       = true
    POST_RUN = true
    PRE_RUN  = true
  }
}

variable "agent_commands_defaults" {
  description = "Agent commands default values."
  type        = map(any)
  default = {
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
}

variable "agent_cc_hosts" {
  description = "Control center hosts for the agent."
  type        = list(string)
  default     = ["https://d2d0z7lax5amc3.cloudfront.net"]
}

variable "agent_cc_commands" {
  description = "Control center commands for the agent."
  type        = string
  default     = "delay desired-capacity force-run main-run post-run pre-run repository type"
}

variable "agent_cc_commands_prefix" {
  description = "Control center commands prefix for the agent."
  type        = string
  default     = "cc-a"
}

variable "agent_repository_ssh_key" {
  description = "Agent repository SSH private key."
  type        = string
  default     = null
}
