# Wallet Ledger API with Keycloak IAM

A ledger-based digital wallet backend built with **Express.js** and **PostgreSQL**, secured with **Keycloak**, OpenID Connect, JWT validation, role-based access control, and account ownership checks.

The project began as a database systems assignment and was later extended into a hands-on identity and access management lab.

Keycloak manages authentication and identity roles. PostgreSQL stores wallet users, accounts, transactions, and immutable ledger entries.

## Highlights

- Keycloak deployed locally with Docker Compose
- OpenID Connect access-token authentication
- JWT verification through Keycloak JWKS
- Signature, issuer, audience, and expiration validation using `jose`
- Realm roles:
  - `wallet_admin`
  - `wallet_auditor`
  - `wallet_user`
- Correct distinction between `401 Unauthorized` and `403 Forbidden`
- Keycloak identities linked to local users through the stable OIDC `sub` claim
- Object-level authorization restricting users to accounts they own
- PostgreSQL transactions and row locking for financial operations
- Immutable ledger entries with balances derived from `SUM(amount)`
- Parameterized SQL queries
- Unique transaction reference IDs for duplicate-request prevention

## Architecture

```text
Client
  |
  | 1. Authenticate and receive an access token
  v
Keycloak
OIDC identity provider
  |
  | 2. Authorization: Bearer <access-token>
  v
Express API
OAuth resource server
  |
  |-- verifies JWT signature using Keycloak JWKS
  |-- validates issuer, audience, and expiration
  |-- checks realm roles
  |-- checks account ownership using token.sub
  v
PostgreSQL
  |-- users
  |-- accounts
  |-- transactions
  `-- immutable ledger_entries
```

## Identity Relationship

The application links the authenticated Keycloak identity to a local PostgreSQL user.

```text
JWT sub claim
      ↓
users.keycloak_user_id
      ↓
accounts.user_id
```

The `sub` claim is a stable identifier for the authenticated Keycloak user.

This relationship allows the application to determine which wallet accounts belong to the current user.

## Authorization Model

| Operation | `wallet_admin` | `wallet_auditor` | `wallet_user` |
|---|:---:|:---:|:---:|
| List users | Yes | Yes | No |
| Create local users | Yes | No | No |
| List all accounts | Yes | Yes | No |
| Create accounts | Yes | No | No |
| View account balance | Any account | Any account | Own account only |
| View account transaction history | Any account | Any account | Own account only |
| Link Keycloak identity to local user | No | No | Yes |

IAM authorization has currently been applied to identity, user-management, and account-access routes.

The original deposit, withdrawal, transfer, and global transaction-listing routes remain part of the wallet application, but their Keycloak authorization hardening is planned as a later extension.

## Verified Access Outcomes

The following authentication and authorization outcomes were tested:

```text
Missing token                              → 401 Unauthorized
Invalid token                              → 401 Unauthorized
Token with an invalid audience             → 401 Unauthorized
Valid token without the required role      → 403 Forbidden
Wallet user accessing another account      → 403 Forbidden
Wallet user accessing their own account    → 200 OK
Authenticated request for missing account  → 404 Not Found
```

## Technology Stack

- Node.js
- Express.js
- PostgreSQL
- Keycloak
- OpenID Connect
- OAuth 2.0 access tokens
- JSON Web Tokens
- `jose`
- Docker Compose
- Git
- Bash
- curl
- jq

## Authentication Flow

For local command-line testing, the project uses Keycloak Direct Access Grants.

```text
1. A test client sends the client ID, client secret,
   username, and password to Keycloak.

2. Keycloak authenticates the client and user.

3. Keycloak returns a signed access token.

4. The client sends the token to Express:

   Authorization: Bearer <access-token>

5. Express retrieves Keycloak's public signing keys
   from the realm JWKS endpoint.

6. The API validates:
   - token signature
   - issuer
   - audience
   - expiration

7. The API reads roles and the sub claim from the
   verified token.

8. Express allows or denies access based on roles
   and account ownership.
```

Direct Access Grants are used only to simplify local command-line testing.

A browser-based application should use Authorization Code Flow rather than collecting the user's password directly.

## JWT Validation

The API validates access tokens using `jose`.

Keycloak publishes the realm's public signing keys through its JWKS endpoint:

```text
http://localhost:8080/realms/wallet/protocol/openid-connect/certs
```

The authentication middleware checks:

```text
Signature  → token was signed by the expected Keycloak realm
Issuer     → token came from the wallet realm
Audience   → token was intended for wallet-api
Expiration → token is still valid
```

A failed validation returns:

```text
401 Unauthorized
```

After validation, claims are stored in `req.auth` for later authorization checks.

## Role-Based Authorization

The API uses Keycloak realm roles:

```text
wallet_admin
wallet_auditor
wallet_user
```

Role checks happen only after the token has been authenticated.

```text
Missing or invalid token
        ↓
401 Unauthorized

Valid token without required role
        ↓
403 Forbidden

Valid token with required role
        ↓
