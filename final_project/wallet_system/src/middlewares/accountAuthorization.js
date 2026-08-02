const account_service = require('../services/accountService');

function has_realm_role(req, role) {
    const roles = req.auth?.token?.realm_access?.roles || [];

    return roles.includes(role);
}

async function require_account_access(req, res, next) {
    try {
        const account_id = Number(
            req.params.id ??
            req.body.account_id ??
            req.body.sender_account_id
        );

        if (!Number.isInteger(account_id) || account_id <= 0) {
            const error = new Error('Valid account id is required');
            error.status_code = 400;
            throw error;
        }

        const account_owner =
            await account_service.get_account_owner(account_id);

        if (!account_owner) {
            const error = new Error('Account does not exist');
            error.status_code = 404;
            throw error;
        }

        const is_privileged =
            has_realm_role(req, 'wallet_admin') ||
            has_realm_role(req, 'wallet_auditor');

        const is_owner =
            account_owner.keycloak_user_id === req.auth.subject;

        if (!is_privileged && !is_owner) {
            return res.status(403).json({
                error: {
                    message:
                    'You do not have permission to acces this account',
                },
            });
        }

        req.account = account_owner;

        next();
    } catch (error) {
        next(error);
    }
}

module.exports = {
    require_account_access,
};
