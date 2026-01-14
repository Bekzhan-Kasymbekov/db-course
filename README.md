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

## How to Run the Scripts

Example commands used to execute the scripts:

```bash
psql -h localhost -U postgres -d postgres -f
psql -h localhost -U postgres -d school -f
psql -h localhost -U postgres -d school -f	
psql -h localhost -U postgres -d school -f
