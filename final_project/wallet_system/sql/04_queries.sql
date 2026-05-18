-- 04_queries.sql
-- Useful queries for Digital Wallet & Ledger System


-- ============================================================
-- 1. Show all users
-- ============================================================

SELECT
    id AS user_id,
    email,
    created_at
FROM users
ORDER BY id;


-- ============================================================
-- 2. Show all accounts with owner information
-- ============================================================

SELECT
    a.id AS account_id,
    u.id AS user_id,
    u.email,
    a.currency_code,
    a.is_active,
    a.created_at
FROM accounts a
JOIN users u
    ON u.id = a.user_id
ORDER BY a.id;


-- ============================================================
-- 3. Calculate balance for every account
-- ============================================================

SELECT
    a.id AS account_id,
    u.email,
    a.currency_code,
    COALESCE(SUM(le.amount), 0) AS balance
FROM accounts a
JOIN users u
    ON u.id = a.user_id
LEFT JOIN ledger_entries le
    ON le.account_id = a.id
GROUP BY
    a.id,
    u.email,
    a.currency_code
ORDER BY a.id;


-- ============================================================
-- 4. Calculate balance for one account
-- Change account_id value as needed.
-- ============================================================

SELECT
    a.id AS account_id,
    u.email,
    a.currency_code,
    COALESCE(SUM(le.amount), 0) AS balance
FROM accounts a
JOIN users u
    ON u.id = a.user_id
LEFT JOIN ledger_entries le
    ON le.account_id = a.id
WHERE a.id = 1
GROUP BY
    a.id,
    u.email,
    a.currency_code;


-- ============================================================
-- 5. Show full transaction history with ledger entries
-- ============================================================

SELECT
    t.id AS transaction_id,
    t.transaction_type,
    t.status,
    t.reference_id,
    le.id AS ledger_entry_id,
    le.account_id,
    u.email AS account_owner,
    le.amount,
    le.created_at
FROM transactions t
JOIN ledger_entries le
    ON le.transaction_id = t.id
JOIN accounts a
    ON a.id = le.account_id
JOIN users u
    ON u.id = a.user_id
ORDER BY
    t.id,
    le.id;


-- ============================================================
-- 6. Show transaction history for one account
-- Change account_id value as needed.
-- ============================================================

SELECT
    t.id AS transaction_id,
    t.transaction_type,
    t.status,
    t.reference_id,
    le.amount,
    le.created_at
FROM ledger_entries le
JOIN transactions t
    ON t.id = le.transaction_id
WHERE le.account_id = 1
ORDER BY le.created_at DESC;


-- ============================================================
-- 7. Show only deposits
-- ============================================================

SELECT
    t.id AS transaction_id,
    t.reference_id,
    le.account_id,
    u.email,
    le.amount,
    le.created_at
FROM transactions t
JOIN ledger_entries le
    ON le.transaction_id = t.id
JOIN accounts a
    ON a.id = le.account_id
JOIN users u
    ON u.id = a.user_id
WHERE t.transaction_type = 'deposit'
ORDER BY t.id;


-- ============================================================
-- 8. Show only withdrawals
-- ============================================================

SELECT
    t.id AS transaction_id,
    t.reference_id,
    le.account_id,
    u.email,
    le.amount,
    le.created_at
FROM transactions t
JOIN ledger_entries le
    ON le.transaction_id = t.id
JOIN accounts a
    ON a.id = le.account_id
JOIN users u
    ON u.id = a.user_id
WHERE t.transaction_type = 'withdrawal'
ORDER BY t.id;


-- ============================================================
-- 9. Show only transfers
-- ============================================================

SELECT
    t.id AS transaction_id,
    t.reference_id,
    le.account_id,
    u.email,
    le.amount,
    le.created_at
FROM transactions t
JOIN ledger_entries le
    ON le.transaction_id = t.id
JOIN accounts a
    ON a.id = le.account_id
JOIN users u
    ON u.id = a.user_id
WHERE t.transaction_type = 'transfer'
ORDER BY
    t.id,
    le.amount;


-- ============================================================
-- 10. Check transfer conservation
-- For every transfer, the sum of ledger entries should be 0.
-- ============================================================

SELECT
    t.id AS transaction_id,
    t.reference_id,
    t.transaction_type,
    SUM(le.amount) AS total_amount
FROM transactions t
JOIN ledger_entries le
    ON le.transaction_id = t.id
WHERE t.transaction_type = 'transfer'
GROUP BY
    t.id,
    t.reference_id,
    t.transaction_type
