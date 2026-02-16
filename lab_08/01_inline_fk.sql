-- DROP TO MAKE REPRODUCIBLE
DROP TABLE IF EXISTS employees_inline;
DROP TABLE IF EXISTS departments_inline;

CREATE TABLE departments_inline (
	dept_id SERIAL PRIMARY KEY,
	dept_name VARCHAR(100) NOT NULL,
	location VARCHAR(100)
);

CREATE TABLE employees_inline (
	emp_id SERIAL PRIMARY KEY,
	first_name VARCHAR(50) NOT NULL,
	last_name VARCHAR(50) NOT NULL,
	dept_id INTEGER REFERENCES departments(dept_id)
);
