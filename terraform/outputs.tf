output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.rg.name
}

output "resource_group_id" {
  description = "Full resource ID of the main resource group (used for RBAC scoping)."
  value       = azurerm_resource_group.rg.id
}

output "location" {
  description = "Azure region for all resources."
  value       = var.location
}

output "common_tags" {
  description = "Mandatory tags applied to all resources."
  value       = local.common_tags
}

output "log_analytics_id" {
  description = "ARM ID of the Log Analytics workspace."
  value       = module.log_analytics.id
}

output "log_analytics_workspace_id" {
  description = "GUID form of the Log Analytics workspace ID."
  value       = module.log_analytics.workspace_id
}

output "log_analytics_name" {
  description = "Name of the Log Analytics workspace."
  value       = module.log_analytics.name
}
