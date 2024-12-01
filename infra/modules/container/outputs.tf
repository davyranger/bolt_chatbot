output "rg_id" {
  value = azurerm_resource_group.rg.id
}

output "uai_principal_id" {
  value = azurerm_user_assigned_identity.managed_identity.principal_id
}

output "uai_client_id" {
  value = azurerm_user_assigned_identity.managed_identity.client_id
}

output "cg_id" {
  value = azurerm_container_registry.example.id
}