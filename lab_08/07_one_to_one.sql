-- DELETE TO MAKE REPRODUCIBLE

DROP TABLE IF EXISTS passports CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- ONE-TO-ONE RELATIONSHIP

CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL
);

CREATE TABLE passports (
    user_id INT PRIMARY KEY
        REFERENCES users(user_id)
        ON DELETE CASCADE,
    passport_number VARCHAR(50) NOT NULL
);

INSERT INTO users (username) VALUES 
    ('bekkas'), 
    ('bekzhankas');
INSERT INTO passports VALUES (1, 'AB1234567890');

BEGIN;

INSERT INTO passports VALUES (1, 'ZB1234567890');

ROLLBACK;

SELECT 'ONE-TO-ONE';
SELECT * FROM users;
SELECT * FROM passports;
