// Module outputs — the "public API" of this module.
// Only expose what callers will actually need. Avoid dumping every attribute.

output "id" {
  description = "Full ARM resource ID of the Log Analytics workspace. Use for diagnostic_setting.log_analytics_workspace_id."
  value       = azurerm_log_analytics_workspace.this.id
}

output "workspace_id" {
  description = "GUID form of the workspace ID. Use for legacy MMA agent connection strings."
  value       = azurerm_log_analytics_workspace.this.workspace_id
}

output "name" {
  description = "Workspace name — useful for cross-references and CLI queries."
  value       = azurerm_log_analytics_workspace.this.name
}

output "primary_shared_key" {
  description = "Primary shared key used by legacy log senders. Sensitive."
  value       = azurerm_log_analytics_workspace.this.primary_shared_key
  sensitive   = true
}
