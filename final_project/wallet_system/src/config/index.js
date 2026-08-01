require('dotenv').config();

const config = {
    port: process.env.PORT || 3000,

    db: {
        host: process.env.DB_HOST || 'localhost',
        port: Number(process.env.DB_PORT) || 5432,
        user: process.env.DB_USER || 'postgres',
        password: process.env.DB_PASSWORD,
        database: process.env.DB_NAME || 'wallet_system',
    },

    keycloak: {
        issuer:
            process.env.KEYCLOAK_ISSUER ||
            'http://localhost:8080/realms/wallet',

        client_id:
            process.env.KEYCLOAK_CLIENT_ID ||
            'wallet-api',
    },
};

module.exports = config;
