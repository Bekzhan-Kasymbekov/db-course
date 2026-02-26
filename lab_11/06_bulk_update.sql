-- The script above assumes 01_schema.sql has been executed.

-- Demonstrating BULK UPDATE

UPDATE employees
SET last_name = 'Bekov'
WHERE last_name IN ('Alkanov', 'Isakov');

SELECT * FROM employees;
