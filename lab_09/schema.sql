CREATE TABLE memberships (
    membership_id SERIAL PRIMARY KEY,
    plan_name VARCHAR(50) UNIQUE NOT NULL,
    price NUMERIC(8,2) NOT NULL,
    duration_months INT CHECK (duration_months > 0),
    access_level VARCHAR(20) CHECK (access_level IN ('basic', 'premium', 'vip')) NOT NULL,
    description TEXT
);

CREATE TABLE members (
    member_id SERIAL PRIMARY KEY,
    membership_id INT NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(30),
    date_of_birth DATE,
    gender VARCHAR(20) CHECK (gender IN ('male', 'female', 'other')),
    registration_date DATE DEFAULT CURRENT_DATE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_member_membership
        FOREIGN KEY (membership_id)
        REFERENCES memberships(membership_id)
        ON DELETE CASCADE
);

CREATE TABLE trainers (
    trainer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(30) NOT NULL,
    date_of_birth DATE,
    gender VARCHAR(20) CHECK (gender IN ('male', 'female', 'other')),
    specialization VARCHAR(50),
    hire_date DATE DEFAULT CURRENT_DATE NOT NULL,
    experience_years INT CHECK (experience_years >= 0),
    is_active BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE workout_programs (
    workout_program_id SERIAL PRIMARY KEY,
    trainer_id INT NOT NULL,
    program_name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    difficulty_level VARCHAR(20) 
        CHECK (difficulty_level IN ('novice', 'intermediate', 'advanced')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    
    CONSTRAINT fk_program_trainer
        FOREIGN KEY (trainer_id)
        REFERENCES trainers(trainer_id)
        ON DELETE CASCADE
);

CREATE TABLE exercises (
    exercise_id SERIAL PRIMARY KEY,
    exercise_name VARCHAR(50) UNIQUE NOT NULL,
    target_muscle VARCHAR(100),
    description TEXT,
    equipment_required VARCHAR(50),
    difficulty_level VARCHAR(20)
        CHECK (difficulty_level IN ('novice', 'intermediate', 'advanced'))
);

CREATE TABLE payments (
    payment_id BIGSERIAL PRIMARY KEY,
    member_id INT NOT NULL,
    amount NUMERIC (8,2) NOT NULL,
    payment_date DATE DEFAULT CURRENT_DATE,
    payment_method VARCHAR(20) CHECK (payment_method IN ('cash', 'QR', 'card')),
    status VARCHAR(20) CHECK (status IN ('successful', 'pending', 'failed')) NOT NULL,
    transaction_reference VARCHAR(100) UNIQUE,

    CONSTRAINT fk_payment_member
        FOREIGN KEY (member_id)
        REFERENCES members(member_id)
        ON DELETE CASCADE
);

CREATE TABLE sessions (
    session_id BIGSERIAL PRIMARY KEY,
    member_id INT NOT NULL,
    check_in_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    session_type VARCHAR(20) CHECK (session_type IN ('gym', 'crossfit', 'yoga')),

    CONSTRAINT fk_session_member
        FOREIGN KEY (member_id)
        REFERENCES members(member_id)
        ON DELETE CASCADE
);

CREATE TABLE logs (
    log_id BIGSERIAL PRIMARY KEY,
    member_id INT NOT NULL,
    weight NUMERIC(5,2),
    body_fat_percentage NUMERIC (3, 1),
    notes TEXT,
    log_date DATE DEFAULT CURRENT_DATE,

    CONSTRAINT fk_log_member
        FOREIGN KEY (member_id)
        REFERENCES members(member_id)
        ON DELETE CASCADE
);

CREATE TABLE member_workout_programs (
    member_id INT NOT NULL,
    workout_program_id INT NOT NULL,
    start_date DATE DEFAULT CURRENT_DATE,
    status VARCHAR(20) CHECK (status IN ('active', 'completed', 'paused')) NOT NULL,
    PRIMARY KEY(member_id, workout_program_id),
    FOREIGN KEY(member_id) 
        REFERENCES members(member_id)
        ON DELETE CASCADE,

    FOREIGN KEY(workout_program_id) 
        REFERENCES workout_programs(workout_program_id)
        ON DELETE CASCADE
);

CREATE TABLE trainer_members (
    trainer_id INT NOT NULL,
    member_id INT NOT NULL,
    assigned_date DATE DEFAULT CURRENT_DATE,
    end_date DATE,
    notes TEXT,
    PRIMARY KEY(trainer_id, member_id),
    FOREIGN KEY(trainer_id)
        REFERENCES trainers(trainer_id)
        ON DELETE CASCADE,

    FOREIGN KEY(member_id)
        REFERENCES members(member_id)
        ON DELETE CASCADE
);

CREATE TABLE workout_program_exercises (
    workout_program_id INT NOT NULL,
    exercise_id INT NOT NULL,
    sets INT CHECK (sets > 0),
    reps INT CHECK (reps > 0),
    rest_seconds INT CHECK (rest_seconds >= 0),
    exercise_order INT,
    PRIMARY KEY(workout_program_id, exercise_id),
    FOREIGN KEY(workout_program_id)
        REFERENCES workout_programs(workout_program_id)
        ON DELETE CASCADE,

    FOREIGN KEY(exercise_id)
        REFERENCES exercises(exercise_id)
        ON DELETE CASCADE
);
