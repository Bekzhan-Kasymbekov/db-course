-- The script above assumes 01_schema.sql has been executed.

-- Demonstrating INSERT function with one and multiple values

INSERT INTO departments (dept_name, location)
VALUES ('IT', 'Bishkek');

INSERT INTO departments (dept_name, location)
VALUES 
('HR', 'Osh'),
('Finance', 'Naryn');

INSERT INTO employees (first_name, last_name, dept_id)
VALUES ('Bekzhan', 'Kasymbekov', 1);

INSERT INTO employees (first_name, last_name, dept_id)
VALUES
('Aibek', 'Sadykov', 2),
('Meerim', 'Bekova', 3);

SELECT * FROM departments;
SELECT * FROM employees;
