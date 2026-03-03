SELECT
    c.course_id,
    c.course_title,
    c.price,
    CASE
        WHEN c.price < 50 THEN 'Cheap'
        WHEN c.price BETWEEN 50 AND 150 THEN 'Standard'
        ELSE 'Premium'
    END AS price_category
FROM courses c;


SELECT
    t.user_id,
    t.full_name,
    t.enrollment_count,
    CASE
        WHEN t.enrollment_count = 0 THEN 'Inactive'
        WHEN t.enrollment_count <= 3 THEN 'Casual'
        ELSE 'Active'
    END AS activity_level
FROM (        
    SELECT
        s.user_id,
        s.first_name || ' ' || s.last_name AS full_name
        COUNT(e.course_id) AS enrollment_count,
    FROM users s
    LEFT JOIN enrollments e
        ON e.user_id = s.user_id
    WHERE s.user_role = 'student'
    GROUP BY s.user_id, s.first_name, s.last_name;
) t;

SELECT
    t.course_id,
    t.course_title,
    t.avg_rating,
    CASE
        WHEN t.avg_rating IS NULL THEN 'No Reviews'
        WHEN t.avg_rating >= 4 THEN 'Highly Rated'
        WHEN t.avg_rating >= 3 'Average'
        ELSE 'Low rated'
    END AS rating_level
FROM (
    SELECT
        c.course_id,
        c.course_title,
        AVG(r.rating) AS avg_rating
    FROM courses c
    LEFT JOIN reviews r
        ON c.course_id = r.course_id
    GROUP BY c.course_id, c.course_title
) t;
