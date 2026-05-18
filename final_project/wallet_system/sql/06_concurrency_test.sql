-- 06_concurrency_test.sql
-- Manual concurrency test for Digital Wallet & Ledger System
--
-- This test must be run using two separate psql sessions.
--
-- Goal:
-- Demonstrate that SELECT ... FOR UPDATE locks an account row.
-- This prevents two simultaneous withdrawals/transfers from spending
-- the same balance at the same time.


-- ============================================================
-- SETUP
-- ============================================================
--
-- Before running this test, reset the database:
--
-- psql -h localhost -U postgres -d wallet_system -f 01_schema.sql
-- psql -h localhost -U postgres -d wallet_system -f 02_indexes.sql
-- psql -h localhost -U postgres -d wallet_system -f 03_seed.sql
--
-- Then open TWO terminals:
--
-- Terminal 1:
-- psql -h localhost -U postgres -d wallet_system
--
-- Terminal 2:
-- psql -h localhost -U postgres -d wallet_system


-- ============================================================
-- INITIAL BALANCE CHECK
-- Run this in either terminal.
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


-- Expected after 03_seed.sql:
--
-- Alice   account_id = 1, balance = 925.00
-- Bob     account_id = 2, balance = 550.00
-- Charlie account_id = 3, balance = 225.00


-- ============================================================
-- TEST: TWO CONCURRENT WITHDRAWALS FROM ALICE
-- ============================================================
--
-- We will try to withdraw from Alice's account in two sessions.
-- Alice starts with 925.00.
--
-- Terminal 1 will lock Alice's account and hold the transaction open.
-- Terminal 2 will try to lock the same account and should wait/block.


-- ============================================================
-- TERMINAL 1
-- ============================================================

BEGIN;

SELECT id
FROM accounts
WHERE id = 1
FOR UPDATE;

-- Check Alice's balance.
SELECT
    COALESCE(SUM(amount), 0) AS current_balance
FROM ledger_entries
WHERE account_id = 1;

-- Do not commit yet.
-- Leave this transaction open.
-- Now go to Terminal 2.


-- ============================================================
-- TERMINAL 2
-- ============================================================

BEGIN;

SELECT id
FROM accounts
WHERE id = 1
FOR UPDATE;

-- This query should block/wait because Terminal 1 already locked account 1.
-- It will continue only after Terminal 1 runs COMMIT or ROLLBACK.


-- ============================================================
-- TERMINAL 1
-- Finish the first withdrawal.
-- ============================================================

INSERT INTO transactions (transaction_type, status, reference_id)
VALUES ('withdrawal', 'pending', 'concurrency-withdraw-alice-001')
RETURNING id;

-- If returned id is 7, use 7 below.
-- If different, replace it.

INSERT INTO ledger_entries (transaction_id, account_id, amount)
VALUES (7, 1, -700.00);

UPDATE transactions
SET status = 'completed'
WHERE id = 7;

COMMIT;


-- ============================================================
-- TERMINAL 2
-- After Terminal 1 commits, the blocked SELECT FOR UPDATE should finish.
-- Now Terminal 2 must re-check the balance.
-- ============================================================

SELECT
    COALESCE(SUM(amount), 0) AS current_balance
FROM ledger_entries
WHERE account_id = 1;

-- Expected balance:
-- Alice had 925.00.
-- Terminal 1 withdrew 700.00.
-- New balance is 225.00.
--
-- If Terminal 2 also wanted to withdraw 300.00, it should now fail
-- because 225.00 < 300.00.
--
-- Therefore, rollback Terminal 2.

ROLLBACK;


-- ============================================================
-- FINAL BALANCE CHECK
-- Run in either terminal.
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


-- Expected final balance:
-- Alice = 225.00
-- Bob = 550.00
-- Charlie = 225.00
