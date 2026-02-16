-- DROP TO MAKE REPRODUCIBLE

DROP TABLE IF EXISTS enrollments CASCADE;
DROP TABLE IF EXISTS students CASCADE;
DROP TABLE IF EXISTS courses CASCADE;

-- MANY-TO-MANY RELATIONSHIP
-- One student can enroll in many courses
-- One course can have many students

CREATE TABLE students (
    student_id SERIAL PRIMARY KEY,
    student_name VARCHAR(50) NOT NULL
);

CREATE TABLE courses (
    course_id SERIAL PRIMARY KEY,
    course_name VARCHAR(100) NOT NULL
);

CREATE TABLE enrollments (
    student_id INT
        REFERENCES students(student_id)
        ON DELETE CASCADE,
    course_id INT
        REFERENCES courses(course_id)
        ON DELETE CASCADE,
    enrollment_date DATE DEFAULT CURRENT_DATE,
    PRIMARY KEY (student_id, course_id)
);

-- Insert students
INSERT INTO students (student_name)
VALUES
    ('Chyngyz'),
    ('Alisa'),
    ('David');

-- Insert courses
INSERT INTO courses (course_name)
VALUES
    ('Kyrgyz Language'),
    ('Database'),
    ('Computer Graphics');

-- Insert enrollments (many-to-many)
INSERT INTO enrollments (student_id, course_id) VALUES
(1, 1),
(1, 2),
(2, 1),
(1, 3),
(2, 3),
(3, 2);

SELECT 'MANY-TO-MANY INITIAL STATE';
SELECT * FROM students;
SELECT * FROM courses;
SELECT * FROM enrollments;

SELECT 'STUDENT TO COURSE RELATIONSHIP';

SELECT
    s.student_name,
    c.course_name
FROM enrollments e
JOIN students s ON s.student_id = e.student_id
JOIN courses c ON c.course_id = e.course_id
ORDER BY s.student_name;
