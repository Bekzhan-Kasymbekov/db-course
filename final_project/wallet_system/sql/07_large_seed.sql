-- 07_large_seed.sql
-- Modest large seed for index and EXPLAIN ANALYZE testing
--
-- Creates:
-- 100 users
-- 100 accounts
-- 2,100 transactions
-- 3,100 ledger entries
--
-- This file resets the database data first.

TRUNCATE TABLE ledger_entries, transactions, accounts, users
RESTART IDENTITY CASCADE;


-- ============================================================
-- USERS
-- ============================================================

INSERT INTO users (email)
SELECT
    'user' || gs || '@example.com'
FROM generate_series(1, 100) AS gs;


-- ============================================================
-- ACCOUNTS
-- ============================================================

INSERT INTO accounts (user_id, currency_code)
SELECT
    gs,
    'USD'
FROM generate_series(1, 100) AS gs;


-- ============================================================
-- INITIAL DEPOSITS
-- One initial deposit of 1000.00 per account
-- ============================================================

INSERT INTO transactions (transaction_type, status, reference_id)
SELECT
    'deposit',
    'completed',
    'large-initial-deposit-' || LPAD(gs::TEXT, 4, '0')
FROM generate_series(1, 100) AS gs;

INSERT INTO ledger_entries (transaction_id, account_id, amount)
SELECT
    t.id,
    gs AS account_id,
    1000.00
FROM generate_series(1, 100) AS gs
JOIN transactions t
    ON t.reference_id = 'large-initial-deposit-' || LPAD(gs::TEXT, 4, '0');


-- ============================================================
-- EXTRA DEPOSITS
-- 1000 deposit transactions
-- 1000 positive ledger entries
-- ============================================================

INSERT INTO transactions (transaction_type, status, reference_id)
SELECT
    'deposit',
    'completed',
    'large-deposit-' || LPAD(gs::TEXT, 4, '0')
FROM generate_series(1, 1000) AS gs;

INSERT INTO ledger_entries (transaction_id, account_id, amount)
SELECT
    t.id,
    ((gs - 1) % 100) + 1 AS account_id,
    ((gs % 50) + 1)::NUMERIC(18,2) AS amount
FROM generate_series(1, 1000) AS gs
JOIN transactions t
    ON t.reference_id = 'large-deposit-' || LPAD(gs::TEXT, 4, '0');


-- ============================================================
-- WITHDRAWALS
-- 1000 withdrawal transactions
-- 1000 negative ledger entries
-- Amounts are small because each account already has enough balance.
-- ============================================================

INSERT INTO transactions (transaction_type, status, reference_id)
SELECT
    'withdrawal',
    'completed',
    'large-withdrawal-' || LPAD(gs::TEXT, 4, '0')
FROM generate_series(1, 1000) AS gs;

INSERT INTO ledger_entries (transaction_id, account_id, amount)
SELECT
    t.id,
    ((gs - 1) % 100) + 1 AS account_id,
    -((gs % 20) + 1)::NUMERIC(18,2) AS amount
FROM generate_series(1, 1000) AS gs
JOIN transactions t
    ON t.reference_id = 'large-withdrawal-' || LPAD(gs::TEXT, 4, '0');


-- ============================================================
-- TRANSFERS
-- 1000 transfer transactions
-- 2000 ledger entries
-- Each transfer creates:
-- sender:   negative amount
-- receiver: positive amount
-- ============================================================

INSERT INTO transactions (transaction_type, status, reference_id)
SELECT
    'transfer',
    'completed',
    'large-transfer-' || LPAD(gs::TEXT, 4, '0')
FROM generate_series(1, 1000) AS gs;

INSERT INTO ledger_entries (transaction_id, account_id, amount)
SELECT
    t.id,
    ((gs - 1) % 100) + 1 AS account_id,
    -((gs % 15) + 1)::NUMERIC(18,2) AS amount
FROM generate_series(1, 1000) AS gs
JOIN transactions t
    ON t.reference_id = 'large-transfer-' || LPAD(gs::TEXT, 4, '0')

UNION ALL

SELECT
    t.id,
    (gs % 100) + 1 AS account_id,
    ((gs % 15) + 1)::NUMERIC(18,2) AS amount
FROM generate_series(1, 1000) AS gs
JOIN transactions t
    ON t.reference_id = 'large-transfer-' || LPAD(gs::TEXT, 4, '0');


-- ============================================================
-- SUMMARY CHECKS
-- ============================================================

SELECT 'users' AS table_name, COUNT(*) AS row_count
FROM users

UNION ALL

SELECT 'accounts' AS table_name, COUNT(*) AS row_count
FROM accounts

UNION ALL

SELECT 'transactions' AS table_name, COUNT(*) AS row_count
FROM transactions

UNION ALL

SELECT 'ledger_entries' AS table_name, COUNT(*) AS row_count
FROM ledger_entries;


-- ============================================================
-- BALANCE CHECK
-- Should return no rows.
-- ============================================================

SELECT
    a.id AS account_id,
    COALESCE(SUM(le.amount), 0) AS balance
FROM accounts a
LEFT JOIN ledger_entries le
    ON le.account_id = a.id
GROUP BY a.id
HAVING COALESCE(SUM(le.amount), 0) < 0;


-- ============================================================
-- TRANSFER CONSERVATION CHECK
-- Should return no rows.
-- ============================================================

SELECT
    t.id AS transaction_id,
    t.reference_id,
    SUM(le.amount) AS transfer_sum
FROM transactions t
JOIN ledger_entries le
    ON le.transaction_id = t.id
WHERE t.transaction_type = 'transfer'
GROUP BY
    t.id,
    t.reference_id
HAVING SUM(le.amount) <> 0;
