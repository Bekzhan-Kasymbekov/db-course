-- The script above assumes 01_schema.sql has been executed.

-- Demonstrating DELETE with WHERE clause

DELETE FROM employees
WHERE first_name = 'Meerim';

DELETE FROM departments
WHERE dept_name = 'Finance';

SELECT * FROM departments;
SELECT * FROM employees;
