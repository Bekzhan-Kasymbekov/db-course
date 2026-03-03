SELECT 
    c.course_id,
    c.course_title,
    COUNT(*) AS student_count
FROM enrollments e
JOIN courses c
    ON e.course_id = c.course_id
GROUP BY c.course_id, c.course_title
HAVING COUNT(e.course_id) > 10;

SELECT
    i.user_id,
    i.first_name,
    i.last_name,
    COUNT (*) AS course_count
FROM courses c
JOIN users i 
    ON c.instructor_id = i.user_id
GROUP BY i.user_id, i.first_name, i.last_name
HAVING COUNT(c.course_id) > 2;

SELECT
    cat.category_id,
    cat.category_name,
    COUNT(*) AS course_count
FROM courses c
JOIN categories cat
    ON c.category_id = cat.category_id
GROUP BY cat.category_id, cat.category_name
HAVING COUNT(c.course_id) > 3;

SELECT
    c.course_id,
    c.course_title,
    AVG(r.rating) AS avg_rating
FROM courses c
JOIN reviews r
    ON c.course_id = r.course_id
GROUP BY c.course_id, c.course_title
HAVING AVG(r.rating) > 4;
