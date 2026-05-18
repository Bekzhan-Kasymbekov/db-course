const app = require('./app');
const config = require('./config');

app.listen(config.port, () => {
    console.log(`Wallet system server running on port ${config.port}`);

});
