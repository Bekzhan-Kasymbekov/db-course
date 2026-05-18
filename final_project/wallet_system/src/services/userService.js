const pool = require('../db');

async function create_user(email) {
    const query = `
        INSERT INTO users (email)
        VALUES ($1)
        RETURNING id, email, created_at;
        `;

    const result = await pool.query(query, [email]);

    return result.rows[0];
}

async function get_users() {
    const query =  `
        SELECT id, email, created_at
        FROM users
        ORDER BY id;
    `;

    const result = await pool.query(query);

    return result.rows;
}

module.exports = {
    create_user,
    get_users,
};
