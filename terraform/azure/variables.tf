# Tags
variable "default_tags" {
  description = "Tags which should be applied to created resources."
  type        = map(any)
  default = {
    Name    = "P2P"
    Project = "P2P agent"
    Cloud   = "azure"
  }
}

# Agent
variable "region" {
  description = "The Azure Region where the Resource Group should exist."
  type        = string
  default     = "Germany West Central"
}

variable "rg_region" {
  description = "The Azure Region where the resource should exist."
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
  description = "The workspace data retention in days."
  type        = number
  default     = 30
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

# VN
variable "address_space" {
  description = "The address space that is used the virtual network."
  type        = list(string)
  default     = ["10.20.30.0/24"]
}

variable "address_prefixes" {
  description = "The address prefixes to use for the subnet."
  type        = list(string)
  default     = ["10.20.30.0/24"]
}

variable "allow_ssh" {
  description = "List of IPv4 addresses allowed SSH access to the instance."
  type        = list(string)
  default     = []
}

# VM
variable "public_keys" {
  description = "SSH public keys to be added to the instance."
  type        = list(string)
  default     = []
}

variable "admin_username" {
  description = "The username of the local administrator on each Virtual Machine Scale Set instance."
  type        = string
  default     = "ubuntu"
}

variable "zone" {
  description = "Specifies a list of Availability Zones in which this Linux Virtual Machine Scale Set should be located."
  type        = list(number)
  default     = [1, 2, 3]
}

variable "sku" {
  description = "The Virtual Machine SKU for the Scale Set."
  type        = string
  default     = "Standard_B1s"
}

variable "os_name" {
  description = "OS name."
  type        = string
  default     = "ubuntu"
}

variable "os_disk_size_gb" {
  description = "The size of the Data Disk which should be created."
  type        = number
  default     = null
}

variable "os_storage_account_type" {
  description = "The Type of Storage Account which should back this Data Disk."
  type        = string
  default     = "StandardSSD_LRS"
}

variable "os_caching" {
  description = "The Type of Caching which should be used for the Internal OS Disk."
  type        = string
  default     = "ReadOnly"
}

variable "initial_deploy" {
  description = "Is this an initial deploy or update."
  type        = bool
  default     = true
}

# Monitor Autoscale setting
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
