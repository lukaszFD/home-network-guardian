#!/bin/bash

# Konfiguracja sciezek
SCRIPT_DIR="$HOME/etc-disk"
LOG_DIR="$HOME/var-log-disk"
LOG_FILE="$LOG_DIR/disk_usage_advanced.log"
JSON_LOG_FILE="$LOG_DIR/disk_usage_graylog.json"

# Utwórz katalogi jesli nie istnieja
mkdir -p "$SCRIPT_DIR" "$LOG_DIR"

# Dane i timestamp
TIMESTAMP=$(date '+%s')
DATE_READABLE=$(date '+%Y-%m-%d %H:%M:%S')
HOSTNAME=$(hostname)

# Pobieranie danych z NVMe
WRITTEN=$(sudo nvme smart-log /dev/nvme0n1 | grep "Data Units Written" | awk '{print $5}' | tr -d ',' 2>/dev/null || echo "0")
READ=$(sudo nvme smart-log /dev/nvme0n1 | grep "Data Units Read" | awk '{print $5}' | tr -d ',' 2>/dev/null || echo "0")

# Obliczenia róznic
if [ -f "$LOG_FILE" ]; then
    LAST_LINE=$(tail -1 "$LOG_FILE")
    LAST_WRITTEN=$(echo "$LAST_LINE" | awk '{print $2}' | tr -d ',' 2>/dev/null || echo "0")
    LAST_READ=$(echo "$LAST_LINE" | awk '{print $3}' | tr -d ',' 2>/dev/null || echo "0")
    
    WRITTEN_DIFF=$((WRITTEN - LAST_WRITTEN))
    READ_DIFF=$((READ - LAST_READ))
else
    WRITTEN_DIFF=0
    READ_DIFF=0
fi

# Przeliczanie na GB
WRITTEN_GB=$(echo "scale=3; $WRITTEN_DIFF * 512 / 1000000000" | bc 2>/dev/null || echo "0.000")
READ_GB=$(echo "scale=3; $READ_DIFF * 512 / 1000000000" | bc 2>/dev/null || echo "0.000")

# Naglówek przy pierwszym uruchomieniu
[ ! -f "$LOG_FILE" ] && echo "# Timestamp Total_Written Total_Read Write_Diff Read_Diff Write_GB Read_GB" > "$LOG_FILE"

# Zapis do logu tekstowego
printf "%-19s %12s %12s %9s %9s %8s %8s\n" \
       "$DATE_READABLE" "$WRITTEN" "$READ" "$WRITTEN_DIFF" "$READ_DIFF" \
       "$WRITTEN_GB GB" "$READ_GB GB" >> "$LOG_FILE"

# Generowanie JSON
JSON_ENTRY=$(cat <<EOF
{
  "timestamp": $TIMESTAMP,
  "date": "$DATE_READABLE",
  "host": "$HOSTNAME",
  "disk_usage": {
    "total_written": $WRITTEN,
    "total_read": $READ,
    "write_diff": $WRITTEN_DIFF,
    "read_diff": $READ_DIFF,
    "write_gb": $WRITTEN_GB,
    "read_gb": $READ_GB,
    "device": "/dev/nvme0n1"
  },
  "message": "Disk usage update - Write: $WRITTEN_GB GB, Read: $READ_GB GB"
}
EOF
)

echo "$JSON_ENTRY" >> "$JSON_LOG_FILE"

# Kompresja starych logów (tylko 7 dni historii)
find "$LOG_DIR" -name "*.log" -mtime +7 -exec gzip {} \;