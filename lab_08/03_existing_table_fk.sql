-- DROP TO MAKE REPRODUCIBLE
DROP TABLE IF EXISTS projects_existing;
DROP TABLE IF EXISTS departments_existing;

CREATE TABLE departments_existing (
    dept_id SERIAL PRIMARY KEY
);

CREATE TABLE projects_existing (
	project_id SERIAL PRIMARY KEY,
	project_name VARCHAR(100),
	dept_id INTEGER
);

ALTER TABLE projects_existing
ADD CONSTRAINT fk_project_department
FOREIGN KEY (dept_id) 
REFERENCES departments(dept_id);
