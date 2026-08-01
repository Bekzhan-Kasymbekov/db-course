const config  = require('../config');

let jose_promise;
let jwks;

async function load_jose() {
    if (!jose_promise) {
        jose_promise = import('jose');
    }
    
    return jose_promise;
}

async function get_jwks() {
    if(!jwks) {
        const { createRemoteJWKSet } = await load_jose();

        const jwks_url = new URL(
            `${config.keycloak.issuer}/protocol/openid-connect/certs`
        );

        jwks = createRemoteJWKSet(jwks_url);
    }

    return jwks;
}

async function authenticate(req, res, next) {
    try {
        const authorization_header = req.get('authorization');

        if (!authorization_header) {
            return res.status(401).json({
                error: {
                    message: 'Authorization header is required',
                },
            });
        }

        const [scheme, token] = authorization_header.split(' ');

        if (scheme !== 'Bearer' || !token) {
            return res.status(401).json({
                error: {
                    message:
                        'Authorization header must use the Bearer scheme',
                }
            });
        }

        const { jwtVerify } = await load_jose();
        const remote_jwks = await get_jwks();

        const { payload, protectedHeader } = await jwtVerify(
            token,
            remote_jwks,
            {
                issuer: config.keycloak.issuer,

                /*
                 * will add audience validation later after checking
                 * the Keycloak token
                 */
            }
        );

        req.auth = {
            token: payload,
            header: protectedHeader,
            subject: payload.sub,
            username: payload.preferred_username,
        };

        next();
    } catch (error) {
        console.error('Access token validation failed:', error.message);

        return res.status(401).json({
            error: {
                message: 'Access token is invalid or expired',
            },
        });
    }
}

module.exports = authenticate;
