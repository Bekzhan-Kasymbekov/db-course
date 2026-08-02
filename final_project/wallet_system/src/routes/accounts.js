const express = require('express');

const account_service = require('../services/accountService');
const {
    is_positive_integer,
    is_valid_currency_code,
} = require('../utils/validators');
const authenticate = require('../middlewares/authenticate');

const {
    require_realm_role,
} = require('../middlewares/authorize');

const {
    require_account_access,
} = require('../middlewares/accountAuthorization');

const router = express.Router();

router.post('/',
    authenticate,
    require_realm_role('wallet_admin'),
    async (req, res, next) => {
    try {
        const { user_id, currency_code = 'USD' } = req.body;

        if (!is_positive_integer(user_id)) {
            const error = new Error('Valid user_id is required');
            error.status_code = 400;
            throw error;
        }

        if (!is_valid_currency_code(currency_code)) {
            const error = new Error(
                'currency_code must be a 3-letter uppercase code, for example USD'
            );
            error.status_code = 400;
            throw error;
        }

        const account =
            await account_service.create_account(
            Number(user_id),
            currency_code
        );
        
        res.status(201).json({
            account,
        });
    } catch (error) {
        if (error.code === '23503') {
            error.status_code = 404;
            error.message = 'User does not exist';
        }

        next(error);
    }
});

router.get(
    '/:id/balance',
    authenticate,
    require_account_access,
    async (req, res, next) => {
    try {
        const { id } = req.params;

        if (!is_positive_integer(id)) {
            const error = new Error('Valid account id is required');
            error.status_code = 400;
            throw error;
        }

        const balance = await account_service.get_account_balance(Number(id));

        res.json({
            account: balance,
        });
    } catch (error) {
        next(error);
    }
});

router.get(
    '/:id/transactions',
    authenticate,
    require_account_access,
    async (req, res, next) => {
    try {
        const { id } = req.params;

        if (!is_positive_integer(id)) {
            const error = new Error('Valid account id is required');
            error.status_code = 400;
            throw error;
        }

        const transactions = await account_service.get_account_transactions(Number(id));

        res.json({
            account_id: Number(id),
            transactions,
        });
    } catch (error) {
        next(error);
    }
});

router.get('/',
    authenticate,
    require_realm_role('wallet_admin', 'wallet_auditor'),
    async (req, res, next) => {
    try {
        const accounts =
            await account_service.get_accounts();

        res.json({
            accounts,
        });
    } catch (error) {
        next(error);
    }
});

module.exports = router;
