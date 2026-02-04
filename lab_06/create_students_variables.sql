CREATE TABLE students (
	student_id SERIAL PRIMARY KEY,
	first_name VARCHAR(50) NOT NULL,
	last_name VARCHAR(50) NOT NULL,
	email VARCHAR(100) UNIQUE NOT NULL,
	thesis_topic TEXT,
	enrolment_year DATE,
	grade INTEGER NOT NULL,
	CONSTRAINT grade_range_check CHECK (grade BETWEEN 0 and 100)
);
