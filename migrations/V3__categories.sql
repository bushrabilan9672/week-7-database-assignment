CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name TEXT,
    parent_id INT REFERENCES categories(id)
);
