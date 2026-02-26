-- The script above assumes 01_schema.sql has been executed.

-- Demonstrating CSV import using \copy

-- Reset BOTH tables before import
TRUNCATE departments RESTART IDENTITY CASCADE;

-- Recreate base departments
INSERT INTO departments (dept_name, location)
VALUES
('IT', 'Bishkek'),
('HR', 'Karakol'),
('Finance', 'Naryn');

-- Import from CSV
\copy employees(first_name, last_name, dept_id) FROM 'employees.csv' CSV HEADER;

-- Show table after import
SELECT * FROM employees;
