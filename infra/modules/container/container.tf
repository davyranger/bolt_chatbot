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

resource "null_resource" "docker_build_push" {
  provisioner "local-exec" {
    command = <<EOT
      az login --service-principal -u "$AZURE_CLIENT_ID" -p "$AZURE_CLIENT_SECRET" --tenant "$AZURE_TENANT_ID"
      az account set --subscription "$AZURE_SUBSCRIPTION_ID"
      az acr login --name boltslackbotacr
      docker build \
        --build-arg SLACK_BOT_TOKEN="$SLACK_BOT_TOKEN" \
        --build-arg SLACK_APP_TOKEN="$SLACK_APP_TOKEN" \
        -t boltslackbotacr.azurecr.io/slack-bot:latest ./infra/modules/container
      docker push boltslackbotacr.azurecr.io/slack-bot:latest
    EOT
    environment = {
      AZURE_CLIENT_ID        = var.azure_client_id
      AZURE_CLIENT_SECRET    = var.azure_client_secret
      AZURE_TENANT_ID        = var.azure_tenant_id
      AZURE_SUBSCRIPTION_ID  = var.azure_subscription_id
      SLACK_BOT_TOKEN        = var.slack_bot_token
      SLACK_APP_TOKEN        = var.slack_app_token
    }
  }

  depends_on = [
    azurerm_container_registry.example
  ]
}
