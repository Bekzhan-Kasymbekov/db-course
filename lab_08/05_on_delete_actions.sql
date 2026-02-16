-- DELETE TO MAKE REPRODUCIBLE

DROP TABLE IF EXISTS employees_cascade CASCADE;
DROP TABLE IF EXISTS departments_cascade CASCADE;

DROP TABLE IF EXISTS employees_restrict CASCADE;
DROP TABLE IF EXISTS departments_restrict CASCADE;

DROP TABLE IF EXISTS employees_no_action CASCADE;
DROP TABLE IF EXISTS departments_no_action CASCADE;

DROP TABLE IF EXISTS employees_set_null CASCADE;
DROP TABLE IF EXISTS departments_set_null CASCADE;

DROP TABLE IF EXISTS employees_set_default CASCADE;
DROP TABLE IF EXISTS departments_set_default CASCADE;

-- ON DELETE CASCADE

CREATE TABLE departments_cascade (
	dept_id SERIAL PRIMARY KEY
);

CREATE TABLE employees_cascade (
    emp_id SERIAL PRIMARY KEY,
    dept_id INT
        REFERENCES departments_cascade(dept_id)
        ON DELETE CASCADE
);

INSERT INTO departments_cascade DEFAULT VALUES;
INSERT INTO employees_cascade (dept_id) VALUES (1);

DELETE FROM departments_cascade WHERE dept_id = 1;

SELECT 'CASCADE RESULT';
SELECT * FROM employees_cascade;

-- ON DELETE RESTRICT

CREATE TABLE departments_restrict (
    dept_id SERIAL PRIMARY KEY
);

CREATE TABLE employees_restrict (
    emp_id SERIAL PRIMARY KEY,
    dept_id INT
        REFERENCES departments_restrict(dept_id)
        ON DELETE RESTRICT
);

INSERT INTO departments_restrict DEFAULT VALUES;
INSERT INTO employees_restrict (dept_id) VALUES (1);

DELETE FROM departments_restrict WHERE dept_id = 1;

SELECT 'RESTRICT RESULT';
SELECT * FROM employees_restrict;

-- ON DELETE NO ACTION

CREATE TABLE departments_no_action (
    dept_id SERIAL PRIMARY KEY
);

CREATE TABLE employees_no_action (
    emp_id SERIAL PRIMARY KEY,
    dept_id INT 
        REFERENCES departments_no_action(dept_id)
        ON DELETE NO ACTION
);

INSERT INTO departments_no_action DEFAULT VALUES;
INSERT INTO employees_no_action (dept_id) VALUES (1);

DELETE FROM departments_no_action WHERE dept_id = 1;

SELECT 'NO ACTION RESULT';
SELECT * FROM employees_no_action;

-- ON DELETE SET NULL

CREATE TABLE departments_set_null (
    dept_id SERIAL PRIMARY KEY
);

CREATE TABLE employees_set_null (
    emp_id SERIAL PRIMARY KEY,
	dept_id INT
        REFERENCES departments_set_null(dept_id)
        ON DELETE SET NULL
);

INSERT INTO departments_set_null DEFAULT VALUES;
INSERT INTO employees_set_null (dept_id) VALUES (1);

DELETE FROM departments_set_null WHERE dept_id = 1;

SELECT 'SET NULL RESULT';
SELECT * FROM employees_set_null;

-- ON DELETE SET DEFAULT

CREATE TABLE departments_set_default (
    dept_id INT PRIMARY KEY
);

INSERT INTO departments_set_default VALUES (1);
INSERT INTO departments_set_default VALUES (999);

CREATE TABLE employees_set_default (
    emp_id SERIAL PRIMARY KEY,
	dept_id INT DEFAULT 999 
        REFERENCES departments_set_default(dept_id)
	    ON DELETE SET DEFAULT
);

INSERT INTO employees_set_default (dept_id) VALUES (1);

DELETE FROM departments_set_default WHERE dept_id = 1;

SELECT 'SET DEFAULT RESULT';
SELECT * FROM employees_set_default;
