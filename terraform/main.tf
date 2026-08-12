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
module "diag_kv" {
  source = "./modules/diagnostic-settings"

  name                       = "diag-${module.keyvault.name}"
  target_resource_id         = module.keyvault.id
  log_analytics_workspace_id = module.log_analytics.id
}

module "vnet" {
  source = "./modules/vnet"

  name                = local.names.vnet
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.10.0.0/16"]
  tags                = local.common_tags

  subnets = {
    app = {
      address_prefixes = ["10.10.1.0/24"]
    }
    data = {
      address_prefixes = ["10.10.2.0/24"]
      nsg_rules = [
        {
          name                       = "deny-all-inbound"
          priority                   = 4000
          direction                  = "Inbound"
          access                     = "Deny"
          protocol                   = "*"
          destination_port_range     = "*"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        }
      ]
    }
  }
}
