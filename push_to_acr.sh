#!/bin/bash

# Log in to ACR
az login
az acr login --name boltslackbotcontainerregistry

# Build the Docker image
docker build -t boltslackbotcontainerregistry.azurecr.io/slack-bot:latest .

# Push the image to ACR
docker push boltslackbotcontainerregistry.azurecr.io/slack-bot:latest
