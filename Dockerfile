# Use an official image as a base
FROM python:3.12-slim

# Set the working directory
WORKDIR /app

# Copy the app files
COPY . /app

# # Install dependencies
# RUN pip install -r ./requirements.txt

# Set environment variables
ENV SLACK_BOT_TOKEN=${SLACK_BOT_TOKEN}

ENV SLACK_APP_TOKEN=${SLACK_APP_TOKEN}

# Run the app
CMD ["python", "app.py"]
