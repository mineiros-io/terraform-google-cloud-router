# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED VARIABLES
# These variables must be set when using this module.
# ---------------------------------------------------------------------------------------------------------------------

variable "region" {
  description = "(Required) The region to host the VPC and all related resources in."
  type        = string
}

variable "network" {
  description = "(Required) A reference to the network to which this router belongs."
  type        = string
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL VARIABLES
# These variables have defaults, but may be overridden.
# ---------------------------------------------------------------------------------------------------------------------

variable "project" {
  description = "(Optional) The ID of the project in which the resource belongs. If it is not set, the provider project is used."
  type        = string
  default     = null
}

variable "name" {
  description = "(Optional) Name of the resource. The name must be 1-63 characters long, and comply with RFC1035. Specifically, the name must be 1-63 characters long and match the regular expression '[a-z]([-a-z0-9]*[a-z0-9])?' which means the first character must be a lowercase letter, and all following characters must be a dash, lowercase letter, or digit, except the last character, which cannot be a dash. Default is 'main'."
  type        = string
  default     = "main"

  validation {
    condition     = can(regex("[a-z]([-a-z0-9]*[a-z0-9])?", var.name)) && length(var.name) >= 1 && length(var.name) <= 64
    error_message = "The name must be 1-63 characters long and match the regular expression \"[a-z]([-a-z0-9]*[a-z0-9])?\" which means the first character must be a lowercase letter, and all following characters must be a dash, lowercase letter, or digit, except the last character, which cannot be a dash."
  }
}

# Type: object, with fields:
# - asn (string, required): Local BGP Autonomous System Number (ASN).
# - advertised_groups (list(string), optional): User-specified list of prefix groups to advertise.
# - advertised_ip_ranges (list(object), optional): User-specified list of individual IP ranges to advertise.
#   - range (string, required): The IP range to advertise.
#   - description (string, optional): User-specified description for the IP range.
variable "bgp" {
  description = "(Optional) BGP information specific to this router. Default is 'null'."
  type        = any
  default     = null

  #
  # type = {
  #   asn = string
  #   advertised_groups = list(string)
  #   advertised_ip_ranges = list(object({
  #     range       = string
  #     description = string
  #   }))
  # }
  #

  validation {
    condition     = var.bgp != null ? can(regex("\\d+", var.bgp.asn)) : true
    error_message = "The Local BGP Autonomous System Number (ASN) must be an RFC6996 private ASN, either 16-bit or 32-bit. The value will be fixed for this router resource. All VPN tunnels that link to this router will have the same local ASN."
  }

}

# Type: list(object), with fields:
# - name (string, required): Name of the NAT.
# - nat_ip_allocate_option (string, optional): How external IPs should be allocated for this NAT. Defaults to MANUAL_ONLY if nat_ips are set, else AUTO_ONLY.
# - source_subnetwork_ip_ranges_to_nat (string, optional): How NAT should be configured per Subnetwork. Defaults to ALL_SUBNETWORKS_ALL_IP_RANGES.
# - nat_ips (list(number), optional): Self-links of NAT IPs.
# - min_ports_per_vm (number, optional): Minimum number of ports allocated to a VM from this NAT.
# - udp_idle_timeout_sec (number, optional): Timeout (in seconds) for UDP connections. Defaults to 30s if not set.
# - icmp_idle_timeout_sec (number, optional): Timeout (in seconds) for ICMP connections. Defaults to 30s if not set.
# - tcp_established_idle_timeout_sec (number, optional): Timeout (in seconds) for TCP established connections. Defaults to 1200s if not set.
# - tcp_transitory_idle_timeout_sec (number, optional): Timeout (in seconds) for TCP transitory connections. Defaults to 30s if not set.
# - log_config (object, optional):
#    - filter: Specifies the desired filtering of logs on this NAT. Defaults to "ALL".
# - subnetworks (list(objects), optional):
#   - name (string, required): Self-link of subnetwork to NAT.
#   - source_ip_ranges_to_nat (string, required): List of options for which source IPs in the subnetwork should have NAT enabled.
#   - secondary_ip_range_names (string, optional): List of the secondary ranges of the subnetwork that are allowed to use NAT.
variable "nats" {
  description = "(Optional) NATs to deploy on this router. Default is '[]'."
  type        = any
  default     = []
}

# ------------------------------------------------------------------------------
# MODULE CONFIGURATION PARAMETERS
# These variables are used to configure the module.
# See https://medium.com/mineiros/the-ultimate-guide-on-how-to-write-terraform-modules-part-1-81f86d31f024
# ------------------------------------------------------------------------------

variable "module_enabled" {
  description = "(Optional) Whether to create resources within the module or not. Default is 'true'."
  type        = bool
  default     = true
}

variable "module_depends_on" {
  description = "(Optional) A list of external resources the module depends_on. Default is '[]'."
  type        = any
  default     = []
}
