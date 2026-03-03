SELECT
    s.user_id,
    s.first_name || ' ' || s.last_name AS full_name
FROM users s
WHERE s.user_role = 'student'
AND EXISTS (
    SELECT 1
    FROM submissions sub
    WHERE sub.user_id = s.user_id
);

SELECT
    s.user_id,
    s.first_name || ' ' || s.last_name AS full_name
FROM users s
WHERE s.user_role = 'student'
AND NOT EXISTS (
    SELECT 1
    FROM submissions sub
    WHERE sub.user_id = s.user_id
);

SELECT
    c.course_id,
    c.course_title
FROM courses c
WHERE NOT EXISTS (
    SELECT 1
    FROM reviews r
    WHERE r.course_id = c.course_id
);

SELECT
    i.user_id,
    i.first_name || ' ' || i.last_name AS full_name
FROM users i
WHERE i.user_role = 'instructor'
AND NOT EXISTS (
    SELECT 1
    FROM courses c
    WHERE c.instructor_id = i.user_id
);
