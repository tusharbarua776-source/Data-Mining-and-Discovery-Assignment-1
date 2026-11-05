-- Food Delivery Management Database
-- Based on the uploaded ER diagram.
-- SQLite compatible. Run this script in DB Browser for SQLite or sqlite3.

PRAGMA foreign_keys = ON;

-- Drop tables in child-to-parent order so the script can be rerun.
DROP TABLE IF EXISTS Order_Items;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Menu_Items;
DROP TABLE IF EXISTS Customers;
DROP TABLE IF EXISTS Restaurants;
DROP TABLE IF EXISTS Address;

CREATE TABLE Address (
    id       TEXT PRIMARY KEY, -- UUID stored as TEXT in SQLite
    country  TEXT NOT NULL,
    city     TEXT NOT NULL,
    street   TEXT NOT NULL,
    postcode TEXT NOT NULL
);

CREATE TABLE Customers (
    id                TEXT PRIMARY KEY,
    first_name        TEXT NOT NULL,
    last_name         TEXT NOT NULL,
    email             TEXT NOT NULL UNIQUE,
    mobile_no         TEXT,
    registration_date TEXT NOT NULL,
    address           TEXT NOT NULL,
    FOREIGN KEY (address) REFERENCES Address(id)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE Restaurants (
    id              TEXT PRIMARY KEY,
    restaurant_name TEXT NOT NULL,
    cuisine_type    TEXT NOT NULL,
    rating          REAL CHECK (rating IS NULL OR rating BETWEEN 0 AND 5),
    address         TEXT NOT NULL,
    opening_year    TEXT,
    FOREIGN KEY (address) REFERENCES Address(id)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE Menu_Items (
    id                 TEXT PRIMARY KEY,
    restaurant_id      TEXT NOT NULL,
    item_name          TEXT NOT NULL,
    category           TEXT NOT NULL,
    dietary_type       TEXT NOT NULL,
    availability       INTEGER NOT NULL DEFAULT 1 CHECK (availability IN (0, 1)),
    preparation_time   TEXT,
    FOREIGN KEY (restaurant_id) REFERENCES Restaurants(id)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE Orders (
    id                    TEXT PRIMARY KEY,
    customer_id           TEXT NOT NULL,
    restaurant_id         TEXT NOT NULL,
    order_date_time       TEXT NOT NULL,
    order_status          TEXT NOT NULL,
    payment_method        TEXT NOT NULL,
    delivery_temperature REAL,
    total_amount          REAL NOT NULL CHECK (total_amount >= 0),
    FOREIGN KEY (customer_id) REFERENCES Customers(id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (restaurant_id) REFERENCES Restaurants(id)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE Order_Items (
    order_id   TEXT NOT NULL,
    item_id    TEXT NOT NULL,
    quantity   INTEGER NOT NULL CHECK (quantity > 0),
    unit_price REAL NOT NULL CHECK (unit_price >= 0),
    PRIMARY KEY (order_id, item_id),
    FOREIGN KEY (order_id) REFERENCES Orders(id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (item_id) REFERENCES Menu_Items(id)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

-- Helpful indexes for common joins and lookups.
CREATE INDEX idx_customers_address ON Customers(address);
CREATE INDEX idx_restaurants_address ON Restaurants(address);
CREATE INDEX idx_menu_items_restaurant ON Menu_Items(restaurant_id);
CREATE INDEX idx_orders_customer ON Orders(customer_id);
CREATE INDEX idx_orders_restaurant ON Orders(restaurant_id);
CREATE INDEX idx_orders_datetime ON Orders(order_date_time);
CREATE INDEX idx_order_items_item ON Order_Items(item_id);

-- Optional quick checks after creating the schema:
-- PRAGMA foreign_key_check;
-- SELECT name FROM sqlite_master WHERE type = 'table' ORDER BY name;
