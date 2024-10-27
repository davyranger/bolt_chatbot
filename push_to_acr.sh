#!/bin/bash

# Log in to ACR
az acr login --name exampleacr

# Build the Docker image
docker build -t exampleacr.azurecr.io/slack-bot:latest .

# Push the image to ACR
docker push exampleacr.azurecr.io/slack-bot:latest
