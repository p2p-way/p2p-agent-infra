# Main
variable "tenancy_ocid" {
  description = "Tenancy OCID. It is used as a compartment or to create a child one."
  type        = string
  default     = null
}

variable "create_compartment" {
  description = "Where to create a separate compartment for resources."
  type        = bool
  default     = true
}

# Tags
variable "default_tags" {
  description = "Tags which should be applied to created resources."
  type        = map(any)
  default = {
    Name    = "P2P"
    Project = "P2P agent"
    Cloud   = "oci"
  }
}

# Agent
variable "region" {
  description = "A region where to run instances."
  type        = string
  default     = "eu-frankfurt-1"
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

# Network
variable "cidr_blocks" {
  description = "The list of one or more IPv4 CIDR blocks for the VCN."
  type        = list(string)
  default     = ["10.20.30.0/24"]
}

variable "ad_number" {
  description = "Number of availability domains to use for instances launching."
  type        = number
  default     = 3
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

# Instances
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
  default     = "VM.Standard.A4.Flex"
}

variable "os_volume_size" {
  description = "The size of the boot volume in GBs. The minimum value is 50 GB and the maximum value is 32,768 GB (32 TB)."
  type        = number
  default     = null
}

variable "os_volume_perf" {
  description = "The number of volume performance units (VPUs) that will be applied to this volume per GB, representing the Block Volume service's elastic performance options. Allowed values: 10, 20, 30-120."
  type        = number
  default     = null
}

variable "enable_ipv6" {
  description = "Whether to enable IPv6."
  type        = bool
  default     = false
}
variable "min_size" {
  description = "Min number of Amazon EC2 instances that should be running in the group."
  type        = number
  default     = 0
}

variable "max_size" {
  description = "Max number of Amazon EC2 instances that should be running in the group."
  type        = number
  default     = 30
}

# Autoscaling
variable "initial_deploy" {
  description = "Is this an initial deploy or update."
  type        = bool
  default     = true
}

variable "desired_capacity" {
  description = "Number of instances to run."
  type        = number
  default     = 1
}

variable "start_time" {
  description = "Time for this action to start. Can be `watcher`, `now`or `custom` in `YYYY-MM-DDThh:mm:ssZ` format in UTC/GMT only (for example, 2014-06-01T00:00:00Z )."
  type        = string
  default     = "now"
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
