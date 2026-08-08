// Module outputs — minimal public API.

output "id" {
  description = "Full ARM resource ID of the Key Vault. Use for RBAC scope + diagnostic settings."
  value       = azurerm_key_vault.this.id
}

output "name" {
  description = "Name of the Key Vault."
  value       = azurerm_key_vault.this.name
}

output "vault_uri" {
  description = "DNS URI of the Key Vault (used by client applications)."
  value       = azurerm_key_vault.this.vault_uri
}


