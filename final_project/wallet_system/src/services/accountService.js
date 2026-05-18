const pool = require('../db');

async function create_account(user_id, currency_code = 'USD') {
    const query = `
        INSERT INTO accounts (user_id, currency_code)
        VALUES ($1, $2)
        RETURNING id, user_id, currency_code, is_active, created_at;
    `;

    const result = await pool.query(query, [user_id, currency_code]);

    return result.rows[0];
}

async function get_accounts() {
    const query = `
        SELECT
            a.id,
            a.user_id,
            u.email,
            a.currency_code,
            a.is_active,
            a.created_at
        FROM accounts a
        JOIN users u
            ON u.id = a.user_id
        ORDER by a.id;
    `;

    const result = await pool.query(query);

    return result.rows;
}

async function get_account_balance(account_id) {
    const query = `
        SELECT
            a.id AS account_id,
            a.user_id,
            u.email,
            a.currency_code,
            a.is_active,
            COALESCE(SUM(le.amount), 0) AS balance
        FROM accounts a
        JOIN users u
            ON u.id = a.user_id
        LEFT JOIN ledger_entries le
            ON le.account_id = a.id
        WHERE a.id = $1
        GROUP BY
            a.id,
            a.user_id,
            u.email,
            a.currency_code,
            a.is_active;
    `;

    const result = await pool.query(query, [account_id]);

    return result.rows[0] || null;
}

async function get_account_transactions(account_id) {
    const query = `
        SELECT
            t.id AS transaction_id,
            t.transaction_type,
            t.status,
            t.reference_id,
            le.id AS ledger_entry_id,
            le.account_id,
            le.amount,
            le.created_at
        FROM ledger_entries le
        JOIN transactions t
            ON t.id = le.transaction_id
        WHERE le.account_id = $1
        ORDER BY le.created_at DESC, le.id DESC;
    `;

    const result = await pool.query(query, [account_id]);

    return result.rows;
}

module.exports = {
    create_account,
    get_accounts,
    get_account_balance,
    get_account_transactions,
};
