resource "azurerm_role_assignment" "acr_pull" {
  principal_id         = azurerm_user_assigned_identity.managed_identity.id
  role_definition_name = "AcrPull"
  scope                = var.resource_group_id
}

resource "azurerm_user_assigned_identity" "managed_identity" {
  name                = "slackbot-identity"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
}

resource "azurerm_container_group" "example" {
  name                = "boltslackbotgroup"
  location            = "australiaeast"
  resource_group_name = "slack-bot-rg"
  os_type             = "Linux"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.managed_identity.id]
  }

  container {
    name   = "boltslackbot"
    image  = "boltslackbotacr.azurecr.io/slack-bot:latest"
    cpu    = "1.0"
    memory = "1.5"

    ports {
      port = 80
    }

    environment_variables = {
      SLACK_BOT_TOKEN = var.slack_bot_token
      SLACK_APP_TOKEN = var.slack_app_token
    }
  }

  image_registry_credential {
    user_assigned_identity_id = azurerm_user_assigned_identity.managed_identity.id
    server                    = "boltslackbotacr.azurecr.io"
  }
}