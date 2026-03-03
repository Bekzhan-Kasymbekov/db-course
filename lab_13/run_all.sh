#!/bin/bash

DB_NAME="lab_13"

echo "Running lab_13 scripts ..."
echo "--------------------------"

psql -h localhost -U postgres -d "$DB_NAME" -f 01_schema.sql
psql -h localhost -U postgres -d "$DB_NAME" -f 02_seed.sql
psql -h localhost -U postgres -d "$DB_NAME" -f 03_aggregates.sql > output.txt 2>&1

echo "--------------------------"
echo "All scripts executed."
