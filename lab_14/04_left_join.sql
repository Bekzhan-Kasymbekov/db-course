-- Shows all students including those without enrollments
SELECT
    s.student_name,
    c.course_name,
    e.grade
FROM students s
LEFT JOIN enrollments e
    ON s.student_id = e.student_id
LEFT JOIN courses c
    ON c.course_id = e.course_id
ORDER BY s.student_name;
