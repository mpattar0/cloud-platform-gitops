// Module: Vnet
// Public contract. Required inputs first, then optional with sensible defaults.

# ---------- Required context (every module in this repo takes these 4) ----------

variable "name" {
  description = "Fully-qualified name of the Vnet."
  type        = string

  validation {
    condition     = length(var.name) >= 4 && length(var.name) <= 63
    error_message = "Vnet name must be 4-63 characters."
  }
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group that will contain the Vnet."
  type        = string
}

variable "address_space" {
  description = "Address space for the Vnet."
  type        = list(string)

  validation {
    condition     = length(var.address_space) > 0
    error_message = "At least one address space must be provided."
  }
  validation {
    condition     = alltrue([for cidr in var.address_space : can(cidrhost(cidr, 0))])
    error_message = "All address spaces must be valid CIDR blocks."
  }
}

variable "subnets" {
  description = <<-EOT
    Map of subnets to create. Key = short name (becomes part of resource name).
    Set nsg_rules = null (or omit) to skip NSG creation for that subnet.
  EOT

  type = map(object({
    address_prefixes  = list(string)
    service_endpoints = optional(list(string), [])
    nsg_rules = optional(list(object({
      name                       = string
      priority                   = number
      direction                  = string
      access                     = string
      protocol                   = string
      source_port_range          = optional(string, "*")
      destination_port_range     = optional(string, "*")
      source_address_prefix      = optional(string, "*")
      destination_address_prefix = optional(string, "*")
    })), null)
  }))

  default = {}

  validation {
    condition = alltrue([
      for k, v in var.subnets :
      alltrue([for p in v.address_prefixes : can(cidrhost(p, 0))])
    ])
    error_message = "Every subnet address_prefix must be a valid CIDR block."
  }
}

variable "tags" {
  description = "Tags applied to all resources created by this module."
  type        = map(string)
  default     = {}

  validation {
    condition = alltrue([
      for k in ["env", "workload", "owner", "costCenter", "managedBy"] :
      contains(keys(var.tags), k)
    ])
    error_message = "tags must include the 5 mandatory keys: env, workload, owner, costCenter, managedBy."
  }
}


