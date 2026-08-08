// Module: keyvault
// Pure function of its inputs. RBAC-auth by default; cost-safe defaults for dev.

resource "azurerm_key_vault" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  rbac_authorization_enabled    = var.rbac_authorization_enabled
  enabled_for_disk_encryption   = var.enabled_for_disk_encryption
  tenant_id                     = var.tenant_id
  soft_delete_retention_days    = var.soft_delete_retention_days
  purge_protection_enabled      = var.purge_protection_enabled
  public_network_access_enabled = var.public_network_access_enabled
  sku_name                      = var.sku_name

  tags = var.tags
}


