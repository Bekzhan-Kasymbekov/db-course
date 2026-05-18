const express = require('express');

const pool = require('./db');
const users_router = require('./routes/users');
const accounts_router = require('./routes/accounts');
const transactions_router = require('./routes/transactions');
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

app.use('/users', users_router);
app.use('/accounts', accounts_router);
app.use('/transactions', transactions_router);

app.use(error_handler);

module.exports = app;

