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
ENV SLACK_BOT_TOKEN=${SLACK_BOT_TOKEN}

ENV SLACK_SIGNING_SECRET=${SLACK_SIGNING_SECRET}

# Run the app
CMD ["python", "app.py"]
