resource "azurerm_resource_group" "rg" {
  name     = local.names.resource_group
  location = var.location
  tags     = local.common_tags
}

module "log_analytics" {
  source = "./modules/log-analytics"

  name                = local.names.log_analytics
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = local.common_tags
}

data "azurerm_client_config" "current" {}

module "keyvault" {
  source              = "./modules/keyvault"
  name                = local.names.key_vault
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  tags                = local.common_tags
}

module "diag_rg" {
  source = "./modules/diagnostic-settings"

  name                       = "diag-${azurerm_resource_group.rg.name}"
  target_resource_id         = azurerm_resource_group.rg.id
  log_analytics_workspace_id = module.log_analytics.id
}

module "diag_kv" {
  source = "./modules/diagnostic-settings"

  name                       = "diag-${module.keyvault.name}"
  target_resource_id         = module.keyvault.id
  log_analytics_workspace_id = module.log_analytics.id
}
