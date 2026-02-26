#!/bin/bash

# Database name
DB_NAME="lab_11"

# Ordered list of SQL files
FILES=(
    "01_schema.sql"
    "02_insert.sql"
    "03_update.sql"
    "04_delete.sql"
    "05_bulk_insert.sql"
    "06_bulk_update.sql"
    "07_bulk_delete.sql"
    "08_copy.sql"
)

echo "Running scripts for DATABASE: $DB_NAME"
echo "---------------------------------------"

for file in "${FILES[@]}"; do
    if [ -f "$file" ]; then
        output_file="${file%.sql}_output.txt"

        echo "Running $file ..."

        # Run SQL and capture both output and errors
        psql -h localhost -U postgres -d "$DB_NAME" -f "$file" > "$output_file" 2>&1

        if [ $? -eq 0 ]; then
            echo "$file completed successfully"
        else
            echo "Error occurred in $file (see $output_file)"
            exit 1
        fi
    else
        echo "File $file not found!"
        exit 1
    fi
done

echo "--------------------------------------"
echo "All scripts executed."
