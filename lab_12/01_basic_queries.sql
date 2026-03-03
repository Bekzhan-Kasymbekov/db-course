SELECT user_id, first_name, last_name FROM users
WHERE country = 'Germany' 
AND user_role = 'student';

SELECT user_id, first_name, last_name FROM users
WHERE user_role = 'instructor'
AND is_active = TRUE;

SELECT course_id, course_title FROM courses
WHERE price > 100;

SELECT course_id, course_title FROM courses
WHERE course_level = 'BEGINNER';

SELECT user_id, first_name, last_name FROM users
WHERE user_role = 'student'
AND date_of_birth >= '2001-01-01';

SELECT 
    u.first_name,
    u.last_name,
    c.course_title,
    e.enrollment_date,
    e.duration_days
FROM enrollments e
JOIN users u ON e.user_id = u.user_id
JOIN courses c ON e.course_id = c.course_id
WHERE e.enrollment_status = 'completed';
