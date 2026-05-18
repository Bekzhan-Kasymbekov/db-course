function error_handler(error, req, res, next) {
    console.error(error);

    const status_code = error.status_code || 500;

    res.status(status_code).json({
        error: {
            message: error.message || 'Internal server error',
        },
    });
}

module.exports = error_handler;
