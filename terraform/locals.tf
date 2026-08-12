locals {
  # Short region codes -  keep in sync with location allow-list in variable.tf
  region_short_map = {
    eastus    = "eus"
    eastus2   = "eus2"
    centralus = "cus"
  }

  region_short = local.region_short_map[var.location]
  name_suffix  = "${var.prefix}-${var.environment}-${local.region_short}"

  names = {
    resource_group   = "rg-${local.name_suffix}"
    log_analytics    = "log-${local.name_suffix}"
    key_vault        = "kv-${local.name_suffix}"
    app_service_plan = "asp-${local.name_suffix}"
    app_service      = "app-${local.name_suffix}"
    #storage account: 3-24 alphanumeric only, no dashes
    storage_account = lower(replace("st${var.prefix}${var.environment}${local.region_short}", "-", ""))
    vnet            = "vnet-${local.name_suffix}"
  }
  # Mandatory tags
  common_tags = {
    env        = var.environment
    workload   = var.prefix
    owner      = var.owner
    costCenter = var.cost_center
    managedBy  = "terraform"
  }
}

check "key_vault_name_length" {
  assert {
    condition     = length(local.names.key_vault) <= 24
    error_message = "Key Vault name must be 24 characters or less. Current length: ${length(local.names.key_vault)}"
  }
}

check "storage_account_name_length" {
  assert {
    condition     = length(local.names.storage_account) <= 24
    error_message = "Storage Account name must be 24 characters or less. Current length: ${length(local.names.storage_account)}"
  }
}


