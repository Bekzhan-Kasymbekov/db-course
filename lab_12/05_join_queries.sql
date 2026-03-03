SELECT 
    s.first_name || ' ' || s.last_name AS full_name,
    c.course_title
FROM enrollments e
JOIN users s
    ON e.user_id = s.user_id
JOIN courses c
    ON e.course_id = c.course_id
WHERE s.user_role = 'student'
ORDER BY s.last_name, s.first_name;

SELECT
    i.first_name || ' ' || i.last_name AS full_name,
    c.course_title
FROM courses c
JOIN users i
    ON c.instructor_id = i.user_id
ORDER BY i.last_name, i.first_name;

SELECT
    c.course_title,
    COUNT(l.lesson_id) AS lesson_count
FROM courses c
LEFT JOIN lessons l
    ON l.course_id = c.course_id
GROUP BY c.course_id, c.course_title;

SELECT
    c.course_title,
    COUNT(a.assignment_id) AS assignment_count
FROM courses c
LEFT JOIN assignments a
    ON a.course_id = c.course_id
GROUP BY c.course_id, c.course_title; 
