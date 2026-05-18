function is_valid_email(email) {
    if(typeof email !== 'string') {
        return false;
    }

    return /^[^\s@]+@[^\s@]+\.[^/s@]+$/.test(email);
}

function is_positive_integer(value) {
    const number_value = Number(value);

    return Number.isInteger(number_value) && number_value > 0;
}

function is_valid_currency_code(currency_code) {
    if (currency_code === undefined || currency_code === null) {
        return true;
    }   
    
    if (typeof currency_code !== 'string') {
        return false;
    }

    return /^[A-Z]{3}$/.test(currency_code);
}

function is_positive_amount(value) {
    const number_value = Number(value);

    return Number.isFinite(number_value) && number_value > 0;
}

module.exports = {
    is_valid_email,
    is_positive_integer,
    is_valid_currency_code,
    is_positive_amount,
};
