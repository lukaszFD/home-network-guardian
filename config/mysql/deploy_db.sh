#!/bin/bash

# Define output file with current date
CURRENT_DATE=$(date +%Y_%m_%d)
OUTPUT_FILE="deployment_script.sql"

# Clear previous deployment script if it exists
if [ -f "$OUTPUT_FILE" ]; then
    rm "$OUTPUT_FILE"
    echo "Previous deployment script removed."
fi

echo "Creating the database deployment script: $OUTPUT_FILE"

# 1. Append the database creation script
echo "-- Database creation script" >> $OUTPUT_FILE
if [ -f "CREATE_DATABASE.sql" ]; then
    cat "CREATE_DATABASE.sql" >> $OUTPUT_FILE
    echo -e "\n" >> $OUTPUT_FILE
    echo "Database creation script appended."
else
    echo "Error: CREATE_DATABASE.sql not found." >> $OUTPUT_FILE
fi

# 2. Append table creation scripts
echo -e "\n-- Table creation scripts" >> $OUTPUT_FILE
for file in TABLE/*.sql; do
    if [ -f "$file" ]; then
        echo "Processing table script: $file"
        cat "$file" >> $OUTPUT_FILE
        echo -e "\n" >> $OUTPUT_FILE
    fi
done
echo "All table scripts appended."

# 3. Append index creation scripts
echo -e "\n-- Index creation scripts" >> $OUTPUT_FILE
for file in INDEXES/*.sql; do
    if [ -f "$file" ]; then
        echo "Processing index script: $file"
        cat "$file" >> $OUTPUT_FILE
        echo -e "\n" >> $OUTPUT_FILE
    fi
done
echo "All index scripts appended."

# 4. Append view creation scripts
echo -e "\n-- View creation scripts" >> $OUTPUT_FILE
for file in VIEWS/*.sql; do
    if [ -f "$file" ]; then
        echo "Processing view script: $file"
        cat "$file" >> $OUTPUT_FILE
        echo -e "\n" >> $OUTPUT_FILE
    fi
done
echo "All view scripts appended."

# 5. Append procedure creation scripts
echo -e "\n-- Procedure creation scripts" >> $OUTPUT_FILE
for file in PROCEDURES/*.sql; do
    if [ -f "$file" ]; then
        echo "Processing procedure script: $file"
        cat "$file" >> $OUTPUT_FILE
        echo -e "\n" >> $OUTPUT_FILE
    fi
done
echo "All procedure scripts appended."

echo "Deployment script created successfully. Run it with: "
echo "mysql -u [user] -p [password] < $OUTPUT_FILE"