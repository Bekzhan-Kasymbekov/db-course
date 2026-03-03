#!/bin/bash

set -e

DB_NAME="lab_12"
DB_USER="postgres"
DB_HOST="localhost"

echo "Running scripts for DATABASE: $DB_NAME"
echo "----------------------------------------"

rm -f *_output.txt

echo "Running schema.sql ..."
psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -f schema.sql
echo "schema.sql completed"
echo "----------------------------------------"

echo "Running seed.sql ..."
psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -f seed.sql
echo "seed.sql completed"
echo "----------------------------------------"

for file in 0*.sql; do
    output_file="${file%.sql}_output.txt"

    echo "Running $file ..."

    if psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -f "$file" \
        > "$output_file" 2>&1; then
        echo "SUCCESS: $file"
    else 
        echo "FAILED: $file (see $output_file)"
    fi

    echo "------------------------------------------"
done

echo "Execution finished."
