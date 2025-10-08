# Control center
variable "cc_create" {
  description = "Whether to create control center."
  type        = bool
  default     = true
}

# Suffix
variable "cc_suffix_version" {
  description = "Control center version of the random suffix, when changed triggers new suffix generation."
  type        = number
  default     = 1
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
