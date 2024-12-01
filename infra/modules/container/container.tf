resource "azurerm_resource_group" "rg" {
  name     = "slack-bot-rg"  # Name of the resource group
  location = "australiaeast" # Azure region where the resource group is located
}

resource "azurerm_user_assigned_identity" "managed_identity" {
  name                = "slackbot-identity"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_container_registry" "example" {
  name                = "boltslackbotacr"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Standard"
}