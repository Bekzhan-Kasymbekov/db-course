# Digital Wallet & Ledger System

A PostgreSQL and Node.js backend project that implements a ledger-based digital wallet system.

The system does not store account balances directly. Instead, balances are derived from immutable ledger entries.

---

## Project Objective

The goal of this project is to design and implement a production-style financial backend system that demonstrates:

- normalized relational schema design
- PostgreSQL implementation
- ledger-based accounting
- SQL constraints and indexes
- basic and advanced SQL queries
- transaction safety
- rollback behavior
- concurrency control using `SELECT ... FOR UPDATE`
- backup and restore strategy
- Node.js backend integration
- SQL injection prevention using parameterized queries

---

## Technology Stack

- PostgreSQL
- Node.js
- Express
- pg
- dotenv
- nodemon
- Ubuntu Linux

---

## Core Idea

Balances are not stored in the `accounts` table.

Instead, an account balance is calculated from the sum of its ledger entries:

```sql
SELECT COALESCE(SUM(amount), 0) AS balance
FROM ledger_entries
WHERE account_id = $1;
```

Positive ledger entries increase balance.

Negative ledger entries decrease balance.

---

## Main Entities

### users

Stores wallet users.

Important fields:

- `id`
- `email`
- `created_at`

### accounts

Stores wallet accounts owned by users.

Important fields:

- `id`
- `user_id`
- `currency_code`
- `is_active`
- `created_at`

One user can have multiple accounts.

### transactions

Stores logical financial operations.

Important fields:

- `id`
- `transaction_type`
- `status`
- `reference_id`
- `created_at`

The `transactions` table does not store money amounts directly.

### ledger_entries

Stores actual money movement.

Important fields:

- `id`
- `transaction_id`
- `account_id`
- `amount`
- `created_at`

Positive amount means credit.

Negative amount means debit.

---

## ER Diagram

The ER diagram is available in:

```text
docs/wallet_system_erd.png
```
---

## Relationships

```text
users 1 ---- many accounts

accounts 1 ---- many ledger_entries

transactions 1 ---- many ledger_entries
```

A transaction can create one or more ledger entries.

For example, a transfer creates two ledger entries:

```text
-25.00 from sender account
+25.00 to receiver account
```
---

## Ledger Rules

### Deposit

A deposit creates:

- one transaction row
- one positive ledger entry

Example:

```text
+100.00 to account 1
```

### Withdrawal

A withdrawal creates:

- one transaction row
- one negative ledger entry

Example:

```text
-50.00 from account 1
```

The backend checks the account balance before inserting the ledger entry.

### Transfer

A transfer creates:

- one transaction row
- two ledger entries

Example:

```text
-25.00 from sender account
+25.00 to receiver account
```

The sum of transfer ledger entries must be zero:

```text
-25.00 + 25.00 = 0.00
```

---

## System Invariants

The system follows these rules:

1. Every account belongs to one user.
2. Every ledger entry belongs to one account.
3. Every ledger entry belongs to one transaction.
4. Account balances are not stored directly.
5. Account balances are derived from `SUM(ledger_entries.amount)`.
6. Ledger entry amount cannot be zero.
7. Money values use `NUMERIC(18,2)`.
8. Transaction `reference_id` is unique.
9. Withdrawals cannot make balance negative.
10. Transfers cannot make sender balance negative.
11. Transfers must conserve money.
12. Financial operations are atomic.

More details are documented in:

```text
docs/invariants.md
```

---

## Project Structure

```text
wallet_system/
├── docs
│   ├── api_examples.md
│   ├── backup_restore.md
│   ├── index_analysis.md
│   ├── invariants.md
│   ├── Wallet_ledger_system_presentation.pdf
│   ├── Completion_Certificate_Oracle_Database_Foundations.png
│   └── wallet_system_erd.md
├── package.json
├── package-lock.json
├── README.md
├── sql
│   ├── 01_schema.sql
│   ├── 02_indexes.sql
│   ├── 03_seed.sql
│   ├── 04_queries.sql
│   ├── 05_transaction_tests.sql
│   ├── 06_concurrency_test.sql
│   ├── 07_large_seed.sql
│   └── schema_notes.txt
└── src
    ├── app.js
    ├── config
    │   └── index.js
    ├── db
    │   └── index.js
    ├── middlewares
    │   └── errorHandler.js
    ├── routes
    │   ├── accounts.js
    │   ├── transactions.js
    │   └── users.js
    ├── server.js
    ├── services
    │   ├── accountService.js
    │   ├── transactionService.js
    │   └── userService.js
    └── utils
        └── validators.js
```

---

## Database Files

### `sql/01_schema.sql`

Creates the main tables:

- `users`
- `accounts`
- `transactions`
- `ledger_entries`

Includes:

- primary keys
- foreign keys
- unique constraints
- check constraints
- default values

### `sql/02_indexes.sql`

Creates indexes for performance.

Important indexes include:

- account lookup by user
- balance lookup by account
- transaction history lookup
- transaction status/type filtering

### `sql/03_seed.sql`

Inserts small readable demo data.

### `sql/04_queries.sql`

Contains useful SQL queries:

- list users
- list accounts
- calculate balances
- transaction history
- transfer conservation checks
- negative balance checks
- window function examples
- `EXPLAIN ANALYZE` examples

### `sql/05_transaction_tests.sql`

Demonstrates manual SQL transactions:

- `BEGIN`
- `COMMIT`
- `ROLLBACK`
- deposit
- withdrawal
- transfer
- failed withdrawal

### `sql/06_concurrency_test.sql`

Documents a manual two-terminal concurrency test using:

```sql
SELECT ... FOR UPDATE;
```

