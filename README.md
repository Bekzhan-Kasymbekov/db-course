# Database Labs (PostgreSQL)

This repository contains my work for the Database laboratory assignments.  
All tasks were completed using **PostgreSQL** and executed via the terminal using `psql`.

All SQL commands are stored in `.sql` scripts to ensure:

- Reproducibility  
- Clear workflow  
- Version control tracking  
- Structured lab organization  

---

# Lab #3: Database and Table Basics

In this lab, I:

- Created a PostgreSQL database `school`
- Created a basic table `students`
- Inserted sample records
- Executed queries using `.sql` scripts
- Ran all scripts through the terminal using `psql`

## Relevant files

- `schema.sql` — table creation
- `seed.sql` — inserting sample data
- `queries.sql` — basic SELECT queries
- `output.txt` — execution output as proof

---

# Lab #4: Data Selection and Filtering

In this lab, I practiced querying data using:

- `SELECT`
- `WHERE`
- `ORDER BY`
- `LIMIT`

All queries were executed on the `students` table.

## Relevant files

- `queries.sql` — filtering, ordering, and limiting queries
- `output.txt` — saved query results

---

# Lab #5: Database Administration and Switching

In this lab, I worked with database-level operations:

- Created and dropped databases using SQL scripts
- Executed administrative commands from the terminal
- Demonstrated switching between databases using `\c`

## Relevant files

- `db_admin.sql` — `CREATE DATABASE` and `DROP DATABASE`
- `db_admin_output.txt` — execution output
- `switch_db.sql` — database switching demonstration
- `switch_db_output.txt` — execution output

---

# Lab #6: Tables, Data Types, and Constraints

In this lab, I worked with table structure and modification:

- Created and dropped tables using SQL scripts
- Used different data types
- Implemented constraints (`NOT NULL`, `UNIQUE`, `CHECK`, etc.)
- Modified existing tables using `ALTER TABLE`
- Created temporary tables using `CREATE TEMP TABLE`

## Relevant files

- `create_students_variables.sql`
- `create_students_output.txt`
- `populate_students.sql`
- `populate_students_output.txt`
- `alter_table.sql`
- `alter_table_output.txt`
- `drop_table.sql`
- `drop_table_output.txt`
- `students_table.txt`
- `students_table_after_alter.txt`
- `temp_table.sql`
- `temp_table_output.txt`

---

# Lab #7: Primary Keys

In this lab, I worked with different types of primary keys:

- Column-level primary key constraints
- Table-level primary key constraints
- Named primary key constraints
- Composite primary keys
- Auto-generated primary keys using:
  - `SERIAL`
  - `BIGSERIAL`
  - `GENERATED AS IDENTITY`

## Relevant files

- `00_clean.sql`
- `01_column_level_pk.sql`
- `02_table_level_pk.sql`
- `03_named_constraint_pk.sql`
- `04_composite_pk.sql`
- `05_serial_bigserial.sql`
- `06_identity.sql`
- `run_all.sql`
- `output.txt`

---

# Lab #8: Foreign Keys and Relationships

In this lab, I explored foreign key constraints and relational modeling.

Topics covered:

- Inline foreign key definitions
- Table-level foreign keys
- Named foreign key constraints
- Adding foreign keys via `ALTER TABLE`
- `ON DELETE` actions:
  - CASCADE
  - RESTRICT
  - NO ACTION
  - SET NULL
  - SET DEFAULT
- `ON UPDATE` actions
- One-to-One relationships
- One-to-Many relationships
- Many-to-Many relationships (junction table with composite primary key)

## Relevant files

- `01_inline_fk.sql`
- `02_table_lvl_fk.sql`
- `03_existing_table_fk.sql`
- `04_named_fk.sql`
- `05_on_delete_actions.sql`
- `06_on_update_actions.sql`
- `07_one_to_one.sql`
- `08_one_to_many.sql`
- `09_many_to_many.sql`

