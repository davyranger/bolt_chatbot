data "azuread_service_principal" "sp" {
  display_name = "GiHub Actions"
}

data "azurerm_subscription" "current" {
}