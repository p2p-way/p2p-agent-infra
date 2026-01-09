# Tags
variable "default_tags" {
  description = "Tags which should be applied to all created resources."
  type        = map(any)
  default = {
    Name    = "P2P"
    Project = "P2P agent"
    Cloud   = "aliyun"
  }
}

# Agent
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
  description = "The data retention time (in days). Valid values: [1-3650]. Default to 30. Log store data will be stored permanently when the value is 3650."
  type        = number
  default     = 7
}

variable "agent_open_ports" {
  description = "P2P agent open [TCP-TCP, UDP-UDP] ports. Set null to skip specific protocol or [] to disable rules creation."
  type        = list(any)
  default     = ["1024-65535", "1024-65535"]
}

# VPC
variable "cidr_block" {
  description = "The CIDR block of the VPC."
  type        = string
  default     = "10.20.30.0/24"
}

variable "az_number" {
  description = "Number of availability zones for subnets creation and instances launching."
  type        = number
  default     = 3
}

variable "allow_ssh" {
  description = "List of IPv4 addresses allowed SSH access to the instance."
  type        = list(string)
  default     = []
}

# Launch template
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
  description = "Instance type."
  type        = string
  default     = "ecs.e-c2m1.large"
}

variable "instance_charge_type" {
  description = "Internet bandwidth billing method. Valid values: PayByTraffic, PayByBandwidth."
  type        = string
  default     = "PostPaid"
}

variable "internet_charge_type" {
  description = "Internet bandwidth billing method. Valid values: PayByTraffic, PayByBandwidth."
  type        = string
  default     = "PayByBandwidth"
}

variable "internet_max_bandwidth_in" {
  description = "The maximum inbound bandwidth from the Internet network, measured in Mbit/s. Value range: [1, 200]."
  type        = number
  default     = 5
}

variable "internet_max_bandwidth_out" {
  description = "Maximum outbound bandwidth from the Internet, its unit of measurement is Mbit/s. Value range: [0, 100]."
  type        = number
  default     = 5
}

variable "system_disk_size" {
  description = "Size of the system disk, measured in GB."
  type        = number
  default     = 20
}

variable "system_disk_category" {
  description = "The category of the system disk."
  type        = string
  default     = "cloud_essd"
}

variable "system_disk_performance_level" {
  description = "The performance level of the ESSD used as the system disk."
  type        = string
  default     = null
}

# Scaling group
variable "initial_deploy" {
  description = "Is this an initial deploy or update."
  type        = bool
  default     = true
}

variable "desired_capacity" {
  description = "Expected number of ECS instances in the scaling group."
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
