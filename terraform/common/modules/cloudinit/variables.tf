# Cloud-init
variable "gzip" {
  description = "Whether to enable gzip compression."
  type        = bool
  default     = true
}

variable "base64_encode" {
  description = "Whether to enable base64 encoding."
  type        = bool
  default     = true
}

# Agent
variable "public_keys" {
  description = "SSH public keys to be added to the instance."
  type        = list(string)
  default     = []
}

variable "agent_repository_ssh_key" {
  description = "Agent repository SSH private key."
  type        = string
  default     = null
}

variable "agent_file" {
  description = "Agent file."
  type        = string
  default     = "p2p-agent.sh"
}

variable "agent_meta_file" {
  description = "Agent metadata file."
  type        = string
  default     = null
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

#
variable "cloud_config_files" {
  description = "Cloudinit text/cloud-config files."
  type        = list(any)
  default     = []
}

variable "shellscript_files" {
  description = "Cloudinit text/x-shellscript files."
  type        = list(any)
  default     = []
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
