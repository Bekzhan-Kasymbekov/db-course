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

-- ON UPDATE CASCADE

CREATE TABLE departments_cascade (
	dept_id INT PRIMARY KEY
);

CREATE TABLE employees_cascade (
    emp_id SERIAL PRIMARY KEY,
    dept_id INT
        REFERENCES departments_cascade(dept_id)
        ON UPDATE CASCADE
);

INSERT INTO departments_cascade VALUES (1);
INSERT INTO employees_cascade (dept_id) VALUES (1);

UPDATE departments_cascade
    SET dept_id = 2
    WHERE dept_id = 1;

SELECT 'CASCADE RESULT';
SELECT * FROM departments_cascade;
SELECT * FROM employees_cascade;

-- ON UPDATE RESTRICT

CREATE TABLE departments_restrict (
    dept_id INT PRIMARY KEY
);

CREATE TABLE employees_restrict (
    emp_id SERIAL PRIMARY KEY,
    dept_id INT
        REFERENCES departments_restrict(dept_id)
        ON UPDATE RESTRICT
);

INSERT INTO departments_restrict VALUES (1);
INSERT INTO employees_restrict (dept_id) VALUES (1);

BEGIN;

UPDATE departments_restrict
    SET dept_id = 2
    WHERE dept_id = 1;

ROLLBACK;

SELECT 'RESTRICT RESULT';
SELECT * FROM departments_restrict;
SELECT * FROM employees_restrict;

-- ON UPDATE NO ACTION

CREATE TABLE departments_no_action (
    dept_id INT PRIMARY KEY
);

CREATE TABLE employees_no_action (
    emp_id SERIAL PRIMARY KEY,
    dept_id INT 
        REFERENCES departments_no_action(dept_id)
        ON UPDATE NO ACTION
);

INSERT INTO departments_no_action VALUES (1);
INSERT INTO employees_no_action (dept_id) VALUES (1);

BEGIN;

UPDATE departments_no_action
    SET dept_id = 2
    WHERE dept_id = 1;

ROLLBACK;

SELECT 'NO ACTION RESULT';
SELECT * FROM departments_no_action;
SELECT * FROM employees_no_action;

-- ON UPDATE SET NULL

CREATE TABLE departments_set_null (
    dept_id INT PRIMARY KEY
);

CREATE TABLE employees_set_null (
    emp_id SERIAL PRIMARY KEY,
	dept_id INT
        REFERENCES departments_set_null(dept_id)
        ON UPDATE SET NULL
);

INSERT INTO departments_set_null VALUES (1);
INSERT INTO employees_set_null (dept_id) VALUES (1);

UPDATE departments_set_null
    SET dept_id = 2
    WHERE dept_id = 1;

SELECT 'SET NULL RESULT';
SELECT * FROM departments_set_null;
SELECT * FROM employees_set_null;

-- ON UPDATE SET DEFAULT

CREATE TABLE departments_set_default (
    dept_id INT PRIMARY KEY
);

INSERT INTO departments_set_default VALUES (1);
INSERT INTO departments_set_default VALUES (999);

CREATE TABLE employees_set_default (
    emp_id SERIAL PRIMARY KEY,
	dept_id INT DEFAULT 999 
        REFERENCES departments_set_default(dept_id)
	    ON UPDATE SET DEFAULT
);

INSERT INTO employees_set_default (dept_id) VALUES (1);

UPDATE departments_set_default
    SET dept_id = 2
    WHERE dept_id = 1;

SELECT 'SET DEFAULT RESULT';
SELECT * FROM departments_set_default;
SELECT * FROM employees_set_default;
