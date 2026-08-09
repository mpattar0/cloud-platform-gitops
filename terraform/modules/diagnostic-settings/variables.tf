// Module: diagnostic-settings
// Routes platform logs + metrics from one Azure resource into a Log Analytics workspace.
// Generic across resource types — categories are discovered at plan time.

variable "name" {
  description = "Name of the diagnostic setting (unique per target resource)."
  type        = string
  validation {
    condition     = length(var.name) >= 1 && length(var.name) <= 260
    error_message = "Diagnostic setting name must be 1-260 chars."
  }
}

variable "target_resource_id" {
  description = "Full ARM resource ID of the source resource whose logs/metrics we're routing."
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "Full ARM resource ID of the destination Log Analytics workspace."
  type        = string
}
