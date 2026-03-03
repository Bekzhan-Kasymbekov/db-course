-- SELF JOIN
SELECT
    e1.name AS employee,
    e2.name AS manager
FROM employees e1
LEFT JOIN employees e2
    ON e1.manager_id = e2.employee_id;

-- m2m JOIN
SELECT
    s.student_name,
    c.course_name,
    e.grade
FROM students s
INNER JOIN enrollments e
    ON s.student_id = e.student_id
INNER JOIN courses c
    ON e.course_id = c.course_id
WHERE e.grade IS NOT NULL
ORDER BY s.student_name, c.course_name;
