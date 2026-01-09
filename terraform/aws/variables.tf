# Provider
variable "skip_credentials_validation" {
  description = "Whether to skip credentials validation via the STS API."
  type        = bool
  default     = false
}

variable "skip_requesting_account_id" {
  description = "Whether to skip requesting the account ID."
  type        = bool
  default     = false
}

# Tags
variable "default_tags" {
  description = "Tags which should be applied to all created resources."
  type        = map(any)
  default = {
    Name    = "P2P"
    Project = "P2P agent"
    Cloud   = "aws"
  }
}

# Control center
variable "cc_create" {
  description = "Whether to create control center."
  type        = bool
  default     = true
}

# Common
variable "cc_name" {
  description = "Name to be used for control center resources."
  type        = string
  default     = "P2P control center"
}

# CloudFront
variable "cc_commands" {
  description = "Map of the control center commands."
  type        = map(any)
  default = {
    cc-w-scheduler          = "*/10 * * * *"
    cc-w-a-desired-capacity = 1
    cc-w-a-start            = "2022-11-28T13:00:00Z"
    cc-w-a-start-offset     = "15 minutes"
    cc-w-a-stop             = "2022-12-05T13:00:00Z"
    cc-a-delay              = 60
    cc-a-desired-capacity   = "-"
    cc-a-force-run          = "false"
    cc-a-main-run           = "ansible/playbook.yml"
    cc-a-pre-run            = "echo \"Start: $(date)\""
    cc-a-post-run           = "echo \"Finish: $(date)\""
    cc-a-repository         = "https://github.com/p2p-way/p2p-agent-infra"
    cc-a-type               = "ansible"
  }
}

# WAF
variable "waf_enable" {
  description = "Whether to enable WAF."
  type        = bool
  default     = false
}

variable "waf_rate_limit" {
  description = "WAF rate limit per IP during 5 minutes."
  type        = number
  default     = 1000
}

variable "waf_logs_enable" {
  description = "Whether to enable WAF logs."
  type        = bool
  default     = false
}

# Agent
variable "region" {
  description = "Region where this resource will be managed."
  type        = string
  default     = "eu-central-1"
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
  description = "Specifies the number of days you want to retain log events in the specified log group."
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
  description = "The IPv4 CIDR block for the VPC."
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
  description = "The type of the instance."
  type        = string
  default     = "t3.micro"
}

variable "volume_size" {
  description = "The size of the volume in gigabytes."
  type        = number
  default     = null
}

variable "volume_type" {
  description = "The type of volume."
  type        = string
  default     = null
}

variable "volume_iops" {
  description = "The amount of provisioned IOPS."
  type        = number
  default     = null
}

variable "volume_throughput" {
  description = "The throughput to provision for a gp3 volume in MiB/s."
  type        = number
  default     = null
}

# Auto Scaling group
variable "initial_deploy" {
  description = "Is this an initial deploy or update."
  type        = bool
  default     = true
}

variable "desired_capacity" {
  description = "Number of Amazon EC2 instances that should be running in the group."
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

# Watcher
variable "watcher_name" {
  description = "Name to be used for watcher resources."
  type        = string
  default     = "P2P watcher"
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
  default     = "rate(15 minutes)"
}

variable "lambda_architecture" {
  description = "Lambda function architecture."
  type        = list(any)
  default     = ["x86_64"]
}
