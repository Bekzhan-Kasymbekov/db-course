# Authenticated API Examples

These examples assume that:

- PostgreSQL is running
- Keycloak is running
- the Express API is running
- the shell contains fresh access tokens

Example variables:

```bash
ADMIN_ACCESS_TOKEN=...
USER_ACCESS_TOKEN=...
AUDITOR_ACCESS_TOKEN=...
```

Access tokens are user-specific and expire. Request a new token after changing a user's roles, account state, or token mappings.

## Public Health Checks

```bash
curl -s http://localhost:3000/health | jq
```

```bash
curl -s http://localhost:3000/db-health | jq
```

## Inspect the Authenticated Identity

```bash
curl -s \
  -H "Authorization: Bearer $USER_ACCESS_TOKEN" \
  http://localhost:3000/auth/me |
jq
```

## Link a Keycloak User to a Local Wallet User

The first call creates the local user and returns `201 Created`.

Later calls return the existing linked user with `200 OK`.

```bash
curl -i \
  -X POST \
  -H "Authorization: Bearer $USER_ACCESS_TOKEN" \
  http://localhost:3000/users/me
```

## Create a Local User

Requires `wallet_admin`.

```bash
curl -s \
  -X POST \
  http://localhost:3000/users \
  -H "Authorization: Bearer $ADMIN_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"email":"david@example.com"}' |
jq
```

## List Users

Allowed for `wallet_admin` and `wallet_auditor`.

```bash
curl -s \
  -H "Authorization: Bearer $AUDITOR_ACCESS_TOKEN" \
  http://localhost:3000/users |
jq
```

## Create an Account

Requires `wallet_admin`.

```bash
curl -s \
  -X POST \
  http://localhost:3000/accounts \
  -H "Authorization: Bearer $ADMIN_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": 107,
    "currency_code": "USD"
  }' |
jq
```

## List Accounts

Allowed for `wallet_admin` and `wallet_auditor`.

```bash
curl -s \
  -H "Authorization: Bearer $AUDITOR_ACCESS_TOKEN" \
  http://localhost:3000/accounts |
jq
```

## View an Owned Account Balance

```bash
curl -s \
  -H "Authorization: Bearer $USER_ACCESS_TOKEN" \
  http://localhost:3000/accounts/105/balance |
jq
```

## View an Owned Account's Transactions

```bash
curl -s \
  -H "Authorization: Bearer $USER_ACCESS_TOKEN" \
  http://localhost:3000/accounts/105/transactions |
jq
```

A wallet user receives `403 Forbidden` when the requested account belongs to another local user.

## List All Transactions

Allowed for `wallet_admin` and `wallet_auditor`.

```bash
curl -s \
  -H "Authorization: Bearer $AUDITOR_ACCESS_TOKEN" \
  http://localhost:3000/transactions |
jq
```

## Deposit

The recommended authorization policy is to restrict deposits to `wallet_admin`.

```bash
curl -s \
  -X POST \
  http://localhost:3000/transactions/deposit \
  -H "Authorization: Bearer $ADMIN_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "account_id": 105,
    "amount": 100,
    "reference_id": "api-deposit-001"
  }' |
jq
```

Ownership should be checked against the sender account. A user may receive funds into an account they do not own, but must not transfer funds out of another user's account.

## Authorization Behavior Tests

### No token

```bash
curl -i http://localhost:3000/accounts/105/balance
```

Expected:

```text
401 Unauthorized
```

### Invalid token

```bash
curl -i \
  -H "Authorization: Bearer not-a-jwt" \
  http://localhost:3000/accounts/105/balance
```

Expected:

```text
401 Unauthorized
```

### Valid token, another user's account

```bash
curl -i \
  -H "Authorization: Bearer $USER_ACCESS_TOKEN" \
  http://localhost:3000/accounts/OTHER_ACCOUNT_ID/balance
```

Expected:

```text
403 Forbidden
```

### Valid token, nonexistent account

```bash
curl -i \
  -H "Authorization: Bearer $USER_ACCESS_TOKEN" \
  http://localhost:3000/accounts/999999/balance
```

Expected:

```text
404 Not Found
```

### Valid owner token

```bash
curl -i \
  -H "Authorization: Bearer $USER_ACCESS_TOKEN" \
  http://localhost:3000/accounts/105/balance
```

Expected:

```text
200 OK
```

## Financial Validation Tests

The existing wallet implementation should also reject:

- duplicate `reference_id` values
- withdrawals above the available balance
- transfers to the same account
- operations involving missing or inactive accounts
- zero or negative amounts
