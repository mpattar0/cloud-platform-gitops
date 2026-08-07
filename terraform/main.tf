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


