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
  ip_address_type     = "Public"
  dns_name_label      = "boltslackbot"
  restart_policy      = "Always"

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
      port     = 3000
      protocol = "TCP"
    }

    environment_variables = {
      SLACK_BOT_TOKEN = var.slack_bot_token
      SLACK_SIGNING_SECRET = var.slack_signing_secret
    }
  }

  container {
    name   = "ngrok"
    image  = "boltslackbotacr.azurecr.io/ngrok:latest"
    cpu    = "1.0"
    memory = "1.5"

    ports {
      port     = 443
      protocol = "TCP"
    }

    environment_variables = {
      NGROK_AUTHTOKEN = var.ngrok_authtoken # Assuming this is securely stored
    }

    commands = [
      "ngrok",
      "http",
      "3000",
      "--region=au",
      "--hostname=boltslackbot.australiaeast.azurecontainer.io"
    ]

  }

  image_registry_credential {
    user_assigned_identity_id = azurerm_user_assigned_identity.managed_identity.id
    server                    = "boltslackbotacr.azurecr.io"
  }

  depends_on = [
    azurerm_role_assignment.acr_pull
  ]
}