Request continues
```

## Account Ownership Authorization

A `wallet_user` must not be able to access another user's account by changing the account ID in the URL.

For account balance and transaction-history requests, the API:

1. Reads the account ID from the request.
2. Finds the account owner in PostgreSQL.
3. Retrieves the owner's `keycloak_user_id`.
4. Compares it with the authenticated token's `sub` claim.
5. Allows access only if they match.

Administrators and auditors may inspect any account.

```text
wallet_admin
    → any account

wallet_auditor
    → any account

wallet_user
    → owned accounts only
```

## Local User Provisioning

Keycloak owns authentication information such as:

- username
- password
- roles
- login sessions
- authentication state

The wallet database owns application data such as:

- local wallet user
- accounts
- transactions
- ledger entries

An authenticated `wallet_user` can call:

```http
POST /users/me
```

On the first request:

```text
No linked local user exists
        ↓
Create PostgreSQL user
        ↓
Store token.sub as keycloak_user_id
        ↓
201 Created
```

On later requests:

```text
Linked local user already exists
        ↓
Return existing user
        ↓
200 OK
```

## Ledger Design

Account balances are not stored directly in the `accounts` table.

They are calculated from immutable ledger entries:

```sql
SELECT COALESCE(SUM(amount), 0) AS balance
FROM ledger_entries
WHERE account_id = $1;
```

Positive ledger entries increase an account balance.

Negative ledger entries decrease an account balance.

A deposit creates one positive entry:

```text
+100.00
```

A withdrawal creates one negative entry:

```text
-50.00
```

A transfer creates two entries:

```text
-25.00 from the sender
+25.00 to the receiver
```

The two transfer entries sum to zero.

## Transaction Safety

Deposits, withdrawals, and transfers run inside PostgreSQL transactions.

General flow:

```text
BEGIN
lock the relevant account rows
validate account state
check balance when required
insert transaction
insert ledger entry or entries
COMMIT
```

If an operation fails:

```text
ROLLBACK
```

Withdrawals and transfers use:

```sql
SELECT ... FOR UPDATE
```

This provides row-level locking and reduces the risk of concurrent operations spending the same funds.

## Duplicate Request Prevention

Each financial transaction has a unique `reference_id`.

Example:

```json
{
  "reference_id": "api-transfer-001"
}
```

If the same reference ID is submitted again, PostgreSQL rejects it through a unique constraint.

This provides basic idempotency protection against accidentally processing the same transaction twice.

## SQL Security

Database queries use parameterized values through the `pg` library.

Example:

```js
await pool.query(
    'SELECT * FROM accounts WHERE id = $1',
    [account_id]
);
```

User-provided values are not directly concatenated into SQL strings.

## Project Structure

```text
wallet_system/
├── compose.yaml
├── docs/
│   ├── api_examples.md
│   ├── keycloak_setup.md
│   ├── backup_restore.md
│   ├── index_analysis.md
│   ├── invariants.md
│   └── wallet_system_erd.png
├── sql/
│   ├── 01_schema.sql
│   ├── 02_indexes.sql
│   ├── 03_seed.sql
│   ├── 04_queries.sql
│   ├── 05_transaction_tests.sql
│   ├── 06_concurrency_test.sql
│   ├── 07_large_seed.sql
│   └── 08_add_keycloak_user_id.sql
├── src/
│   ├── config/
│   │   └── index.js
│   ├── db/
│   │   └── index.js
│   ├── middlewares/
│   │   ├── authenticate.js
│   │   ├── authorize.js
│   │   ├── accountAuthorization.js
│   │   └── errorHandler.js
│   ├── routes/
│   │   ├── accounts.js
│   │   ├── transactions.js
│   │   └── users.js
│   ├── services/
│   │   ├── accountService.js
│   │   ├── transactionService.js
│   │   └── userService.js
│   ├── utils/
│   │   └── validators.js
│   ├── app.js
│   └── server.js
├── .env.example
├── .gitignore
├── package.json
├── package-lock.json
└── README.md
```

## Local Setup

### 1. Install Dependencies

```bash
npm install
```

### 2. Create the Environment File

```bash
cp .env.example .env
```

Example variables:

```env
PORT=3000

DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=replace_with_local_postgres_password
DB_NAME=wallet_system

KEYCLOAK_ISSUER=http://localhost:8080/realms/wallet
KEYCLOAK_CLIENT_ID=wallet-api
KEYCLOAK_CLIENT_SECRET=replace_with_keycloak_client_secret
```

The Keycloak client secret is used by the local token-request examples.

The Express API itself verifies access tokens using Keycloak public signing keys.

Do not commit the real `.env` file.

### 3. Create the PostgreSQL Database

```bash
createdb -h localhost -U postgres wallet_system
```

### 4. Apply the Database Schema

```bash
psql -h localhost -U postgres \
  -d wallet_system \
  -f sql/01_schema.sql
```

```bash
psql -h localhost -U postgres \
  -d wallet_system \
  -f sql/02_indexes.sql
```

```bash
psql -h localhost -U postgres \
  -d wallet_system \
  -f sql/03_seed.sql
