#!/bin/bash

# Log in to ACR
az login --service-principal -u "$AZURE_CLIENT_ID" -p "$AZURE_CLIENT_SECRET" --tenant "$AZURE_TENANT_ID"

az acr login --name boltslackbotcontainerregistry

# Build the Docker image
docker build -t boltslackbotcontainerregistry.azurecr.io/slack-bot:latest .

# Push the image to ACR
docker push boltslackbotcontainerregistry.azurecr.io/slack-bot:latest
