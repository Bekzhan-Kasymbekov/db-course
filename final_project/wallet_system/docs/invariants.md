# System Invariants and Ledger Rules

## Overview

The Digital Wallet & Ledger System uses a ledger-based accounting model.

Account balances are not stored directly in the `accounts` table. Instead, balances are calculated from the sum of ledger entries.

```sql
SELECT COALESCE(SUM(amount), 0) AS balance
FROM ledger_entries
WHERE account_id = ?;
```

This makes the ledger the source of truth.

---

## Core Invariants

1. Every account belongs to exactly one user.

2. Every ledger entry belongs to exactly one transaction.

3. Every ledger entry belongs to exactly one account.

4. Account balances are not stored directly.

5. Account balance is derived from:

```text
SUM(ledger_entries.amount)
```

6. Ledger entry amount cannot be zero.

7. Money values use `NUMERIC(18,2)`, not floating-point types.

8. Transaction `reference_id` must be unique.

9. Withdrawals cannot make an account balance negative.

10. Transfers cannot make the sender account balance negative.

11. Transfers must conserve money.

For each transfer:

```text
sender ledger entry + receiver ledger entry = 0
```

Example:

```text
-25.00 + 25.00 = 0.00
```

12. Ledger entries are append-only in design.

---

## Ledger Rules

## Deposit

A deposit creates:

- one transaction row
- one positive ledger entry

Example:

```text
Transaction type: deposit
Ledger entry: +100.00 to account 1
```

A deposit increases account balance.

---

## Withdrawal

A withdrawal creates:

- one transaction row
- one negative ledger entry

Example:

```text
Transaction type: withdrawal
Ledger entry: -50.00 from account 1
```

Before inserting the ledger entry, the backend checks the current balance.

If the balance is not enough, the operation is rolled back.

---

## Transfer

A transfer creates:

- one transaction row
- two ledger entries

Example:

```text
Transaction type: transfer
Ledger entry 1: -25.00 from sender account
Ledger entry 2: +25.00 to receiver account
```

The sum of the transfer ledger entries must be zero.

```text
-25.00 + 25.00 = 0.00
```

This guarantees that transfers do not create or destroy money.

---

## Concurrency Control

The backend uses PostgreSQL transactions and row-level locking.

Before withdrawal or transfer logic calculates the balance, the relevant account row is locked:

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

This prevents two concurrent operations from reading the same old balance and both spending it.

---

## Atomicity

Each financial operation runs inside a database transaction.

General flow:

```text
BEGIN
validate account
lock account row
check balance if needed
insert transaction row
insert ledger entry or entries
update transaction status
COMMIT
```

If any step fails:

```text
ROLLBACK
```

This ensures that partial financial operations are not saved.

---

## Idempotency

Each transaction has a unique `reference_id`.

This prevents the same API operation from being processed twice.

Example:

```json
{
  "reference_id": "api-transfer-alice-bob-001"
}
```

If the same `reference_id` is used again, PostgreSQL rejects it because of the unique constraint.

---

## Database-Enforced Rules

The database enforces:

- primary keys
- foreign keys
- unique user emails
- unique transaction reference IDs
- allowed transaction types
- allowed transaction statuses
- non-zero ledger amounts
- valid currency code format

---

## Backend-Enforced Rules

The backend enforces:

- no negative balances
- transfer sender and receiver must be different
- account must exist and be active
- transaction atomicity
- rollback on failure
- row-level locking with `SELECT ... FOR UPDATE`
