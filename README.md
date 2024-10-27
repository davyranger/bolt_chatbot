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