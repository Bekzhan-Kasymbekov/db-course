# Index Analysis

## Dataset

The index analysis was tested using `sql/07_large_seed.sql`.

The large seed creates approximately:

```text
100 users
100 accounts
3100 transactions
4100 ledger entries
```

This provides a larger dataset than the small demo seed and makes index behavior easier to observe.

---

## Balance Lookup Query

Query:

```sql
EXPLAIN ANALYZE
SELECT COALESCE(SUM(amount), 0) AS balance
FROM ledger_entries
WHERE account_id = 1;
```

Result summary:

PostgreSQL used the index `idx_ledger_entries_account_created_at`.

Important part of the query plan:

```text
Bitmap Index Scan on idx_ledger_entries_account_created_at
Index Cond: (account_id = 1)
```

The query returned 41 ledger entries for account 1.

Execution time:

```text
0.287 ms
```

This supports the indexing strategy because balance lookup is one of the most common operations in the wallet system.

---

## Account Transaction History Query

Query:

```sql
EXPLAIN ANALYZE
SELECT *
FROM ledger_entries
WHERE account_id = 1
ORDER BY created_at DESC;
```

Result summary:

PostgreSQL used the index `idx_ledger_entries_account_created_at`.

Important part of the query plan:

```text
Bitmap Index Scan on idx_ledger_entries_account_created_at
Index Cond: (account_id = 1)
```

The query returned 41 rows.

Execution time:

```text
0.291 ms
```

The plan also included a sort step:

```text
Sort Key: created_at DESC
Sort Method: quicksort
```

This means PostgreSQL used the index to find ledger entries for the account, then sorted the matching rows by `created_at DESC`. Since only 41 rows matched, the sort was cheap.

---

## Transaction Type Query

Query:

```sql
EXPLAIN ANALYZE
SELECT *
FROM transactions
WHERE transaction_type = 'transfer';
```

Result summary:

PostgreSQL used the index `idx_transactions_type`.

Important part of the query plan:

```text
Bitmap Index Scan on idx_transactions_type
Index Cond: ((transaction_type)::text = 'transfer'::text)
```

The query returned 1000 transfer transactions.

Execution time:

```text
0.688 ms
```

This shows that indexing `transaction_type` is useful for filtering transactions by operation type.

---

## Transaction Status Query

Query:

```sql
EXPLAIN ANALYZE
SELECT *
FROM transactions
WHERE status = 'completed';
```

Result summary:

PostgreSQL used a sequential scan:

```text
Seq Scan on transactions
Filter: ((status)::text = 'completed'::text)
```

The query returned all 3100 transactions.

Execution time:

```text
2.212 ms
```

This is expected because all transactions in the large seed have status `completed`. Since almost every row matches the filter, PostgreSQL decided that scanning the full table was cheaper than using the index.

This demonstrates an important indexing concept:

```text
An index is most useful when it filters out many rows.
If most rows match the condition, a sequential scan can be faster.
```

---

## Conclusion

The index analysis shows that PostgreSQL used indexes for important wallet operations:

- balance lookup by account
- account transaction history lookup
- transaction filtering by type

The status query used a sequential scan because all rows had the same status. This is normal query planner behavior and does not mean the index is wrong.

The indexing strategy is still useful for a production-style system because real transaction tables may contain a mix of statuses such as:

```text
pending
completed
failed
```

In that case, filtering by status could become more selective and the index may be used.
