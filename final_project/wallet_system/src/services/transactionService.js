const pool = require('../db');

async function deposit(account_id, amount, reference_id) {
    const client = await pool.connect();

    try {
        await client.query('BEGIN');

        const account_result = await client.query(
            `
                SELECT id
                FROM accounts
                WHERE id = $1 AND is_active = TRUE
                FOR UPDATE;
            `,
            [account_id]
        );

        if (account_result.rowCount === 0) {
            const error = new Error('Account does not exist or is inactive');
            error.status_code = 404;
            throw error;
        }

        const transaction_result = await client.query(
            `
                INSERT INTO transactions (transaction_type, status, reference_id)
                VALUES ('deposit', 'pending', $1)
                RETURNING id, transaction_type, status, reference_id, created_at;
            `,
            [reference_id]
        );

        const transaction = transaction_result.rows[0];

        await client.query(
            `
                INSERT INTO ledger_entries (transaction_id, account_id, amount)
                VALUES ($1, $2, $3);
            `,
            [transaction.id, account_id, amount]
        );

        const completed_transaction_result = await client.query(
            `
                UPDATE transactions
                SET status = 'completed'
                WHERE id = $1
                RETURNING id, transaction_type, status, reference_id, created_at;
            `,
            [transaction.id]
        );

        await client.query('COMMIT');

        return completed_transaction_result.rows[0];
    } catch (error) {
        await client.query('ROLLBACK');

        if (error.code === '23505') {
            error.status_code = 400;
            error.message = 'Transaction with this reference_id already exists';
        }

        throw error;
    } finally {
        client.release();
    }
}

async function withdraw(account_id, amount, reference_id) {
    const client = await pool.connect();

    try {
        await client.query('BEGIN');
        
        const account_result = await client.query(
            `
                SELECT id
                FROM accounts
                WHERE id = $1 AND is_active = TRUE
                FOR UPDATE;
            `,
            [account_id]
        );

        if (account_result.rowCount === 0) {
            const error = new Error('Account does not exist or is inactive');
            error.status_code = 404;
            throw error;
        }

        const balance_result = await client.query(
            `
                SELECT COALESCE(SUM(amount), 0) AS balance
                FROM ledger_entries
                WHERE account_id = $1;
            `,
            [account_id]
        );

        const current_balance = Number(balance_result.rows[0].balance);

        if (current_balance < amount) {
            const error = new Error('Insufficient funds');
            error.status_code = 409;
            throw error;
        }

        const transaction_result = await client.query(
            `
                INSERT INTO transactions (transaction_type, status, reference_id)
                VALUES ('withdrawal', 'pending', $1)
                RETURNING id, transaction_type, status, reference_id, created_at;
            `,
            [reference_id]
        );

        const new_transaction = transaction_result.rows[0];

        await client.query(
            `
                INSERT INTO ledger_entries (transaction_id, account_id, amount)
                VALUES ($1, $2, $3);
            `,
            [new_transaction.id, account_id, -amount]
        );

        const completed_transaction_result = await client.query(
            `
                UPDATE transactions
                SET status = 'completed'
                WHERE id = $1
                RETURNING id, transaction_type, status, reference_id, created_at;
            `,
            [new_transaction.id]
        );

        await client.query('COMMIT');

        return completed_transaction_result.rows[0];
    } catch (error) {
        await client.query('ROLLBACK');

        if (error.code === '23505') {
            error.status_code = 409;
            error.message = 'Transaction with this reference_id already exists';
        }

        throw error;
    } finally {
        client.release();
    }
}

async function transfer(sender_account_id, receiver_account_id, amount, reference_id) {
    const client = await pool.connect();

    try {
        await client.query('BEGIN');

        if (sender_account_id === receiver_account_id) {
            const error = new Error('Cannot transfer to the same account');
            error.status_code = 400;
            throw error;
        }

        const accounts_result = await client.query(
            `
                SELECT id
                FROM accounts
                WHERE id IN ($1, $2)
                    AND is_active = TRUE
                ORDER BY id
                FOR UPDATE;
            `,
            [sender_account_id, receiver_account_id]
        );

        if (accounts_result.rowCount !== 2) {
            const error = new Error('One or both accounts do not exist or are inactive');
            error.status_code = 404;
            throw error;
        }
 
        const balance_result = await client.query(
            `
                SELECT COALESCE(SUM(amount), 0) AS balance
                FROM ledger_entries
                WHERE account_id = $1;
            `,
            [sender_account_id]
        );

        const current_balance = Number(balance_result.rows[0].balance);

        if (current_balance < amount) {
            const error = new Error('Insufficient funds');
            error.status_code = 409;
            throw error;
        }

        const transaction_result = await client.query(
            `
                INSERT INTO transactions (transaction_type, status, reference_id)
                VALUES ('transfer', 'pending', $1)
                RETURNING id, transaction_type, status, reference_id, created_at;
            `,
            [reference_id]
        );

        const transaction = transaction_result.rows[0];

        await client.query(
            `
                INSERT INTO ledger_entries (transaction_id, account_id, amount)
                VALUES ($1, $2, $3);
            `,
            [transaction.id, sender_account_id, -amount]
        );

        await client.query(
            `
                INSERT INTO ledger_entries (transaction_id, account_id, amount)
                VALUES ($1, $2, $3);
            `,
            [transaction.id, receiver_account_id, amount]
        );

        const completed_transaction_result = await client.query(
            `
                UPDATE transactions
                SET status = 'completed'
                WHERE id = $1
                RETURNING id, transaction_type, status, reference_id, created_at;
            `,
            [transaction.id]
        );

        await client.query('COMMIT');

        return completed_transaction_result.rows[0];
    } catch (error) {
        await client.query('ROLLBACK');
    
        if (error.code === '23505') {
            error.status_code = 409;
            error.message = 'Transaction with this reference_id already exists';
        }
        throw error;
    } finally {
        client.release();
    }
}

async function get_transactions() {
    const query = `
        SELECT
            id,
            transaction_type,
            status,
            reference_id,
            created_at
        FROM transactions
        ORDER BY created_at DESC, id DESC;
    `;

    const result = await pool.query(query);

    return result.rows;
}

module.exports = {
    deposit,
    withdraw,
    transfer,
    get_transactions,
};
