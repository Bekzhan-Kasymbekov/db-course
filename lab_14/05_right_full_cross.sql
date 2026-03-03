SELECT
    s.student_name,
    e.grade
FROM students s
RIGHT JOIN enrollments e
    ON s.student_id = e.student_id;

SELECT
    s.student_name,
    e.grade
FROM students s
FULL OUTER JOIN enrollments e
    ON s.student_id = e.student_id;

SELECT
    s.student_name,
    c.course_name
FROM students s
CROSS JOIN courses c;
