CREATE TABLE course_enrollments (
	student_id INTEGER,
	course_id INTEGER,
	semester VARCHAR(20),
	enrollment_date DATE DEFAULT CURRENT_DATE,
	grade CHAR(2),
	PRIMARY KEY (student_id, course_id, semester)
);

INSERT INTO course_enrollments (student_id, course_id, semester, grade)
VALUES
(1, 101, '2024-Spring', 'A'),
(1, 102, '2024-Spring', 'B+'),
(2, 101, '2024-Spring', 'A-'),
(1, 101, '2024-Fall', 'A+');

