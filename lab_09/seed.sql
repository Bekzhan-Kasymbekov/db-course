-- ===============================
-- Seed Data for Gym System
-- ===============================

-- -------------------------------
-- Memberships
-- -------------------------------

INSERT INTO memberships (plan_name, price, duration_months, access_level, description)
VALUES
('Basic Plan', 1500.00, 1, 'basic', 'Access to gym equipment only'),
('Premium Plan', 4000.00, 3, 'premium', 'Gym + group classes'),
('VIP Plan', 10000.00, 6, 'vip', 'All access including personal training');

-- -------------------------------
-- Members
-- -------------------------------

INSERT INTO members (membership_id, first_name, last_name, email, phone, date_of_birth, gender, is_active)
VALUES
(1, 'John', 'Doe', 'john.doe@email.com', '+996700000001', '1998-05-14', 'male', TRUE),
(2, 'Alice', 'Smith', 'alice.smith@email.com', '+996700000002', '1995-09-21', 'female', TRUE),
(3, 'Mark', 'Brown', 'mark.brown@email.com', '+996700000003', '1990-02-11', 'male', TRUE);

-- -------------------------------
-- Trainers
-- -------------------------------

INSERT INTO trainers (first_name, last_name, email, phone, gender, specialization, experience_years, is_active)
VALUES
('David', 'Wilson', 'david.wilson@gym.com', '+996700000010', 'male', 'Strength Training', 5, TRUE),
('Emma', 'Taylor', 'emma.taylor@gym.com', '+996700000011', 'female', 'CrossFit', 3, TRUE);

-- -------------------------------
-- Workout Programs
-- -------------------------------

INSERT INTO workout_programs (trainer_id, program_name, description, difficulty_level, is_active)
VALUES
(1, 'Beginner Strength', 'Basic strength building program', 'novice', TRUE),
(2, 'Advanced CrossFit', 'High intensity crossfit program', 'advanced', TRUE);

-- -------------------------------
-- Exercises
-- -------------------------------

INSERT INTO exercises (exercise_name, target_muscle, description, equipment_required, difficulty_level)
VALUES
('Bench Press', 'Chest', 'Barbell bench press exercise', 'Barbell', 'intermediate'),
('Squat', 'Legs', 'Barbell squat exercise', 'Barbell', 'intermediate'),
('Pull-ups', 'Back', 'Bodyweight pull-up exercise', 'Pull-up Bar', 'advanced'),
('Burpees', 'Full Body', 'High intensity bodyweight exercise', 'None', 'novice');

-- -------------------------------
-- Payments
-- -------------------------------

INSERT INTO payments (member_id, amount, payment_method, status, transaction_reference)
VALUES
(1, 1500.00, 'card', 'successful', 'TXN1001'),
(2, 4000.00, 'cash', 'successful', 'TXN1002'),
(3, 10000.00, 'QR', 'pending', 'TXN1003');

-- -------------------------------
-- Sessions (Check-ins)
-- -------------------------------

INSERT INTO sessions (member_id, session_type)
VALUES
(1, 'gym'),
(1, 'crossfit'),
(2, 'gym'),
(3, 'yoga');

-- -------------------------------
-- Logs (Progress Tracking)
-- -------------------------------

INSERT INTO logs (member_id, weight, body_fat_percentage, notes)
VALUES
(1, 78.5, 18.4, 'Good progress this month'),
(2, 62.0, 22.1, 'Improved endurance'),
(3, 85.3, 25.0, 'Needs to improve diet');

-- -------------------------------
-- Member ↔ Workout Programs
-- -------------------------------

INSERT INTO member_workout_programs (member_id, workout_program_id, status)
VALUES
(1, 1, 'active'),
(2, 2, 'active'),
(3, 1, 'completed');

-- -------------------------------
-- Trainer ↔ Members
-- -------------------------------

INSERT INTO trainer_members (trainer_id, member_id)
VALUES
(1, 1),
(2, 2),
(1, 3);

-- -------------------------------
-- Workout Program ↔ Exercises
-- -------------------------------

INSERT INTO workout_program_exercises (workout_program_id, exercise_id, sets, reps, rest_seconds, exercise_order)
VALUES
(1, 1, 3, 10, 60, 1),
(1, 2, 4, 8, 90, 2),
(2, 3, 4, 12, 60, 1),
(2, 4, 5, 15, 45, 2);
