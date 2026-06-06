# Tags
variable "default_tags" {
  description = "Tags which should be applied to all created resources."
  type        = map(any)
  default = {
    Name    = "P2P"
    Project = "P2P agent"
    Cloud   = "scaleway"
  }
}

# Agent
variable "region" {
  description = "The zone in which the server should be created."
  type        = string
  default     = "nl-ams-1"
}

variable "project_id" {
  description = "The ID of the project the resources will be associated with."
  type        = string
  default     = null
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
variable "type" {
  description = "The commercial type of the server."
  type        = string
  default     = "STARDUST1-S"
}

variable "os_name" {
  description = "OS name."
  type        = string
  default     = "ubuntu"
}

variable "os_disk_size" {
  description = "Size of the root volume in gigabytes."
  type        = number
  default     = null
}

variable "os_disk_type" {
  description = "Volume type of root volume, can be l_ssd or sbs_volume, default value depends on server type."
  type        = string
  default     = null
}

variable "os_disk_sbs_iops" {
  description = "Choose IOPS of your sbs volume, has to be used with sbs_volume for root volume type."
  type        = number
  default     = null
}

variable "desired_capacity" {
  description = "Number of the instances to run."
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
    DEFAULT_REPOSITORY_RADICLE = "rad:z3yXqAJjHXxqJ8ChJezGZRdkvU27"
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

# Radar
variable "radar_url" {
  description = "Radar URL."
  type        = list(any)
  default     = []
}

variable "radar_url_file" {
  description = "Radar URL file."
  type        = string
  default     = "p2p-radar.url"
}
