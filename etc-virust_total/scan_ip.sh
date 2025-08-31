#!/bin/bash

# Check if an IP address was provided as an argument
if [ -z "$1" ]; then
  echo "Usage: $0 <ip_address>"
  exit 1
fi

# Variable to hold the provided IP address
IP_ADDRESS="$1"

# Path to the docker-compose file
COMPOSE_FILE="virus_total.yml"

# Project name
PROJECT_NAME="virus_total-service"

# Scanner service name
SERVICE_NAME="virustotal_scanner"

# Run the scanner with the provided IP address
echo "Scanning IP address: $IP_ADDRESS"
sudo docker compose -f "$COMPOSE_FILE" -p "$PROJECT_NAME" run --rm "$SERVICE_NAME" python main.py "$IP_ADDRESS"

echo "Scanning completed."
