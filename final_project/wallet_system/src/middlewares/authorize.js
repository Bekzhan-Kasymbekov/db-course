function require_realm_role(...allowed_roles) {
    return (req, res, next) => {
        const user_roles = req.auth?.token?.realm_access?.roles || [];

        const is_allowed = allowed_roles.some((role) =>
            user_roles.includes(role)
        );

        if (!is_allowed) {
            return res.status(403).json({
                error: {
                    message: 'You do not have permission to access this resource',
                },
            });
        }

        next();
    };
}

module.exports = {
    require_realm_role,
};
