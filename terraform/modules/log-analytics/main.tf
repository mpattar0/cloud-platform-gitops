// Module: log-analytics
// Manages a single Azure Log Analytics workspace with cost-safe defaults.

resource "azurerm_log_analytics_workspace" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  sku               = var.sku
  retention_in_days = var.retention_in_days
  daily_quota_gb    = var.daily_quota_gb

  internet_ingestion_enabled = var.internet_ingestion_enabled
  internet_query_enabled     = var.internet_query_enabled

  tags = var.tags
}
