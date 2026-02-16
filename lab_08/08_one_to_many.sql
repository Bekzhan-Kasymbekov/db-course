-- DROP TO MAKE REPRODUCIBLE

DROP TABLE IF EXISTS employees CASCADE;
DROP TABLE IF EXISTS departments CASCADE;

-- ONE-TO-MANY RELATIONSHIP
-- One department can have many employees
-- One employee can only have one department

CREATE TABLE departments (
    dept_id SERIAL PRIMARY KEY,
    dept_name VARCHAR(100) NOT NULL
);

CREATE TABLE employees (
    emp_id SERIAL PRIMARY KEY,
    emp_name VARCHAR(50),
    dept_id INT NOT NULL
        REFERENCES departments(dept_id) 
        ON DELETE RESTRICT
);

-- Insert departments
INSERT INTO departments (dept_name) 
VALUES 
    ('Engineering'),
    ('Design');

-- Insert multiple employees into one department
INSERT INTO employees  (emp_name, dept_id) VALUES 
    ('Bob', 1),
    ('Brian', 1),
    ('Alicia', 2),
    ('Jordan', 2);

SELECT 'ONE-TO-MANY INITIAL STATE';
SELECT * FROM departments;
SELECT * FROM employees;

SELECT 'DEPARTMENT → EMPLOYEE RELATIONSHIP';
SELECT 
    d.dept_name,
    e.emp_name
FROM departments d
JOIN employees e ON d.dept_id = e.dept_id
ORDER BY d.dept_name;

-- Attempt to delete department while employees exist
BEGIN;

DELETE FROM departments WHERE dept_id = 1;

ROLLBACK;

SELECT 'ONE-TO-MANY AFTER DELETE ATTEMPT';
SELECT * FROM departments;
SELECT * FROM employees;
