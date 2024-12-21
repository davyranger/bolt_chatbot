# bolt_chatbot

az login

docker build -t cloud-career-roadmap-generator .

docker run -p 8501:8501 cloud-roadmap-generator

app should be accessible on http://localhost:8501

# to push to azure container registry from your local machine

docker build -t boltslackbotcontainerregistry.azurecr.io/slack-bot:latest .

docker push boltslackbotcontainerregistry.azurecr.io/slack-bot:latest

docker pull boltslackbotcontainerregistry.azurecr.io/slack-bot:latest

# if the image is not on the local machine it will be pulled from the acr

docker run -p 3000:3000 -e SLACK_BOT_TOKEN=$SLACK_BOT_TOKEN -e SLACK_APP_TOKEN=$SLACK_APP_TOKEN boltslackbotcontainerregistry.azurecr.io/slack-bot:latest

# Getting started with Bolt for Python

https://tools.slack.dev/bolt-python/getting-started

# Configuring OpenID Connect in Azure

https://docs.github.com/en/actions/security-for-github-actions/security-hardening-your-deployments/configuring-openid-connect-in-azure

# Configure a federated identity credential on an app

https://learn.microsoft.com/en-us/entra/workload-id/workload-identity-federation-create-trust?pivots=identity-wif-apps-methods-azp#configure-a-federated-identity-credential-on-an-app

# variables

### using, for example this - "echo "TF_VAR_azure_client_id=${{ secrets.AZURE_CLIENT_ID }}" >> $GITHUB_ENV"
### means that you don't have to hardcode any values into a local terraform tfvars config file
### The variable will be available for using in the github actions job

