-- 02_indexes.sql
-- Indexes for Digital Wallet & Ledger System

-- Speeds up finding all accounts that belong to a user.
CREATE INDEX IF NOT EXISTS idx_accounts_user_id
ON accounts(user_id);

-- Speeds up balance calculation for one account:
-- SELECT SUM(amount) FROM ledger_entries WHERE account_id = ?;
CREATE INDEX IF NOT EXISTS idx_ledger_entries_account_id
ON ledger_entries(account_id);

-- Speeds up finding all ledger entries for a transaction.
CREATE INDEX IF NOT EXISTS idx_ledger_entries_transaction_id
ON ledger_entries(transaction_id);

-- Speeds up transaction history ordered by time for an account.
CREATE INDEX IF NOT EXISTS idx_ledger_entries_account_created_at
ON ledger_entries(account_id, created_at DESC);

-- Speeds up filtering transactions by type.
CREATE INDEX IF NOT EXISTS idx_transactions_type
ON transactions(transaction_type);

-- Speeds up filtering transactions by status.
CREATE INDEX IF NOT EXISTS idx_transactions_status
ON transactions(status);

-- Speeds up chronological transaction queries.
CREATE INDEX IF NOT EXISTS idx_transactions_created_at
ON transactions(created_at DESC);
