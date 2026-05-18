# API Examples

## Health Check

```bash
curl -s http://localhost:3000/health | jq
```

## Database Health Check

```bash
curl -s http://localhost:3000/db-health | jq
```

## Create User

```bash
curl -s -X POST http://localhost:3000/users \
  -H "Content-Type: application/json" \
  -d '{"email":"david@example.com"}' | jq
```

## List Users

```bash
curl -s http://localhost:3000/users | jq
```

## Create Account

```bash
curl -s -X POST http://localhost:3000/accounts \
  -H "Content-Type: application/json" \
  -d '{"user_id":4,"currency_code":"USD"}' | jq
```

## List Accounts

```bash
curl -s http://localhost:3000/accounts | jq
```

## Get Account Balance

```bash
curl -s http://localhost:3000/accounts/1/balance | jq
```

## Get Account Transaction History

```bash
curl -s http://localhost:3000/accounts/1/transactions | jq
```

## List Transactions

```bash
curl -s http://localhost:3000/transactions | jq
```

## Deposit

```bash
curl -s -X POST http://localhost:3000/transactions/deposit \
  -H "Content-Type: application/json" \
  -d '{"account_id":1,"amount":100,"reference_id":"api-deposit-alice-001"}' | jq
```

## Withdraw

```bash
curl -s -X POST http://localhost:3000/transactions/withdraw \
  -H "Content-Type: application/json" \
  -d '{"account_id":1,"amount":50,"reference_id":"api-withdraw-alice-001"}' | jq
```

## Transfer

```bash
curl -s -X POST http://localhost:3000/transactions/transfer \
  -H "Content-Type: application/json" \
  -d '{"sender_account_id":1,"receiver_account_id":2,"amount":25,"reference_id":"api-transfer-alice-bob-001"}' | jq
```

## Duplicate Reference ID Test

The same `reference_id` should not be processed twice.

```bash
curl -s -X POST http://localhost:3000/transactions/deposit \
  -H "Content-Type: application/json" \
  -d '{"account_id":1,"amount":100,"reference_id":"api-deposit-alice-001"}' | jq
```

Expected response:

```json
{
  "error": {
    "message": "Transaction with this reference_id already exists"
  }
}
```

## Insufficient Funds Test

```bash
curl -s -X POST http://localhost:3000/transactions/withdraw \
  -H "Content-Type: application/json" \
  -d '{"account_id":1,"amount":999999,"reference_id":"api-withdraw-too-much-001"}' | jq
```

Expected response:

```json
{
  "error": {
    "message": "Insufficient funds"
  }
}
```

## Transfer to Same Account Test

```bash
curl -s -X POST http://localhost:3000/transactions/transfer \
  -H "Content-Type: application/json" \
  -d '{"sender_account_id":1,"receiver_account_id":1,"amount":25,"reference_id":"api-transfer-same-account-001"}' | jq
```

Expected response:

```json
{
  "error": {
    "message": "Cannot transfer to the same account"
  }
}
```

## Missing Account Test

```bash
curl -s -X POST http://localhost:3000/transactions/transfer \
  -H "Content-Type: application/json" \
  -d '{"sender_account_id":1,"receiver_account_id":999,"amount":25,"reference_id":"api-transfer-missing-account-001"}' | jq
```

Expected response:

```json
{
  "error": {
    "message": "One or both accounts do not exist or are inactive"
  }
}
```
