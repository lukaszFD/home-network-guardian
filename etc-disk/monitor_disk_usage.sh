#!/bin/bash

# Konfiguracja sciezek
SCRIPT_DIR="$HOME/etc-disk"
LOG_DIR="$HOME/var-log-disk"
JSON_LOG_FILE="$LOG_DIR/disk_usage_graylog.json"
mkdir -p "$SCRIPT_DIR" "$LOG_DIR"

# Funkcja do odczytu wartosci z nawiasów
get_nvme_value() {
    local metric="$1"
    local raw_data=$(sudo nvme smart-log /dev/nvme0n1 2>/dev/null || echo "ERROR")
    
    [ "$raw_data" = "ERROR" ] && echo "0" && return

    case "$metric" in
        "written")
            echo "$raw_data" | grep "Data Units Written" | sed -n 's/.*(\([0-9.]*\) GB).*/\1/p' | awk '{print int($1+0.5)}' || echo "0"
            ;;
        "read")
            echo "$raw_data" | grep "Data Units Read" | sed -n 's/.*(\([0-9.]*\) GB).*/\1/p' | awk '{print int($1+0.5)}' || echo "0"
            ;;
        "temperature")
            echo "$raw_data" | grep "temperature" | head -1 | sed 's/.*: *\([0-9]*\).*/\1/' || echo "0"
            ;;
        *)
            echo "0"
            ;;
    esac
}

# Pobierz dane
TIMESTAMP=$(date '+%s')
DATE_READABLE=$(date '+%Y-%m-%d %H:%M:%S')
HOSTNAME=$(hostname)

WRITTEN_GB=$(get_nvme_value "written")
READ_GB=$(get_nvme_value "read")
TEMPERATURE=$(get_nvme_value "temperature")

# Przygotuj JSON
cat > "$JSON_LOG_FILE" <<EOF
{
  "version": "2.2",
  "timestamp": $TIMESTAMP,
  "date": "$DATE_READABLE",
  "host": "$HOSTNAME",
  "device": "/dev/nvme0n1",
  "metrics": {
    "total_written_gb": $WRITTEN_GB,
    "total_read_gb": $READ_GB,
    "temperature": $TEMPERATURE
  },
  "message": "NVMe stats - Written: ${WRITTEN_GB}GB, Read: ${READ_GB}GB, Temp: ${TEMPERATURE}"
}
EOF