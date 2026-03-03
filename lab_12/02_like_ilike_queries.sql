SELECT user_id, first_name, last_name, email 
FROM users
WHERE email ILIKE '%@mail.com';

SELECT course_id, course_title 
FROM courses
WHERE course_title LIKE 'Course 1%';

SELECT user_id, first_name, last_name, email
FROM users 
WHERE user_role = 'instructor'
AND first_name ~ '3';

SELECT user_id, first_name, last_name
FROM users
WHERE LENGTH(last_name) = 8;
