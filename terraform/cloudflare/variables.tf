# Main
variable "cc_create" {
  description = "Whether to create control center."
  type        = bool
  default     = true
}

# Account
variable "account_name" {
  description = "Name of the account. Should be used when user has a ccess to multple Cloudflare accounts."
  type        = string
  default     = null
}

# DNS
variable "domain_name" {
  description = "Cloudflare domain name."
  type        = string
}

# Control center
variable "cc_name" {
  description = "Name to be used for control center resources."
  type        = string
  default     = "P2P control center"
}

variable "cc_commands" {
  description = "Map of the control center commands."
  type        = map(any)
  default = {
    cc-a-delay            = 60
    cc-a-desired-capacity = "-"
    cc-a-force-run        = "false"
    cc-a-main-run         = "ansible/playbook.yml"
    cc-a-pre-run          = "echo \"Start: $(date)\""
    cc-a-post-run         = "echo \"Finish: $(date)\""
    cc-a-repository       = "https://github.com/p2p-way/p2p-agent-infra"
    cc-a-type             = "ansible"
  }
}

variable "cc_prefix" {
  description = "Control center name prefix. By default a random one will be generated."
  type        = string
  default     = null
}

variable "cc_prefix_version" {
  description = "Version of the cc_prefix, when changed triggers new value generation."
  type        = number
  default     = 1
}

# R2
variable "bucket_jurisdiction" {
  description = "Jurisdiction where objects in this bucket are guaranteed to be stored. Available values: 'default', 'eu', 'fedramp'."
  type        = string
  default     = "default"
}

variable "bucket_location" {
  description = "Location of the bucket. Available values: 'apac', 'eeur', 'enam', 'weur', 'wnam', 'oc'."
  type        = string
  default     = null
}

variable "bucket_suffix_version" {
  description = "Version of the bucket suffix, when changed triggers new value generation."
  type        = number
  default     = 1
}