Each script includes reproducible `DROP TABLE IF EXISTS` statements and produces an associated `_output.txt` file.

---

# Lab #9: Database Design and Normalization (3NF)

In this lab, I designed and implemented a complete relational database system for a **Gym & Fitness Tracking System**.

Topics covered:

- Requirements analysis
- Conceptual design (entities and relationships)
- Logical design
- Implementation in PostgreSQL
- Application of normalization rules up to **Third Normal Form (3NF)**
- One-to-Many relationships
- Many-to-Many relationships with junction tables
- Composite primary keys
- Foreign key constraints with `ON DELETE CASCADE`
- Data validation using `CHECK`, `NOT NULL`, and `UNIQUE`
- Seeding realistic test data
- Automated execution via terminal scripts

The system includes:

- Members
- Membership plans
- Trainers
- Workout programs
- Exercises
- Payments
- Sessions
- Logs
- Junction tables for M:N relationships

All tables were properly normalized and verified to satisfy 3NF.

## Relevant files

- `schema.sql` — full database schema
- `seed.sql` — initial data population
- `queries.sql` — verification queries
- `output.txt` — full execution output (schema + seed + queries)

---

# Lab #11: Basic Data Operations and Bulk Import

In this lab, I implemented and automated fundamental data manipulation operations in PostgreSQL using a relational schema.

Topics covered:

- Creating relational tables with foreign key constraints
- Demonstrating `INSERT` (single-row and multi-row)
- Demonstrating `UPDATE` with `WHERE` clause
- Demonstrating `DELETE` with `WHERE` clause
- Bulk operations:
  - Multi-row `INSERT`
  - Conditional bulk `UPDATE`
  - Conditional bulk `DELETE`
- Data reset using `TRUNCATE`
- `TRUNCATE ... CASCADE` for foreign key dependencies
- Bulk data import using `\copy` from CSV
- Referential integrity enforcement
- Automated execution via Bash scripting
- Output and error logging

The schema includes:

- `departments` (parent table)
- `employees` (child table with `FOREIGN KEY` referencing departments)
- `ON DELETE CASCADE` behavior

The lab demonstrates the full data lifecycle:

1. Schema creation
2. Data insertion
3. Data modification
4. Data deletion
5. Bulk operations
6. Table reset
7. CSV-based data ingestion

All operations are reproducible and idempotent due to:

- `DROP TABLE IF EXISTS`
- Controlled execution order
- Automated script execution

## Relevant files

- `01_schema.sql` — schema creation with foreign key constraint
- `02_insert.sql` — single and multi-row insert operations
- `03_update.sql` — update operations with `WHERE`
- `04_delete.sql` — delete operations with referential integrity
- `05_bulk_insert.sql` — multi-row insert
- `06_bulk_update.sql` — conditional bulk update
- `07_bulk_delete.sql` — conditional bulk delete
- `08_copy.sql` — CSV import using `\copy`
- `employees.csv` — sample data for bulk import
- `run_all.sh` — Bash automation script
- `*_output.txt` — per-script execution logs (stdout + stderr)

## Automation

All scripts are executed via:

```bash
./run_all.sh

---

# How to Run the Scripts

Example command format:

```bash
psql -h localhost -U postgres -d <database_name> -f script.sql
```

For automated scripts:
```bash
/.run_all.sh
```

Example:

```bash
psql -h localhost -U postgres -d lab_08 -f 05_on_delete_actions.sql
```

To capture output:

```bash
psql -h localhost -U postgres -d lab_08 -f script.sql > output.txt 2>&1
```

To run all scripts automatically:

```bash
for file in *.sql; do
    psql -h localhost -U postgres -d lab_08 -f "$file" > "${file%.sql}_output.txt" 2>&1
done
```

---

# Environment

- PostgreSQL
- Ubuntu Linux
- Terminal-based workflow
- Version control via Git
