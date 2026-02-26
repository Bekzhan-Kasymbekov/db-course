-- The script above assumes 01_schema.sql has been executed.

-- Demonstrating UPDATE with WHERE clause

UPDATE employees
SET last_name = 'Smith'
WHERE first_name = 'Aibek';

UPDATE departments
SET location = 'Karakol'
WHERE dept_name = 'HR';

SELECT * FROM departments;
SELECT * FROM employees;
