/* This code creates the table for students with the columns for id, 
name, age, major and email */
CREATE TABLE IF NOT EXISTS students (
	id SERIAL PRIMARY KEY,
	name TEXT NOT NULL,
	age INT,
	major TEXT, 
	email TEXT UNIQUE
);
