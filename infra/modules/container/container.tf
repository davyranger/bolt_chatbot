resource "azurerm_resource_group" "rg" {
  name     = "slack-bot-rg"  # Name of the resource group
  location = "australiaeast" # Azure region where the resource group is located
}

resource "azurerm_container_registry" "example" {
  name                = "boltslackbotacr"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Standard"
}

# Define a null resource named "docker_build_push"
# This resource does not create or manage any infrastructure but is used to run local commands.
resource "random_id" "example" {
  byte_length = 8
}

resource "null_resource" "docker_build_push" {
  triggers = {
    rebuild = random_id.example.hex
  }

  # Use the "local-exec" provisioner to execute shell commands locally on the machine where Terraform is run.
  provisioner "local-exec" {

    # Define the shell command to log in to Azure, set the subscription, log in to ACR, build a Docker image, and push it to ACR.
    command = <<EOT
      # Log in to Azure using service principal credentials.
      az login --service-principal -u "AZURE_CLIENT_ID" --tenant "$AZURE_TENANT_ID"

      # Set the active Azure subscription.
      az account set --subscription "$AZURE_SUBSCRIPTION_ID"

      # Log in to the Azure Container Registry (ACR) specified by its name.
      az acr login --name boltslackbotacr

      # Build the Docker image with arguments for Slack bot tokens, tagging it with the repository and tag.
      docker build \
        --build-arg SLACK_BOT_TOKEN="$SLACK_BOT_TOKEN" \
        --build-arg SLACK_SIGNING_SECRET="$SLACK_SIGNING_SECRET" \
        -t boltslackbotacr.azurecr.io/slack-bot:latest \
        -f Dockerfile .

      # Push the built Docker image to the Azure Container Registry (ACR).
      docker push boltslackbotacr.azurecr.io/slack-bot:latest
    EOT

    # Define environment variables for the shell command.
    environment = {
      # Azure credentials and configuration variables for authentication and resource access.
      AZURE_CLIENT_ID       = var.azure_client_id       # Azure service principal client ID.
      AZURE_TENANT_ID       = var.azure_tenant_id       # Azure tenant ID.
      AZURE_SUBSCRIPTION_ID = var.azure_subscription_id # Azure subscription ID.

      # Slack bot tokens used as build arguments for the Docker image.
      SLACK_BOT_TOKEN      = var.slack_bot_token      # Slack bot token for authentication.
      SLACK_SIGNING_SECRET = var.slack_signing_secret # Slack app token for authentication.
    }
  }

  # Define a dependency on the Azure Container Registry (ACR) resource to ensure it exists before running this resource.
  depends_on = [
    azurerm_container_registry.example # Replace "example" with the actual resource name of your ACR.
  ]
}

resource "null_resource" "docker_build_push_ngrok" {
  triggers = {
    rebuild = random_id.example.hex
  }
  provisioner "local-exec" {
    command = <<EOT
      # Log in to Azure using service principal credentials.
      az login --service-principal -u "$AZURE_CLIENT_ID" --tenant "$AZURE_TENANT_ID"

      # Set the active Azure subscription.
      az account set --subscription "$AZURE_SUBSCRIPTION_ID"

      # Log in to the Azure Container Registry (ACR) specified by its name.
      az acr login --name boltslackbotacr

      # Build the Docker image for ngrok, tagging it with the repository and tag.
      docker build \
        --build-arg NGROK_AUTHTOKEN="$NGROK_AUTHTOKEN" \
        -t boltslackbotacr.azurecr.io/ngrok:latest \
        -f Dockerfile2 .

      # Push the built Docker image to the Azure Container Registry (ACR).
      docker push boltslackbotacr.azurecr.io/ngrok:latest
    EOT

    environment = {
      # Azure credentials and configuration variables for authentication and resource access.
      AZURE_CLIENT_ID       = var.azure_client_id       # Azure service principal client ID.
      AZURE_TENANT_ID       = var.azure_tenant_id       # Azure tenant ID.
      AZURE_SUBSCRIPTION_ID = var.azure_subscription_id # Azure subscription ID.

      # Ngrok authentication token used as a build argument for the Docker image.
      NGROK_AUTHTOKEN = var.ngrok_authtoken # Ngrok authentication token.
    }
  }

  depends_on = [
    azurerm_container_registry.example # Replace "example" with the actual resource name of your ACR.
  ]
}
