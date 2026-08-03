# Keycloak Setup

This document describes the local Keycloak configuration used by the Wallet Ledger API.

The setup is intended for development and learning. It is not a hardened production configuration.

## 1. Start Keycloak

From the project root:

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

Sign in to the administration console using the development bootstrap credentials configured in `compose.yaml`.

## 2. Create the Realm

Create a realm named:

```text
wallet
```

Do not create application users or clients in the `master` realm.

## 3. Create Realm Roles

Create the following realm roles:

```text
wallet_admin
wallet_auditor
wallet_user
```

Intended behavior:

| Role | Permissions |
|---|---|
| `wallet_admin` | Create and inspect users and accounts, deposit funds, inspect transactions, and access any account |
| `wallet_auditor` | Read users, accounts, balances, histories, and transactions |
| `wallet_user` | Link their Keycloak identity to a local wallet user and access accounts they own |

## 4. Create the OIDC Client

Create a client with:

```text
Client type: OpenID Connect
Client ID: wallet-api
```

For local command-line testing:

```text
Client authentication: On
Standard flow: Off
Direct access grants: On
Service accounts roles: Off
Authorization: Off
```

Direct Access Grants are used only to simplify local token requests. A browser application should use Authorization Code Flow instead.

Copy the client secret into the local `.env` file:

```env
KEYCLOAK_CLIENT_SECRET=replace_with_keycloak_client_secret
```

Do not commit the real secret.

## 5. Add the Audience Mapper

Open:

```text
Clients
→ wallet-api
→ Client scopes
→ wallet-api-dedicated
→ Add mapper
→ By configuration
→ Audience
```

Use:

```text
Name: wallet-api-audience
Included Client Audience: wallet-api
Included Custom Audience: empty
Add to access token: On
Add to ID token: Off
```

New access tokens should contain an audience similar to:

```json
[
  "wallet-api",
  "account"
]
```

The Express API validates that `wallet-api` is present in the `aud` claim.

## 6. Create Test Users

Create users such as:

```text
admin.user
auditor.user
normal.user
```

Assign:

```text
admin.user   → wallet_admin
auditor.user → wallet_auditor
normal.user  → wallet_user
```

Set permanent passwords by turning Temporary off.

Make sure required profile fields are complete and no unfinished required actions remain before testing Direct Access Grants.

## 7. Request a Token

Load the environment variables:

```bash
set -a
source .env
set +a
```

Request a token:

```bash
ACCESS_TOKEN=$(
  curl -s -X POST \
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

Check that the value looks like a JWT:

```bash
printf 'Length: %s\n' "${#ACCESS_TOKEN}"
awk -F. '{ print "JWT sections:", NF }' <<< "$ACCESS_TOKEN"
```

A JWT should normally have three dot-separated sections.

## 8. Test the API

Without a token:

```bash
curl -i http://localhost:3000/auth/me
```

Expected:

```text
401 Unauthorized
```

With a valid token:

```bash
curl -i \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  http://localhost:3000/auth/me
```

Expected:

```text
200 OK
```

## 9. Token Validation

The API validates:

- JWT signature using Keycloak JWKS
- issuer
- audience
- expiration
- realm roles

Keycloak public keys are retrieved from:

```text
http://localhost:8080/realms/wallet/protocol/openid-connect/certs
```

## 10. Identity Linking

The OIDC `sub` claim is stored in:

```text
users.keycloak_user_id
```

The ownership relationship is:

```text
JWT sub
    ↓
users.keycloak_user_id
    ↓
accounts.user_id
```

This allows a `wallet_user` to access only accounts belonging to their linked local wallet user.
