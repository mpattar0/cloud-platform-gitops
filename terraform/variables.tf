variable "prefix" {
  description = "Short workload prefix used in CAF names. Lowercase, 3-10 chars."
  type        = string
  default     = "cpgitops"

  validation {
    condition     = can(regex("^[a-z][a-z0-9]{2,9}$", var.prefix))
    error_message = "Prefix must be lowercase, start with a letter, and be 3-10 characters long."
  }
}

variable "location" {
  description = "Azure region for all resources. Restricted to cheap regions."
  type        = string
  default     = "eastus"
  validation {
    condition     = contains(["eastus", "eastus2", "centralus"], var.location)
    error_message = "Location must be one of: eastus, eastus2, centralus."
  }
}

variable "owner" {
  description = "Human owner email/alias for the mandatory 'owner' tag on all resources"
  type        = string
  default     = "Mounesh Pattar"
}

variable "cost_center" {
  description = "Cost center for the mandatory 'costCenter' tag on all resources"
  type        = string
  default     = "learning"
}

variable "github_org" {
  description = "Github org/user that owns the repo (for OIDC objects and github provider)"
  type        = string
  default     = "mpattar0"
}
variable "github_repo" {
  description = "Github repo name (for OIDC objects and github provider)"
  type        = string
  default     = "cloud-platform-gitops"
}
variable "environment" {
  description = "Deployment environment. Drives CAF naming and tags."
  type        = string
  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "Environment must be either 'dev' or 'prod'."
  }
}
