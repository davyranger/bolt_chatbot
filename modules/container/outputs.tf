output "rg_id" {
  value = data.azurerm_resource_group.rg.id
}

output "uai_principal_id" {
  value = data.azurerm_user_assigned_identity.managed_identity.principal_id
}

output "cg_id" {
  value = data.azurerm_container_registry.example.id
}