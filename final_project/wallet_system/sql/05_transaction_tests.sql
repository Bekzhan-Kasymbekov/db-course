-- 05_transaction_tests.sql
-- Manual transaction tests for Digital Wallet & Ledger System

-- ============================================================
-- Check current balances before tests
-- ============================================================

SELECT
    a.id AS account_id,
    u.email,
    COALESCE(SUM(le.amount), 0) AS balance
FROM accounts a
JOIN users u
    ON u.id = a.user_id
LEFT JOIN ledger_entries le
    ON le.account_id = a.id
GROUP BY
    a.id,
    u.email
ORDER BY a.id;


-- ============================================================
-- Test 1: Deposit 200.00 into Alice's account
-- Account 1: Alice
-- ============================================================

BEGIN;

INSERT INTO transactions (transaction_type, status, reference_id)
VALUES ('deposit', 'pending', 'manual-deposit-alice-001')
RETURNING id;

-- Suppose returned transaction id is 7.
-- Replace 7 below if your returned id is different.

INSERT INTO ledger_entries (transaction_id, account_id, amount)
VALUES (7, 1, 200.00);

UPDATE transactions
SET status = 'completed'
WHERE id = 7;

COMMIT;


-- ============================================================
-- Test 2: Withdrawal 50.00 from Bob's account
-- Account 2: Bob
-- Uses SELECT ... FOR UPDATE to lock the account row.
-- ============================================================

BEGIN;

SELECT id
FROM accounts
WHERE id = 2
FOR UPDATE;

-- Check Bob's balance before withdrawal.
SELECT
    COALESCE(SUM(amount), 0) AS current_balance
FROM ledger_entries
WHERE account_id = 2;

INSERT INTO transactions (transaction_type, status, reference_id)
VALUES ('withdrawal', 'pending', 'manual-withdraw-bob-001')
RETURNING id;

-- Suppose returned transaction id is 8.
-- Replace 8 below if your returned id is different.

INSERT INTO ledger_entries (transaction_id, account_id, amount)
VALUES (8, 2, -50.00);

UPDATE transactions
SET status = 'completed'
WHERE id = 8;

COMMIT;


-- ============================================================
-- Test 3: Transfer 100.00 from Alice to Charlie
-- Account 1: Alice
-- Account 3: Charlie
-- Locks both accounts in stable order to reduce deadlock risk.
-- ============================================================

BEGIN;

SELECT id
FROM accounts
WHERE id IN (1, 3)
ORDER BY id
FOR UPDATE;

-- Check Alice's balance before transfer.
SELECT
    COALESCE(SUM(amount), 0) AS current_balance
FROM ledger_entries
WHERE account_id = 1;

INSERT INTO transactions (transaction_type, status, reference_id)
VALUES ('transfer', 'pending', 'manual-transfer-alice-charlie-001')
RETURNING id;

-- Suppose returned transaction id is 9.
-- Replace 9 below if your returned id is different.

INSERT INTO ledger_entries (transaction_id, account_id, amount)
VALUES
    (9, 1, -100.00),
    (9, 3, 100.00);

UPDATE transactions
SET status = 'completed'
WHERE id = 9;

COMMIT;


-- ============================================================
-- Test 4: Failed withdrawal example
-- This demonstrates rollback behavior.
-- Try to withdraw 999999.00 from Charlie.
-- ============================================================

BEGIN;

SELECT id
FROM accounts
WHERE id = 3
FOR UPDATE;

SELECT
    COALESCE(SUM(amount), 0) AS current_balance
FROM ledger_entries
WHERE account_id = 3;

-- We intentionally do not insert ledger entries here.
-- In real backend logic, if current_balance < withdrawal_amount,
-- the application would ROLLBACK.

ROLLBACK;


-- ============================================================
-- Final balance check
-- ============================================================

SELECT
    a.id AS account_id,
    u.email,
    COALESCE(SUM(le.amount), 0) AS balance
FROM accounts a
JOIN users u
    ON u.id = a.user_id
LEFT JOIN ledger_entries le
    ON le.account_id = a.id
GROUP BY
    a.id,
    u.email
ORDER BY a.id;
