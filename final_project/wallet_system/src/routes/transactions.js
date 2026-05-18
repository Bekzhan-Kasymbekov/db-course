const express = require('express');

const transaction_service = require('../services/transactionService');
const {
    is_positive_integer,
    is_positive_amount,
} = require('../utils/validators');

const router = express.Router();

function validate_transaction_input(account_id, amount, reference_id) { 
    if (!is_positive_integer(account_id)) {
        const error = new Error('Valid account_id is required');
        error.status_code = 400;
        throw error;
    }

    if (!is_positive_amount(amount)) {
        const error = new Error('Amount must be greater than 0');
        error.status_code = 400;
        throw error;
    }

    if (typeof reference_id !== 'string' || reference_id.trim() === '') {
        const error = new Error('reference_id is required');
        error.status_code = 400;
        throw error;
    }
}

function validate_transfer_input(sender_account_id, receiver_account_id, amount, reference_id) {
    if (!is_positive_integer(sender_account_id)) {
        const error = new Error('Valid sender_account_id is required');
        error.status_code = 400;
        throw error;
    }

    if (!is_positive_integer(receiver_account_id)) {
        const error = new Error('Valid receiver_account_id is required');
        error.status_code = 400;
        throw error;
    }

    if (!is_positive_amount(amount)) {
        const error = new Error('Amount must be greater than 0');
        error.status_code = 400;
        throw error;
    }

    if (typeof reference_id !== 'string' || reference_id.trim() === '') {
        const error = new Error('reference_id is required');
        error.status_code = 400;
        throw error;
    }
}

router.post('/deposit', async (req, res, next) => {
    try {
        const { account_id, amount, reference_id } = req.body;

        validate_transaction_input(account_id, amount, reference_id);

        const transaction = await transaction_service.deposit(
            Number(account_id),
            Number(amount),
            reference_id.trim()
        );

        res.status(201).json({
            transaction,
        });
    } catch (error) {
        next(error);   
    }
});

router.post('/withdraw', async (req, res, next) => {
    try {
        const { account_id, amount, reference_id } = req.body;
    
        validate_transaction_input(account_id, amount, reference_id);

        const transaction = await transaction_service.withdraw(
            Number(account_id),
            Number(amount),
            reference_id.trim()
        );

        res.status(201).json({
            transaction,
        });
    } catch (error) {
        next(error);   
    }
});

router.post('/transfer', async (req, res, next) => {
    try {
        const { sender_account_id, receiver_account_id, amount, reference_id } = req.body;

        validate_transfer_input(sender_account_id, receiver_account_id, amount, reference_id);
        
        const transaction = await transaction_service.transfer(
            Number(sender_account_id),
            Number(receiver_account_id),
            Number(amount),
            reference_id.trim()
        );

        res.status(201).json({
            transaction,
        });
    } catch (error) {
        next(error);
    }
});

router.get('/', async (req, res, next) => {
    try {
        const transactions = await transaction_service.get_transactions();

        res.json({
            transactions,
        });
    } catch (error) {
        next(error)
    }
});

module.exports = router;
