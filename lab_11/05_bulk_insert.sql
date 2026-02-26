-- The script above assumes 01_schema.sql has been executed.

-- Demonstrating BULK INSERT

INSERT INTO employees (first_name, last_name, dept_id) VALUES
('Tilek', 'Alkanov', 1),
('Nursultan', 'Isakov', 1),
('Gulzat', 'Sultanova', 2);

SELECT * FROM employees;
