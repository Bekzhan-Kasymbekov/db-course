-- =========================
--      1.USERS
-- =========================

-- Admins
INSERT INTO users (user_role, first_name, last_name, email, country)
VALUES
('admin', 'System', 'Admin', 'admin1@platform.com', 'USA'),
('admin', 'Main', 'Admin', 'admin2@platform.com', 'Germany');

-- Instructors
INSERT INTO users (user_role, first_name, last_name, email, country)
SELECT
    'instructor',
    'Instructor' || i,
    'Teach' || i,
    'instructor' || i || '@platform.com',
    (ARRAY['USA','Germany','UK','Canada','France'])[floor(random()*5)+1]
FROM generate_series(1, 8) s(i);

-- Students
INSERT INTO users (user_role, first_name, last_name, email, country, date_of_birth)
SELECT
    'student',
    'Student' || i,
    'Lastname' || i,
    'student' || i || '@mail.com',
    (ARRAY['USA','Germany','UK','Canada','France','Japan','India'])[floor(random()*7)+1],
    DATE '1995-01-01' + (i * 20)
FROM generate_series(1, 35) s(i);


-- =========================
--      2.CATEGORIES
-- =========================

INSERT INTO categories (category_name, description)
VALUES
('Programming', 'Software development courses'),
('Data Science', 'Data analysis and ML'),
('Mathematics', 'Pure and applied math'),
('Business', 'Entrepreneurship and management'),
('Design', 'UI/UX and graphics'),
('Artificial Intelligence', 'AI and neural networks');


-- =========================
--      3.COURSES
-- =========================

INSERT INTO courses (instructor_id, category_id, course_title, description, price, course_level)
SELECT
    (SELECT user_id FROM users WHERE user_role = 'instructor' ORDER BY random() LIMIT 1),
    (SELECT category_id FROM categories ORDER BY random() LIMIT 1),
    'Course ' || i,
    'Description for course ' || i,
    (random() * 200 + 20)::numeric(8,2),
    (ARRAY['BEGINNER','INTERMEDIATE','ADVANCED'])[floor(random()*3)+1]
FROM generate_series(1, 18) s(i);


-- =========================
-- 4.LESSONS (5 per course)
-- =========================

INSERT INTO lessons (course_id, lesson_title, content, position, duration_minutes)
SELECT
    c.course_id,
    'Lesson ' || gs || ' of Course ' || c.course_id,
    'Lesson content...',
    gs,
    (random()*60 + 20)::int
FROM courses c
CROSS JOIN generate_series(1,5) gs;


-- =========================
-- 5.ASSIGNMENTS (4 per course)
-- =========================

INSERT INTO assignments (course_id, title, description, max_score, due_date)
SELECT
    c.course_id,
    'Assignment ' || gs || ' of Course ' || c.course_id,
    'Assignment description...',
    100,
    CURRENT_DATE + (gs * 7)
FROM courses c
CROSS JOIN generate_series(1,4) gs;


-- =========================
-- 6.ENROLLMENTS
-- Randomly enroll students in courses (~40% probability)
-- =========================

INSERT INTO enrollments (user_id, course_id, enrollment_status, duration_days)
SELECT
    u.user_id,
    c.course_id,
    (ARRAY['active','completed','dropped'])[floor(random()*3)+1],
    (random()*120 + 30)::int
FROM users u
CROSS JOIN courses c
WHERE u.user_role = 'student'
AND random() < 0.4;


-- =========================
-- 7.SUBMISSIONS (~80% of enrolled students submit)
-- =========================

INSERT INTO submissions (assignment_id, user_id, score, attempt_number)
SELECT
    a.assignment_id,
    e.user_id,
    floor(random()*101)::int,
    1
FROM assignments a
JOIN enrollments e ON a.course_id = e.course_id
WHERE random() < 0.8;


-- =========================
-- 8.PAYMENTS
-- =========================

INSERT INTO payments (user_id, course_id, amount, status, payment_method)
SELECT
    e.user_id,
    e.course_id,
    (random()*200 + 20)::numeric(8,2),
    (ARRAY['completed','pending','failed'])[floor(random()*3)+1],
    (ARRAY['card','paypal','bank_transfer'])[floor(random()*3)+1]
FROM enrollments e;


-- =========================
-- 9.REVIEWS (~50% of enrollments)
-- =========================

INSERT INTO reviews (user_id, course_id, rating, review_comment)
SELECT
    e.user_id,
    e.course_id,
    floor(random()*5)+1,
    'Review for course ' || e.course_id
FROM enrollments e
WHERE random() < 0.5;
