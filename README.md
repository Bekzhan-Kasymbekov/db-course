# Database Labs (PostgreSQL)

This repository contains my work for the database laboratory assignments.
All tasks were completed using **PostgreSQL** and executed through the terminal using `psql`.
SQL command are stored in `.sql` scripts to ensure reproducibility and version control.

---

## Lab #3: Database and Table Basics

In this lab, I:

- Created a PostgreSQL database `school`
- Created a basic table `students`
- Populated the table with sample data
- Executed queries using SQL scripts with the `.sql` extension
- Ran all scripts through the terminal using `psql`

### Relevant files
- `schema.sql` - table creation
- `seed.sql` - inserting sample data
- `queries.sql` - basic queries
- `output.txt` - execution output as proof

---

## Lab #4: Data Selection and Filtering 

In this lab, I practiced querying data using:

- `SELECT`
- `WHERE`
- `ORDER BY`
- `LIMIT`

All queries were executed on the `students` table.

### Relevant files

- `queries.sql` - queries using filtering, ordering and limiting
- `output.txt` - saved query results

---

## Lab #5: Database Administration and Switching

In this lab, I worked with database-level operations:

- Created and dropped databases using an SQL script
- Executed administrative commands from the terminal
- Created a script demonstrating switching between databases using `\c`

### Relevant files
- `db_admin.sql` - CREATE and DROP DATABASE commands
- `db_admin_ouput.sql` - execution output
- `switch_db.sql` - database switching demonstration
- `switch_db_output.txt` - execution output

---

## Lab #6: Tables, Data Types and Constraints

In this lab, I worked with table manipulation:

- Created and dropped tables via SQL scripts
- Used different data types and implemented constraints
- Altered existing table columns via `ADD`, `RENAME`, and `DROP COLUMN`
- Created temprorary tables using `CREATE TEMP TABLE` command

### Relevant files 
- `create_students_variables.sql` - creating a table with various data types, constraints
- `create_students_output.txt` - output
- `populate_students.sql` - populating the table with data
- `populate_students_output.txt` - output
- `alter_table_output.txt` - changing the table using alter commands
- `drop_table.sql` - dropping a table if it exists
- `drop_table_output.txt` - output
- `students_table.txt` - the table's content before ALTER
- `students_table_after_alter.txt` - the table's content after ALTER
- `temp_table.sql` - creating a temporary table
- `temp_table_output.txt` - output

## Lab #7: Primary Keys

- Created primary keys via Column-level Constraint, Table-level Constraint, Named Constraint 
- Created tables with primary and composite primary keys
- Created tables with auto generated primary keys using `SERIAL`,`BIGSERIAL` and `GENERATED AS IDENTITY`

### Relevant files
- `00_clean.sql` - a script to delete all previously created tables for clean lab workflow
- `01_column_level_pk.sql` - create primary keys using Column-level Constraint
- `02_table_level_pk.sql` - create primary keys using Table-level Constraint
- `03_named_constraint_pk.sql` - create primary keys using Named Contraint
- `04_composite_pk.sql` - create tables with composite primary key
- `05_serial_bigserial.sql` - create tables using `SERIAL` and `BIGSERIAL` for automatic primary key generation 
- `06_identity.sql` - create tables using `AS IDENTITY` primary key generation
- `run_all.sql` - master script to run everything
- `output.txt` - output of scripts and created tables


## How to Run the Scripts

Example commands used to execute the scripts:

```bash
psql -h localhost -U postgres -d postgres -f
psql -h localhost -U postgres -d school -f
psql -h localhost -U postgres -d school -f	
psql -h localhost -U postgres -d school -f
psql -h localhost -U postgres -d lab_07 -f
