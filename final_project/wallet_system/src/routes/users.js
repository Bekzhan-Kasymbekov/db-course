const express = require('express');

const user_service = require('../services/userService');
const { is_valid_email } = require('../utils/validators');
const authenticate = require('../middlewares/authenticate');
const {
    require_realm_role,
} = require('../middlewares/authorize');

const router = express.Router();

router.post(
    '/', 
    authenticate,
    require_realm_role('wallet_admin'),
    async (req, res, next) => {
        try {
            const { email } = req.body;

            if (!is_valid_email(email)) {
                const error = new Error('Valid email is required');
                error.status_code = 400;
                throw error;
            }

            const user = await user_service.create_user(email);

            res.status(201).json({
                user,
            });
        } catch (error) {
            if (error.code === '23505') {
                error.status_code = 409;
                error.message = 'User with this email already exists';
            }

            next(error);
        }
});

router.get(
    '/',
    authenticate,
    require_realm_role('wallet_admin', 'wallet_auditor'),
    async (req, res, next) => {
        try {
            const users = await user_service.get_users();

            res.json({
                users,
            });
        } catch (error) {
            next(error)
        }
});

router.post(
    '/me',
    authenticate,
    require_realm_role('wallet_user'),
    async (req, res, next) => {
        try {
            const keycloak_user_id = req.auth.subject;
            const email = req.auth.token.email;

            if (!email) {
                const error = new Error(
                    'Authenticated user does not have an email claim'
                );
                error.status_code = 400;
                throw error;
            }

            const existing_user =
                await user_service.get_user_by_keycloak_id(
                    keycloak_user_id
                );
            if (existing_user) {
                return res.json({
                    user: existing_user,
                });
            }

            const user = await user_service.create_user(
                email,
                keycloak_user_id
            );

            res.status(201).json({
                user,
            });
        } catch (error) {
            if (error.code === '23505') {
                error.status_code = 409;
                error.message =
                    'A wallet user with this identity or email already exists';
            }

            next(error);
        }
    }
);
module.exports = router;
