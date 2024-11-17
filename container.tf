terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.7.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 2.0"
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

provider "azuread" {
  use_oidc = true
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

data "azurerm_client_config" "current" {}

data "azuread_service_principal" "sp" {
  object_id = "71fdc874-cc03-4e4f-b597-2de49c07589f"
}
resource "azurerm_role_assignment" "resource_group_contributor" {
  principal_id         = data.azuread_service_principal.sp.object_id
  role_definition_name = "Owner"
  scope                = data.azurerm_resource_group.example.id
}

# Role Assignment for ACR Pull Permission
resource "azurerm_role_assignment" "acr_pull" {
  principal_id         = data.azuread_service_principal.sp.object_id
  role_definition_name = "AcrPull"
  scope                = data.azurerm_container_registry.example.id
}

# Store Service Principal Password in Key Vault
resource "azurerm_key_vault" "example" {
  name                = "davysslackbotkeyvault"
  location            = data.azurerm_resource_group.example.location
  resource_group_name = data.azurerm_resource_group.example.name
  sku_name            = "standard"
  tenant_id           = data.azurerm_client_config.current.tenant_id
}

# Store Service Principal ID in Key Vault
resource "azurerm_key_vault_secret" "sp_id_secret" {
  name         = "slackbot-acr-pull-usr"
  value        = data.azuread_service_principal.sp.id
  key_vault_id = azurerm_key_vault.example.id
}
resource "azurerm_key_vault_access_policy" "sp_access_policy" {
  key_vault_id = azurerm_key_vault.example.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azuread_service_principal.sp.object_id

  secret_permissions = [
    "Get",
    "List",
    "Set"
  ]
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
  # az acr credential show --name boltslackbotcontainerregistry
  image_registry_credential {
    username = var.acr_username
    password = var.acr_password
    server   = data.azurerm_container_registry.example.login_server
  }
}

# Custom Role Definition (If Required)
resource "azurerm_role_definition" "custom_role_definition" {
  name        = "RoleAssignmentContributor"
  scope       = data.azurerm_resource_group.example.id
  description = "Custom role with permissions to manage role assignments"
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