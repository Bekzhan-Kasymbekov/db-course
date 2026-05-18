# Backup and Restore Strategy

## Goal

The Digital Wallet & Ledger System stores financial data in PostgreSQL.  
A backup and restore strategy is required to protect users, accounts, transactions, and immutable ledger entries.

## Backup Using pg_dump

Create a compressed backup:

```bash
pg_dump -h localhost -U postgres -d wallet_system -F c -f backups/wallet_system.backup
