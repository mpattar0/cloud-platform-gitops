// Module: keyvault
// Public contract. Required inputs first, then optional with sensible defaults.

variable "name" {
  description = "Key Vault name. Must be globally unique across Azure."
  type        = string
  # Terraform uses RE2 which doesn't support lookaheads, so we split the check:
  #   1) shape: start letter, 3-24 chars total, letters/digits/hyphens, end alphanumeric
  #   2) no consecutive hyphens
  validation {
    condition = alltrue([
      can(regex("^[a-zA-Z][a-zA-Z0-9-]{1,22}[a-zA-Z0-9]$", var.name)),
      !can(regex("--", var.name)),
    ])
    error_message = "Key Vault name must be 3-24 chars, start with a letter, end alphanumeric, letters/digits/hyphens only, no consecutive hyphens."
  }
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group that will contain the keyvault."
  type        = string
}

variable "tenant_id" {
  description = "The Azure Active Directory tenant ID that should be used for authenticating requests to the Key Vault."
  type        = string
  validation {
    condition     = can(regex("^[0-9a-fA-F-]{36}$", var.tenant_id))
    error_message = "Tenant ID must be a valid UUID."
  }
}

# ---------- Optional cost/behavior knobs ----------
variable "sku_name" {
  description = "The SKU name of the Key Vault. Possible values are: 'standard', 'premium'."
  type        = string
  default     = "standard"
  validation {
    condition     = contains(["standard", "premium"], var.sku_name)
    error_message = "Keyvault SKU name must be either 'standard' or 'premium'."
  }
}

variable "soft_delete_retention_days" {
  description = "The number of days that the Key Vault will retain deleted vaults and objects. Possible values are between 7 and 90 days."
  type        = number
  default     = 7
  validation {
    condition     = var.soft_delete_retention_days >= 7 && var.soft_delete_retention_days <= 90
    error_message = "Keyvault soft delete retention days must be between 7 and 90."
  }
}

variable "purge_protection_enabled" {
  description = "Specifies whether purge protection is enabled for this Key Vault. Possible values are true or false."
  type        = bool
  default     = false
}

variable "enabled_for_disk_encryption" {
  description = "Specifies whether Azure Disk Encryption is permitted with this Key Vault. Possible values are true or false."
  type        = bool
  default     = false
}

variable "rbac_authorization_enabled" {
  description = "Specifies whether RBAC authorization is enabled for this Key Vault. Possible values are true or false."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply. Must include the 5 mandatory tags (env, workload, owner, costCenter, managedBy)."
  type        = map(string)
  validation {
    condition = alltrue([
      contains(keys(var.tags), "env"),
      contains(keys(var.tags), "workload"),
      contains(keys(var.tags), "owner"),
      contains(keys(var.tags), "costCenter"),
      contains(keys(var.tags), "managedBy"),
    ])
    error_message = "tags must include: env, workload, owner, costCenter, managedBy."
  }
}

variable "public_network_access_enabled" {
  description = "Specifies whether the Key Vault is accessible via public network. Possible values are true or false."
  type        = bool
  default     = true
}
