const express = require('express');

const config = require('./config');
const pool = require('./db');
const users_router = require('./routes/users');
const accounts_router = require('./routes/accounts');
const transactions_router = require('./routes/transactions');
const authenticate = require('./middlewares/authenticate');
const { require_realm_role } = require('./middlewares/authorize');
const error_handler = require('./middlewares/errorHandler');

const app = express();

app.use(express.json());

app.get('/health', (req, res) => {
    res.json({
        status: 'ok',
        service: 'wallet-system',
    });
});


app.get('/db-health', async (req, res, next) => {
    try {
        const result = await pool.query('SELECT NOW() AS current_time');

        res.json({
            status: 'ok',
            database_time: result.rows[0].current_time,
        });
    } catch (error) {
        next(error);
    }
});

app.get('/auth/me', authenticate, (req, res) => {
    const token = req.auth.token;

    const realmRoles = token.realm_access?.roles || [];

    const clientRoles =
        token.resource_access?.[config.keycloak.client_id]?.roles || [];

    res.json({
        authenticated: true,

        user: {
            subject: req.auth.subject,
            username: req.auth.username,
            email: token.email,
            realm_roles: realmRoles,
            client_roles: clientRoles,
        },

        token: {
            issuer: token.iss,
            audience: token.aud,
            issued_at: token.iat,
            expires_at: token.exp,
            algorithm: req.auth.header.alg,
            key_id: req.auth.header.kid,
        },
    });
});

app.get(
    '/auth/admin-test',
    authenticate,
    require_realm_role('wallet_admin'),
    (req, res) => {
        res.json({
            message: 'You have wallet_admin access',
            username: req.auth.username,
        });
    }
);

app.use('/users', users_router);
app.use('/accounts', accounts_router);
app.use('/transactions', transactions_router);

app.use(error_handler);

module.exports = app;

