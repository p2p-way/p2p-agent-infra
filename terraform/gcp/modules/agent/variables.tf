# Labels
variable "default_labels" {
  description = "Labels which should be applied to created resources."
  type        = map(any)
  default = {
    Name    = "P2P"
    Project = "P2P agent"
    Cloud   = "gcp"
  }
}

# Agent
variable "region" {
  description = "The default region to manage resources in."
  type        = string
  default     = "europe-west3"
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

# Global resources
variable "global_network" {
  description = "Whether to create global health check resources."
  type        = map(any)
  default = {
    create = true
    name   = null
  }
}

variable "global_health_check" {
  description = "Whether to create global health check resources."
  type        = map(any)
  default = {
    create = true
    id     = null
  }
}

# Network
variable "ip_cidr_range" {
  description = "The range of internal addresses that are owned by this subnetwork."
  type        = string
  default     = "10.20.30.0/24"
}

variable "allow_ssh" {
  description = "List of IPv4 addresses allowed SSH access to the instance."
  type        = list(string)
  default     = []
}

# Compute
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

variable "machine_type" {
  description = "The machine type to create."
  type        = string
  default     = "e2-micro"
}

variable "disk_type" {
  description = "The GCE disk type."
  type        = string
  default     = "pd-balanced"
}

variable "disk_size_gb" {
  description = "The size of the image in gigabytes. If not specified, it will inherit the size of its base image."
  type        = number
  default     = null
}

variable "unique_iam_roles" {
  description = "Whether to create unique IAM roles names."
  type        = bool
  default     = false
}

variable "initial_deploy" {
  description = "Is this an initial deploy or update."
  type        = bool
  default     = true
}

# Autoscaler
variable "autoscaling_policy_mode" {
  description = "Defines operating mode for this policy."
  type        = string
  default     = "ON"
}

variable "desired_capacity" {
  description = "The number of instances that are available for scaling."
  type        = number
  default     = 1
}

variable "start_time" {
  description = "Time for this action to start. Can be `watcher`, `now`or `custom` in `YYYY-MM-DDThh:mm:ssZ` format in UTC/GMT only (for example, 2014-06-01T00:00:00Z )."
  type        = string
  default     = "now"

  validation {
    condition     = var.start_time != "watcher"
    error_message = "Watcher is not implemented yet, please set value to \"now\" or custom \"YYYY-MM-DDThh:mm:ssZ\" format."
  }
}

variable "start_offset" {
  description = "Time offset which will be added to the `start_time`. Can be specified in `months`, `days`, `hours` and `minutes`."
  type        = string
  default     = "15 minutes"
}

variable "run_duration" {
  description = "How long nodes should be running. Can be specified in `months`, `days`, `hours` and `minutes`."
  type        = string
  default     = "7 days"
}

variable "time_offset_version" {
  description = "Version of the time_offset used for start/stop, when changed triggers new value generation."
  type        = number
  default     = 1
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
