-- The script above assumes 01_schema.sql has been executed.

-- Demonstrating BULK DELETE

DELETE FROM employees
WHERE first_name IN ('Aibek', 'Tilek', 'Nursultan');

SELECT * FROM employees;
