# Account
variable "account_name" {
  description = "Name of the account. Should be used when user has access to multple Cloudflare accounts."
  type        = string
  default     = null
}

# Radar
variable "radar_create" {
  description = "Whether to create radar."
  type        = bool
  default     = true
}

variable "radar_domain_name" {
  description = "Cloudflare domain name for radar."
  type        = string
  default     = null
}

variable "radar_name" {
  description = "Name to be used for radar resources."
  type        = string
  default     = "P2P radar"
}

variable "radar_prefix" {
  description = "Radar name prefix. By default a random value be generated."
  type        = string
  default     = null
}

variable "radar_prefix_version" {
  description = "Version of the radar_prefix, when changed triggers new value generation."
  type        = number
  default     = 1
}

variable "radar_auth" {
  description = "Where to enable authentication on radar."
  type        = bool
  default     = true
}

variable "radar_auth_version" {
  description = "Version of the radar_auth, when changed triggers new value generation."
  type        = number
  default     = 1
}

variable "radar_file" {
  description = "The name of the main module in the modules array."
  type        = string
  default     = "radar.js"
}
