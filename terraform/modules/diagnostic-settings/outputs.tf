// Module outputs — minimal public API.

output "id" {
  description = "Full ARM resource ID of the diagnostic setting."
  value       = azurerm_monitor_diagnostic_setting.this.id
}
