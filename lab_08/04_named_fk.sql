-- DROP TO MAKE REPRODUCIBLE
DROP TABLE IF EXISTS employees_named;
DROP TABLE IF EXISTS departments_named;

CREATE TABLE departments_named (
    dept_id SERIAL PRIMARY KEY
);

CREATE TABLE employees_named (
    emp_id SERIAL PRIMARY KEY,
    emp_name VARCHAR(50),
    dept_id INTEGER,
        CONSTRAINT fk_employee_department
            FOREIGN KEY (dept_id)
            REFERENCES departments(dept_id)
);