### `sql/07_large_seed.sql`

Creates a modest larger dataset for index analysis:

```text
100 users
100 accounts
3100 transactions
4100 ledger entries
```

---

## Setup Instructions

### 1. Install dependencies

```bash
npm install
```

### 2. Create `.env`

Create a `.env` file in the project root:

```env
PORT=3000

DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=your_postgres_password
DB_NAME=wallet_system
```

### 3. Create the database

```bash
createdb -h localhost -U postgres wallet_system
```

### 4. Run SQL files

For small demo data:

```bash
psql -h localhost -U postgres -d wallet_system -f sql/01_schema.sql
psql -h localhost -U postgres -d wallet_system -f sql/02_indexes.sql
psql -h localhost -U postgres -d wallet_system -f sql/03_seed.sql
```

For large seed/index analysis data:

```bash
psql -h localhost -U postgres -d wallet_system -f sql/07_large_seed.sql
```

### 5. Start the backend server

```bash
npm run dev
```

Expected output:

```text
Wallet system server running on port 3000
```

---

## API Endpoints

### Health

```http
GET /health
GET /db-health
```

### Users

```http
POST /users
GET /users
```

### Accounts

```http
POST /accounts
GET /accounts
GET /accounts/:id/balance
GET /accounts/:id/transactions
```

### Transactions

```http
GET /transactions
POST /transactions/deposit
POST /transactions/withdraw
POST /transactions/transfer
```

Full curl examples are documented in:

```text
docs/api_examples.md
```

---

## Example API Requests

### Create User

```bash
curl -s -X POST http://localhost:3000/users \
  -H "Content-Type: application/json" \
  -d '{"email":"david@example.com"}' | jq
```

### Create Account

```bash
curl -s -X POST http://localhost:3000/accounts \
  -H "Content-Type: application/json" \
  -d '{"user_id":4,"currency_code":"USD"}' | jq
```

### Get Balance

```bash
curl -s http://localhost:3000/accounts/1/balance | jq
```

### Get Account Transaction History

```bash
curl -s http://localhost:3000/accounts/1/transactions | jq
```

### Deposit

```bash
curl -s -X POST http://localhost:3000/transactions/deposit \
  -H "Content-Type: application/json" \
  -d '{"account_id":1,"amount":100,"reference_id":"api-deposit-alice-001"}' | jq
```

### Withdraw

```bash
curl -s -X POST http://localhost:3000/transactions/withdraw \
  -H "Content-Type: application/json" \
  -d '{"account_id":1,"amount":50,"reference_id":"api-withdraw-alice-001"}' | jq
```

### Transfer

```bash
curl -s -X POST http://localhost:3000/transactions/transfer \
  -H "Content-Type: application/json" \
  -d '{"sender_account_id":1,"receiver_account_id":2,"amount":25,"reference_id":"api-transfer-alice-bob-001"}' | jq
```

---

## Transaction Safety

Financial operations run inside PostgreSQL transactions.

General flow:

```text
BEGIN
lock account row
validate account state
check balance if needed
insert transaction row
insert ledger entry or entries
update transaction status
COMMIT
```

If anything fails:

```text
ROLLBACK
```

This prevents partial financial operations from being saved.

---

## Concurrency Control

Withdrawals and transfers use row-level locking.

For one account:

```sql
SELECT id
FROM accounts
WHERE id = $1 AND is_active = TRUE
FOR UPDATE;
```

For transfers, both accounts are locked in stable order:

```sql
SELECT id
FROM accounts
WHERE id IN ($1, $2) AND is_active = TRUE
ORDER BY id
FOR UPDATE;
```

This prevents concurrent operations from spending the same balance at the same time.

---

## Idempotency

Each transaction has a unique `reference_id`.

This prevents duplicate processing.

Example:

```json
{
  "reference_id": "api-transfer-alice-bob-001"
}
```

If the same `reference_id` is submitted again, PostgreSQL rejects it because of the unique constraint.

---

## Indexing Strategy

Indexes are used on columns frequently used for:

- joins
- filtering
- ordering
- balance lookup
- transaction history lookup

Important examples:

```sql
CREATE INDEX IF NOT EXISTS idx_ledger_entries_account_id
ON ledger_entries(account_id);

CREATE INDEX IF NOT EXISTS idx_ledger_entries_account_created_at
ON ledger_entries(account_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_ledger_entries_transaction_id
ON ledger_entries(transaction_id);
```

Index results are documented in:

```text
docs/index_analysis.md
```

---

## Backup and Restore

A compressed PostgreSQL backup can be created with:

```bash
pg_dump -h localhost -U postgres -d wallet_system -F c -f backups/wallet_system.backup
```

Restore into a new database:

```bash
createdb -h localhost -U postgres wallet_system_restore
pg_restore -h localhost -U postgres -d wallet_system_restore backups/wallet_system.backup
```

More details are documented in:

```text
docs/backup_restore.md
```

---

## Security Notes

The backend uses parameterized SQL queries through the `pg` library.

Example:

```js
await pool.query(
    'SELECT * FROM accounts WHERE id = $1',
    [account_id]
);
```

This protects against SQL injection for user-provided values.

The `.env` file is ignored and should not be committed to GitHub.

---

## Implemented Features

- PostgreSQL schema
- indexes
- small seed data
- large seed data
- advanced SQL queries
- transaction tests
- concurrency test
- backup and restore documentation
- Express backend
- PostgreSQL connection pool
- user creation
- account creation
- account balance lookup
- account transaction history
- deposit
- withdrawal
- transfer
- error handling
- input validation
- idempotency via unique `reference_id`

---

## Author

Bekzhan Kasymbekov