HAVING SUM(le.amount) <> 0;


-- ============================================================
-- 11. Show completed transactions with number of ledger entries
-- Useful for verifying transaction structure.
-- ============================================================

SELECT
    t.id AS transaction_id,
    t.transaction_type,
    t.status,
    t.reference_id,
    COUNT(le.id) AS ledger_entry_count,
    SUM(le.amount) AS ledger_entry_sum
FROM transactions t
LEFT JOIN ledger_entries le
    ON le.transaction_id = t.id
GROUP BY
    t.id,
    t.transaction_type,
    t.status,
    t.reference_id
ORDER BY t.id;


-- ============================================================
-- 12. Find transactions without ledger entries
-- Ideally, completed transactions should not appear here.
-- ============================================================

SELECT
    t.id AS transaction_id,
    t.transaction_type,
    t.status,
    t.reference_id,
    t.created_at
FROM transactions t
LEFT JOIN ledger_entries le
    ON le.transaction_id = t.id
WHERE le.id IS NULL;


-- ============================================================
-- 13. Find accounts with negative balances
-- Ideally, this should return no rows.
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
HAVING COALESCE(SUM(le.amount), 0) < 0;


-- ============================================================
-- 14. Total credited and debited amount per account
-- ============================================================

SELECT
    a.id AS account_id,
    u.email,
    SUM(CASE WHEN le.amount > 0 THEN le.amount ELSE 0 END) AS total_credits,
    SUM(CASE WHEN le.amount < 0 THEN ABS(le.amount) ELSE 0 END) AS total_debits,
    COALESCE(SUM(le.amount), 0) AS current_balance
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
-- 15. Transaction volume by type
-- ============================================================

SELECT
    transaction_type,
    COUNT(*) AS transaction_count
FROM transactions
GROUP BY transaction_type
ORDER BY transaction_count DESC;


-- ============================================================
-- 16. Total money movement by transaction type
-- For deposits and withdrawals, this shows total absolute movement.
-- For transfers, the net sum should be zero.
-- ============================================================

SELECT
    t.transaction_type,
    COUNT(DISTINCT t.id) AS transaction_count,
    SUM(ABS(le.amount)) AS total_absolute_movement,
    SUM(le.amount) AS net_amount
FROM transactions t
JOIN ledger_entries le
    ON le.transaction_id = t.id
GROUP BY t.transaction_type
ORDER BY t.transaction_type;


-- ============================================================
-- 17. Account ranking by balance
-- Uses a window function.
-- ============================================================

WITH account_balances AS (
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
)
SELECT
    account_id,
    email,
    balance,
    RANK() OVER (ORDER BY balance DESC) AS balance_rank
FROM account_balances
ORDER BY balance_rank;


-- ============================================================
-- 18. Running balance for one account
-- Uses a window function.
-- Change account_id value as needed.
-- ============================================================

SELECT
    le.account_id,
    t.transaction_type,
    t.reference_id,
    le.amount,
    le.created_at,
    SUM(le.amount) OVER (
        PARTITION BY le.account_id
        ORDER BY le.created_at, le.id
    ) AS running_balance
FROM ledger_entries le
JOIN transactions t
    ON t.id = le.transaction_id
WHERE le.account_id = 1
ORDER BY
    le.created_at,
    le.id;


-- ============================================================
-- 19. Most recent ledger entries
-- ============================================================

SELECT
    le.id AS ledger_entry_id,
    le.account_id,
    u.email,
    t.transaction_type,
    t.reference_id,
    le.amount,
    le.created_at
FROM ledger_entries le
JOIN transactions t
    ON t.id = le.transaction_id
JOIN accounts a
    ON a.id = le.account_id
JOIN users u
    ON u.id = a.user_id
ORDER BY le.created_at DESC
LIMIT 10;


-- ============================================================
-- 20. EXPLAIN ANALYZE example for balance lookup
-- Useful for indexing demonstration.
-- ============================================================

EXPLAIN ANALYZE
SELECT
    COALESCE(SUM(amount), 0) AS balance
FROM ledger_entries
WHERE account_id = 1;


-- ============================================================
-- 21. EXPLAIN ANALYZE example for account transaction history
-- Useful for showing the composite index:
-- idx_ledger_entries_account_created_at
-- ============================================================

EXPLAIN ANALYZE
SELECT
    *
FROM ledger_entries
WHERE account_id = 1
ORDER BY created_at DESC;
