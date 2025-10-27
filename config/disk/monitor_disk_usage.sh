#!/bin/bash

# Configuration
SCRIPT_DIR="$HOME/etc-disk"
LOG_DIR="$HOME/var-log-disk"
JSON_LOG_FILE="$LOG_DIR/disk_usage_graylog.json"

# Make sure the log directory exists
mkdir -p "$LOG_DIR"

# Function to read values from NVMe smart-log output
get_nvme_value() {
    local metric="$1"
    # Capture the output of the smart-log command
    local raw_data=$(sudo nvme smart-log /dev/nvme0n1 2>/dev/null)

    # Check if the command was successful
    if [ $? -ne 0 ]; then
        echo "0"
        return
    fi

    local value_with_unit=""
    if [ "$metric" == "written" ]; then
        value_with_unit=$(echo "$raw_data" | grep "Data Units Written" | sed -n 's/.*(\([0-9.]*\) \(GB\|TB\)).*/\1 \2/p')
    elif [ "$metric" == "read" ]; then
        value_with_unit=$(echo "$raw_data" | grep "Data Units Read" | sed -n 's/.*(\([0-9.]*\) \(GB\|TB\)).*/\1 \2/p')
    elif [ "$metric" == "temperature" ]; then
        echo "$raw_data" | grep "temperature" | head -1 | sed 's/.*: *\([0-9]*\).*/\1/' || echo "0"
        return
    else
        echo "0"
        return
    fi

    local number=$(echo "$value_with_unit" | awk '{print $1}')
    local unit=$(echo "$value_with_unit" | awk '{print $2}')

    # If the number is empty or not a number, return 0
    if [ -z "$number" ] || ! [[ "$number" =~ ^[0-9.]+$ ]]; then
        echo "0"
        return
    fi

    # Check the unit and convert to GB if necessary
    if [ "$unit" == "TB" ]; then
        # Use awk for floating point multiplication
        echo "$number 1024" | awk '{print $1 * $2}' | awk '{print int($1+0.5)}'
    else
        # Return GB value as is
        echo "$number" | awk '{print int($1+0.5)}'
    fi
}

# Get data
TIMESTAMP=$(date '+%s')
DATE_READABLE=$(date '+%Y-%m-%d %H:%M:%S')
HOSTNAME=$(hostname)
DEVICE="/dev/nvme0n1"

WRITTEN_GB=$(get_nvme_value "written")
READ_GB=$(get_nvme_value "read")
TEMPERATURE=$(get_nvme_value "temperature")

# Construct JSON output based on the provided example
JSON_OUTPUT="{\"version\":\"2.2\",\"timestamp\":$TIMESTAMP,\"date\":\"$DATE_READABLE\",\"host\":\"$HOSTNAME\",\"device\":\"$DEVICE\",\"metrics\":{\"total_written_gb\":$WRITTEN_GB,\"total_read_gb\":$READ_GB,\"temperature\":$TEMPERATURE},\"message\":\"NVMe stats - Written: ${WRITTEN_GB}GB, Read: ${READ_GB}GB, Temp: ${TEMPERATURE}\"}"

# Save to file
echo "$JSON_OUTPUT" > "$JSON_LOG_FILE"

# Display the output to console
echo "$JSON_OUTPUT"