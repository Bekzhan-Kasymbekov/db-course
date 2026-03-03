SELECT DISTINCT
    s.user_id,
    s.first_name || ' ' || s.last_name AS full_name
FROM enrollments e
JOIN courses c
    ON e.course_id = c.course_id
JOIN users s
    ON e.user_id = s.user_id
WHERE c.price > 150;

SELECT 
    c.course_id,
    c.course_title
FROM courses c
JOIN categories cat
    ON c.category_id = cat.category_id
WHERE cat.category_name LIKE '%Programming%';

SELECT
    s.user_id,
    s.first_name || ' ' || s.last_name AS full_name,
    COUNT(e.course_id) AS course_count
FROM enrollments e
JOIN users s
    ON e.user_id = s.user_id
GROUP BY s.user_id, s.first_name, s.last_name
HAVING COUNT(e.course_id) > 3;
