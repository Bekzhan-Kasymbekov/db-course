SELECT country, COUNT(*) AS student_count
FROM users
WHERE user_role = 'student'
GROUP BY country;

SELECT 
    i.user_id AS instructor_id,
    i.first_name,
    i.last_name,
    COUNT(*) AS course_count 
FROM courses c
JOIN users i ON c.instructor_id = i.user_id
WHERE i.user_role = 'instructor'
GROUP BY i.user_id, i.first_name, i.last_name;

SELECT 
    cat.category_id,
    cat.category_name,
    AVG(c.price) AS avg_price
FROM courses c
JOIN categories cat 
    ON c.category_id = cat.category_id
GROUP BY cat.category_id, cat.category_name;

SELECT 
    c.course_id,
    c.course_title,
    SUM(p.amount) AS total_revenue
FROM payments p
JOIN courses c 
    ON c.course_id = p.course_id
WHERE p.status = 'completed'
GROUP BY c.course_id, c.course_title;

SELECT 
    c.course_id,
    c.course_title,
    COUNT(*) AS student_count
FROM enrollments e
JOIN courses c 
    ON e.course_id = c.course_id
GROUP BY c.course_id, c.course_title;

SELECT 
    c.course_id,
    c.course_title,
    AVG(rating) as avg_rating
FROM reviews r
JOIN courses c 
    ON r.course_id = c.course_id
GROUP BY c.course_id, c.course_title;
