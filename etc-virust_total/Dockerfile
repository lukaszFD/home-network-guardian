# Dockerfile
FROM python:3.9-slim

# Create a directory for logs
RUN mkdir -p /app/logs

# Set working directory in the container
WORKDIR /app

# Install necessary libraries
RUN pip install --no-cache-dir requests python-dotenv mysql-connector-python Flask

# Copy the script
COPY main.py .
COPY .env .

# Define the default command to run
CMD ["python", "main.py"]