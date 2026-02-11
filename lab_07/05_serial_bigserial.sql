CREATE TABLE products (
	product_id SERIAL PRIMARY KEY,
	product_name VARCHAR(100) NOT NULL,
	price DECIMAL(10,2)
);

CREATE TABLE transactions (
	transaction_id BIGSERIAL PRIMARY KEY,
	amount DECIMAL(15,2),
	transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