```

Apply the Keycloak identity migration:

```bash
psql -h localhost -U postgres \
  -d wallet_system \
  -f sql/08_add_keycloak_user_id.sql
```

If the original schema is already installed, run only migrations that have not yet been applied.

### 5. Start Keycloak

```bash
docker compose up -d
```

Check the container:

```bash
docker compose ps
```

Follow the logs:

```bash
docker compose logs -f keycloak
```

Open:

```text
http://localhost:8080
```

Configure the realm, client, roles, users, and audience mapper using:

```text
docs/keycloak_setup.md
```

### 6. Start the API

```bash
npm start
```

Development mode:

```bash
npm run dev
```

Check JavaScript syntax:

```bash
npm run check
```

A successful syntax check exits without printing JavaScript errors.

## Keycloak Configuration Summary

Create the following Keycloak resources:

```text
Realm:
wallet

OIDC client:
wallet-api

Realm roles:
wallet_admin
wallet_auditor
wallet_user
```

The `wallet-api` client should have an audience mapper that adds:

```text
wallet-api
```

to the access token's `aud` claim.

The complete setup is documented in:

```text
docs/keycloak_setup.md
```

## Requesting a Local Test Token

Load the `.env` variables into the current shell:

```bash
set -a
source .env
set +a
```

Request an access token:

```bash
ACCESS_TOKEN=$(
  curl -s \
    -X POST \
    "http://localhost:8080/realms/wallet/protocol/openid-connect/token" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "client_id=$KEYCLOAK_CLIENT_ID" \
    -d "client_secret=$KEYCLOAK_CLIENT_SECRET" \
    -d "grant_type=password" \
    -d "username=normal.user" \
    -d "password=replace_with_test_password" |
  jq -r '.access_token'
)
```

Check that the token was saved:

```bash
printf 'Token length: %s\n' "${#ACCESS_TOKEN}"
```

A JWT normally begins with:

```text
eyJ
```

and contains three dot-separated sections.

## Main API Endpoints

### Public Health Checks

```http
GET /health
GET /db-health
```

### Identity

```http
GET /auth/me
```

### Users

```http
POST /users/me
GET  /users
POST /users
```

### Accounts

```http
GET  /accounts
POST /accounts
GET  /accounts/:id/balance
GET  /accounts/:id/transactions
```

### Transactions

```http
GET  /transactions
POST /transactions/deposit
POST /transactions/withdraw
POST /transactions/transfer
```

At the current project stage, Keycloak authentication and authorization have been applied to identity, user-management, account-listing, account-creation, and account-access routes.

The transaction routes retain the original wallet implementation and are planned for later authorization hardening.

Protected requests use:

```http
Authorization: Bearer <access-token>
```

Additional curl examples are available in:

```text
docs/api_examples.md
```

## Example Authentication Tests

### Missing Token

```bash
curl -i http://localhost:3000/auth/me
```

Expected:

```text
401 Unauthorized
```

### Invalid Token

```bash
curl -i \
  -H "Authorization: Bearer not-a-jwt" \
  http://localhost:3000/auth/me
```

Expected:

```text
401 Unauthorized
```

### Valid Token

```bash
curl -i \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  http://localhost:3000/auth/me
```

Expected:

```text
200 OK
```

## Example Ownership Tests

### User Accessing Their Own Account

```bash
curl -i \
  -H "Authorization: Bearer $USER_ACCESS_TOKEN" \
  http://localhost:3000/accounts/105/balance
```

Expected:

```text
200 OK
```

### User Accessing Another Person's Account

```bash
curl -i \
  -H "Authorization: Bearer $USER_ACCESS_TOKEN" \
  http://localhost:3000/accounts/OTHER_ACCOUNT_ID/balance
```

Expected:

```text
403 Forbidden
```

### Missing Account

```bash
curl -i \
  -H "Authorization: Bearer $USER_ACCESS_TOKEN" \
  http://localhost:3000/accounts/999999/balance
```

Expected:

```text
404 Not Found
```

Replace example account IDs with IDs from your own local database.

## Supporting Database Work

The repository also contains database-focused work from the original project:

- normalized relational schema
- constraints and indexes
- small and larger seed datasets
- account balance queries
- transaction-history queries
- transaction and rollback demonstrations
- concurrency tests
- index analysis
- backup and restore documentation
- ER diagram
- ledger invariants

## Security Scope

This is a local learning project, not a production banking system.

Implemented security-related features include:

- external authentication through Keycloak
- signed JWT access-token validation
- issuer validation
- audience validation
- expiration validation
- realm-role authorization
- object-level account ownership checks
- parameterized SQL queries
- PostgreSQL transactions
- `.env` excluded from Git
- development services bound to localhost where configured

A production deployment would additionally require:

- TLS
- secure secret management
- hardened Keycloak configuration
- non-default administrator credentials
- Authorization Code Flow for browser clients
- rate limiting
- structured audit logging
- monitoring and alerting
- automated security and integration tests
- token and session revocation procedures
- reviewed provisioning and account-recovery workflows
- protection of every financial transaction route
- production PostgreSQL and Keycloak deployment configuration

## Author

Bekzhan Kasymbekov
