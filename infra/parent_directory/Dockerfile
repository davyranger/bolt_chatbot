# Use an official image as a base
FROM python:3.12-slim

# Set the working directory
WORKDIR /app

# Copy the app files
# Copy only the necessary app files
COPY first-bolt-app/ /app/

# Install dependencies
RUN pip install -r ./requirements.txt

# Set environment variables
ENV SLACK_BOT_TOKEN_HTTP=${SLACK_BOT_TOKEN_HTTP}

ENV SLACK_APP_TOKEN_HTTP=${SLACK_APP_TOKEN_HTTP}

# Run the app
CMD ["python", "app.py"]
