# Agent
variable "region" {
  description = "The region where the Droplet will be created."
  type        = string
  default     = "fra1"
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

variable "agent_open_ports" {
  description = "P2P agent open [TCP-TCP, UDP-UDP] ports. Set null to skip specific protocol or [] to disable rules creation."
  type        = list(any)
  default     = ["1024-65535", "1024-65535"]
}

# Firewall
variable "allow_ssh" {
  description = "List of IPv4 addresses allowed SSH access to the instance."
  type        = list(string)
  default     = []
}

# Servers
variable "ssh_keys" {
  description = "A list of SSH key IDs or fingerprints to enable in the format [12345, 123456]."
  type        = list(string)
  default     = []
}

variable "os_name" {
  description = "OS name."
  type        = string
  default     = "ubuntu"
}

variable "droplet_size" {
  description = "The instance size."
  type        = string
  default     = "s-1vcpu-1gb"
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
