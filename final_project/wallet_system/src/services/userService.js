const pool = require('../db');

async function create_user(email, keycloak_user_id = null) {
    const query = `
        INSERT INTO users (email, keycloak_user_id)
        VALUES ($1, $2)
        RETURNING id, email, keycloak_user_id, created_at;
        `;

    const result = await pool.query(query, [
        email,
        keycloak_user_id,
    ]);

    return result.rows[0];
}

async function get_users() {
    const query =  `
        SELECT id, email, keycloak_user_id, created_at
        FROM users
        ORDER BY id;
    `;

    const result = await pool.query(query);

    return result.rows;
}

async function get_user_by_keycloak_id(keycloak_user_id) {
    const query = `
        SELECT id, email, keycloak_user_id, created_at
        FROM users
        WHERE keycloak_user_id = $1;
    `;

    const result = await pool.query(query, [keycloak_user_id]);

    return result.rows[0] || null;
}

module.exports = {
    create_user,
    get_users,
    get_user_by_keycloak_id,
};
