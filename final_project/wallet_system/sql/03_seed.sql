-- 03_seed.sql
-- Sample data for Digital Wallet & Ledger System

-- Clear existing data in dependency order.
-- This is useful while developing and rerunning the seed file.
TRUNCATE TABLE ledger_entries, transactions, accounts, users
RESTART IDENTITY CASCADE;


-- ============================================================
-- USERS
-- ============================================================

INSERT INTO users (email)
VALUES
    ('alice@example.com'),
    ('bob@example.com'),
    ('charlie@example.com');


-- ============================================================
-- ACCOUNTS
-- ============================================================

INSERT INTO accounts (user_id, currency_code)
VALUES
    (1, 'USD'), -- Alice account
    (2, 'USD'), -- Bob account
    (3, 'USD'); -- Charlie account


-- ============================================================
-- TRANSACTIONS + LEDGER ENTRIES
-- ============================================================

-- Alice deposits 1000.00
INSERT INTO transactions (transaction_type, status, reference_id)
VALUES ('deposit', 'completed', 'seed-deposit-alice-001');

INSERT INTO ledger_entries (transaction_id, account_id, amount)
VALUES (1, 1, 1000.00);


-- Bob deposits 500.00
INSERT INTO transactions (transaction_type, status, reference_id)
VALUES ('deposit', 'completed', 'seed-deposit-bob-001');

INSERT INTO ledger_entries (transaction_id, account_id, amount)
VALUES (2, 2, 500.00);


-- Alice transfers 150.00 to Bob
INSERT INTO transactions (transaction_type, status, reference_id)
VALUES ('transfer', 'completed', 'seed-transfer-alice-bob-001');

INSERT INTO ledger_entries (transaction_id, account_id, amount)
VALUES
    (3, 1, -150.00),
    (3, 2, 150.00);


-- Bob withdraws 100.00
INSERT INTO transactions (transaction_type, status, reference_id)
VALUES ('withdrawal', 'completed', 'seed-withdraw-bob-001');

INSERT INTO ledger_entries (transaction_id, account_id, amount)
VALUES (4, 2, -100.00);


-- Charlie deposits 300.00
INSERT INTO transactions (transaction_type, status, reference_id)
VALUES ('deposit', 'completed', 'seed-deposit-charlie-001');

INSERT INTO ledger_entries (transaction_id, account_id, amount)
VALUES (5, 3, 300.00);


-- Charlie transfers 75.00 to Alice
INSERT INTO transactions (transaction_type, status, reference_id)
VALUES ('transfer', 'completed', 'seed-transfer-charlie-alice-001');

INSERT INTO ledger_entries (transaction_id, account_id, amount)
VALUES
    (6, 3, -75.00),
    (6, 1, 75.00);
