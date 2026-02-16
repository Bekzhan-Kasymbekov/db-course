-- DROP TO MAKE REPRODUCIBLE
DROP TABLE IF EXISTS employees_table_fk;
DROP TABLE IF EXISTS departments_table_fk;

CREATE TABLE departments_table_fk (
    dept_id SERIAL PRIMARY KEY
);

CREATE TABLE employees_table_fk (
	emp_id SERIAL PRIMARY KEY,
	first_name VARCHAR(50) NOT NULL,
	last_name VARCHAR(50) NOT NULL,
	dept_id INTEGER,
	FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);
