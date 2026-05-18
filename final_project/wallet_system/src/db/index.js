const {Pool} = require('pg');

const config = require('../config');

const pool = new Pool(config.db);

pool.on('error', (error) => {
    console.error('Unexpected database error:', error);
    process.exit(1);

});

module.exports = pool;
