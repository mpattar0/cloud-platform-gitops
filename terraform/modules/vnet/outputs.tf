output "vnet_id" {
  description = "Resource ID of the virtual network."
  value       = azurerm_virtual_network.this.id
}

output "vnet_name" {
  description = "Name of the virtual network."
  value       = azurerm_virtual_network.this.name
}

output "subnet_ids" {
  description = "Map of subnet key => subnet resource ID."
  value       = { for k, s in azurerm_subnet.this : k => s.id }
}

output "nsg_ids" {
  description = "Map of subnet key => NSG resource ID (only for subnets that requested an NSG)."
  value       = { for k, n in azurerm_network_security_group.this : k => n.id }
}
