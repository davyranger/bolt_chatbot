terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.7.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-terraform-github-actions-state"
    storage_account_name = "tfgithubactions453335"
    container_name       = "boltslackbotcontainer"
    key                  = "terraform.tfstate"
    use_oidc             = true
  }
}

provider "azurerm" {
  features {}
  use_oidc = true
}

## Resource Group Data Source
data "azurerm_resource_group" "example" {
  name = "slack-bot-rg"
}

# Container Registry Data Source
data "azurerm_container_registry" "example" {
  name                = "boltslackbotcontainerregistry"
  resource_group_name = data.azurerm_resource_group.example.name
}

# Managed Identity
resource "azurerm_user_assigned_identity" "managed_identity" {
  name                = "slackbot-identity"
  location            = data.azurerm_resource_group.example.location
  resource_group_name = data.azurerm_resource_group.example.name
}

# Container Group
resource "azurerm_container_group" "example" {
  name                = "boltslackbotgroup"
  location            = data.azurerm_resource_group.example.location
  resource_group_name = data.azurerm_resource_group.example.name
  os_type             = "Linux"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.managed_identity.id]
  }

  container {
    name   = "boltslackbot"
    image  = "${data.azurerm_container_registry.example.login_server}/slack-bot:latest"
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
}

# Role Assignment for ACR Pull Permission
resource "azurerm_role_assignment" "acr_pull" {
  principal_id         = azurerm_user_assigned_identity.managed_identity.principal_id
  role_definition_name = "AcrPull"
  scope                = data.azurerm_container_registry.example.id
}

# Custom Role Definition (If Required)
resource "azurerm_role_definition" "custom_role_definition" {
  name               = "RoleAssignmentContributor"
  scope              = data.azurerm_resource_group.example.id
  description        = "Custom role with permissions to manage role assignments"
  permissions {
    actions = [
      "Microsoft.Authorization/roleAssignments/write",
      "Microsoft.Authorization/roleAssignments/delete",
    ]
    not_actions = []
  }

  assignable_scopes = [
    data.azurerm_resource_group.example.id,
    data.azurerm_container_registry.example.id
  ]
}
