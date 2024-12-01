resource "azurerm_role_assignment" "acr_pull" {
  principal_id         = var.user_assigned_id
  role_definition_name = "AcrPull"
  scope                = var.resource_group
}

resource "azurerm_container_group" "example" {
  name                = "boltslackbotgroup"
  location            = "australiaeast"
  resource_group_name = "slack-bot-rg"
  os_type             = "Linux"

  identity {
    type         = "UserAssigned"
    identity_ids = "/subscriptions/${var.azure_subscription_id}/resourceGroups/slack-bot-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/slackbot-identity"
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
    user_assigned_identity_id = "/subscriptions/54d76c1b-a9fe-4b89-93cb-2585ce0dacb9/resourceGroups/slack-bot-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/slackbot-identity"
    server                    = "boltslackbotacr.azurecr.io"
  }
}