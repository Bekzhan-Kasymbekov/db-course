INSERT INTO students (student_name) VALUES
('Alice'),
('Bob'),
('Charlie');

INSERT INTO courses (course_name) VALUES
('Databases'),
('Algorithms'),
('Operating Systems');

INSERT INTO enrollments VALUES
(1, 1, '2024-01-10', 90),
(1, 2, '2024-01-12', 85),
(2, 1, '2024-01-15', 78),
(3, 3, '2024-01-20', NULL);

INSERT INTO employees (name, manager_id) VALUES
('CEO', NULL),
('Manager A', 1),
('Manager B', 1),
('Employee 1', 2),
('Employee 2', 3);
