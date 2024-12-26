resource "azurerm_role_assignment" "acr_pull" {
  principal_id         = azurerm_user_assigned_identity.managed_identity.principal_id
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
  restart_policy      = "Always" # keep the container running even though it crashes or the process has completed
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.managed_identity.id]
  }

  container {
    name   = "boltslackbot"
    image  = "boltslackbotacr.azurecr.io/slack-bot:latest"
    cpu    = "1.0"
    memory = "1.5"

    # Do NOT expose any ports for this container
    # The application will be communicated with via the NGROK tunnel

    environment_variables = {
      SLACK_BOT_TOKEN      = var.slack_bot_token
      SLACK_SIGNING_SECRET = var.slack_signing_secret
    }
  }

  container {
    name   = "ngrok"
    image  = "boltslackbotacr.azurecr.io/ngrok:latest"
    cpu    = "1.0"
    memory = "1.5"

    ports {
      port     = 80
      protocol = "TCP"
    }

    environment_variables = {
      NGROK_AUTHTOKEN = var.ngrok_authtoken # Assuming this is securely stored
    }

  }
  image_registry_credential {
    user_assigned_identity_id = azurerm_user_assigned_identity.managed_identity.id
    server                    = "boltslackbotacr.azurecr.io"
  }

  depends_on = [
    azurerm_role_assignment.acr_pull
  ]
}

