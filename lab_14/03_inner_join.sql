SELECT
    s.student_name,
    c.course_name,
    e.grade
FROM students s
INNER JOIN enrollments e
    ON s.student_id = e.student_id
INNER JOIN courses c
    ON c.course_id = e.course_id
ORDER BY s.student_name;
