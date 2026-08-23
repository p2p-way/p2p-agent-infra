# Main
variable "folder_id" {
  description = "The folder identifier that resource belongs to."
  type        = string
  default     = null
}

# Common
variable "default_labels" {
  description = "Labels which should be applied to created resources."
  type        = map(any)
  default = {
    Name    = "P2P"
    Project = "P2P agent"
    Cloud   = "yandex"
  }
}

# Agent
variable "region" {
  description = "A region where to run instances."
  type        = string
  default     = "ru-centra1"
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

variable "agent_watcher" {
  description = "Whether to create agent watcher."
  type        = bool
  default     = true
}

variable "agent_logs" {
  description = "Whether to enable agent logs."
  type        = bool
  default     = false
}

variable "agent_metrics" {
  description = "Whether to enable agent metrics."
  type        = bool
  default     = false
}

variable "agent_logs_retention" {
  description = "Log entries retention period for the Yandex Cloud Logging group."
  type        = string
  default     = "168h0m0s"
}

variable "agent_file" {
  description = "Agent file."
  type        = string
  default     = "p2p-agent.sh"
}

variable "agent_meta_file" {
  description = "Agent metadata file."
  type        = string
  default     = "p2p-agent.meta"
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

# Network
variable "cidr_block" {
  description = "The IPv4 CIDR block for the VPC."
  type        = string
  default     = "10.20.30.0/24"
}

variable "az_list" {
  description = "List of availability zones to use for instances launching."
  type        = list(string)
  default     = ["a", "b", "d", "e"]
}

# Firewall
variable "open_ports" {
  description = "Open [TCP-TCP, UDP-UDP] ports. Set null to skip specific protocol or [] to disable rules creation."
  type        = list(any)
  default     = ["1024-65535", "1024-65535"]
}

variable "allow_ssh" {
  description = "List of IPv4 addresses allowed SSH access to the instance."
  type        = list(string)
  default     = []
}

# Instance
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

variable "instance_type" {
  description = "The type of the instance to run."
  type        = string
  default     = "standard-v3"
}

variable "os_volume_type" {
  description = "The disk type."
  type        = string
  default     = "network-ssd"
}

variable "os_volume_size" {
  description = "The size of the disk in GB."
  type        = number
  default     = 10
}

variable "enable_ipv6" {
  description = "Whether to enable IPv6."
  type        = bool
  default     = false
}

# Autoscaling
variable "desired_capacity" {
  description = "The number of instances to run."
  type        = number
  default     = 1
}

variable "start_time" {
  description = "Time for this action to start. Can be `watcher` or `now`."
  type        = string
  default     = "now"
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

# Watcher
variable "watcher_name" {
  description = "Name to be used for watcher resources."
  type        = string
  default     = "P2P watcher"
}

variable "watcher_file" {
  description = "Name of the function file."
  type        = string
  default     = "watcher.py"
}

variable "watcher_runtime" {
  description = "Name of the function runtime."
  type        = string
  default     = "python3.14"
}

variable "watcher_cc_agent_prefix" {
  description = "Control center agent prefix for the watcher."
  type        = string
  default     = "cc-w-a"
}

variable "watcher_cc_scheduler_prefix" {
  description = "Control center scheduler prefix for the watcher."
  type        = string
  default     = "cc-w-s"
}

# Scheduler
variable "scheduler_name" {
  description = "Name to be used for scheduler resources."
  type        = string
  default     = "P2P scheduler"
}

variable "scheduler_expression" {
  description = "Scheduler expression."
  type        = string
  default     = "15 minutes"
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
