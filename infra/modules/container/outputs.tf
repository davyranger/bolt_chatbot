output "rg_id" {
  value = azurerm_resource_group.rg.id
}

output "uai_id" {
  value = azurerm_user_assigned_identity.managed_identity.id
}

output "cg_id" {
  value = azurerm_container_registry.example.id
}