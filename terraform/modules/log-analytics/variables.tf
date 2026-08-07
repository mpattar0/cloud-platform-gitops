// Module: log-analytics
// Public contract. Required inputs first, then optional with sensible defaults.

# ---------- Required context (every module in this repo takes these 4) ----------

variable "name" {
  description = "Fully-qualified name of the Log Analytics workspace."
  type        = string

  validation {
    condition     = length(var.name) >= 4 && length(var.name) <= 63
    error_message = "Log Analytics workspace name must be 4-63 characters."
  }
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group that will contain the workspace."
  type        = string
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

# ---------- Optional cost/behavior knobs ----------

variable "sku" {
  description = "Log Analytics SKU. PerGB2018 is the only current SKU for new workspaces."
  type        = string
  default     = "PerGB2018"

  validation {
    condition     = contains(["PerGB2018"], var.sku)
    error_message = "Only 'PerGB2018' is supported for new workspaces."
  }
}

variable "retention_in_days" {
  description = "Log retention. 30 days is included in the SKU; beyond that costs per-GB per-day."
  type        = number
  default     = 30

  validation {
    condition     = var.retention_in_days >= 30 && var.retention_in_days <= 730
    error_message = "retention_in_days must be between 30 and 730."
  }
}

variable "daily_quota_gb" {
  description = "Hard cap on daily ingestion (GB). Ingestion pauses on cap; queries still work. -1 disables cap."
  type        = number
  default     = 0.1

  validation {
    condition     = var.daily_quota_gb == -1 || var.daily_quota_gb > 0
    error_message = "daily_quota_gb must be > 0, or -1 to disable the cap."
  }
}

variable "internet_ingestion_enabled" {
  description = "Allow log ingestion over the public internet. Set false in prod + use Private Endpoint."
  type        = bool
  default     = true
}

variable "internet_query_enabled" {
  description = "Allow queries over the public internet. Set false in prod + use Private Endpoint."
  type        = bool
  default     = true
}
