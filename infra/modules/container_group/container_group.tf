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
    identity_ids = ["/subscriptions/12345678-1234-9876-4563-123456789012/resourceGroups/example-resource-group/providers/Microsoft.ManagedIdentity/userAssignedIdentities/${var.uai_client_id}"]
  }

  container {
    name   = "boltslackbot"
    image  = "${var.container_registry}/slack-bot:latest"
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
    user_assigned_identity_id = var.user_assigned_id
    server                    = var.container_registry
  }
}