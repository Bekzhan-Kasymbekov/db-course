#!/bin/bash
set -e

DB_NAME="lab_14"

echo "Running lab_14 scripts..."
echo "----------------------------------"

psql -h localhost -U postgres -d "$DB_NAME" -f 01_schema.sql > output.txt 2>&1
psql -h localhost -U postgres -d "$DB_NAME" -f 02_seed.sql >> output.txt 2>&1
psql -h localhost -U postgres -d "$DB_NAME" -f 03_inner_join.sql >> output.txt 2>&1
psql -h localhost -U postgres -d "$DB_NAME" -f 04_left_join.sql >> output.txt 2>&1
psql -h localhost -U postgres -d "$DB_NAME" -f 05_right_full_cross.sql >> output.txt 2>&1
psql -h localhost -U postgres -d "$DB_NAME" -f 06_multi_self_m2m.sql >> output.txt 2>&1

echo "----------------------------------"
echo "All scripts executed."
