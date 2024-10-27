# bolt_chatbot

az login

docker build -t cloud-career-roadmap-generator .

docker run -p 8501:8501 cloud-roadmap-generator

app should be accessible on http://localhost:8501

# to push to azure container registry from your local machine

docker build -t careerapp.azurecr.io/cloud-career-roadmap-generator:latest .

docker push careerapp.azurecr.io/cloud-career-roadmap-generator:latest

docker pull careerapp.azurecr.io/cloud-career-roadmap-generator:latest
