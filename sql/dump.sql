-- =========================
-- RESET DATABASE
-- =========================
DROP DATABASE IF EXISTS project_pos;

CREATE DATABASE project_pos
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE project_pos;

-- =========================
-- TABLE: user
-- =========================
CREATE TABLE user (
    id_user     INT AUTO_INCREMENT PRIMARY KEY,
    role        ENUM('VENDEUR', 'GERANT') NOT NULL,
    pin_code    VARCHAR(10) NOT NULL,
    email       VARCHAR(255) UNIQUE,
    active      BOOLEAN NOT NULL DEFAULT TRUE
) ENGINE=InnoDB;

-- =========================
-- TABLE: category
-- =========================
CREATE TABLE category (
    id_category INT AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(100) NOT NULL UNIQUE,
    active      BOOLEAN NOT NULL DEFAULT TRUE
) ENGINE=InnoDB;

-- =========================
-- TABLE: product
-- =========================
CREATE TABLE product (
    id_product   INT AUTO_INCREMENT PRIMARY KEY,
    name         VARCHAR(150) NOT NULL,
    image_url    TEXT,
    active       BOOLEAN NOT NULL DEFAULT TRUE,
    id_category  INT NOT NULL,

    CONSTRAINT fk_product_category
        FOREIGN KEY (id_category)
        REFERENCES category(id_category)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT
) ENGINE=InnoDB;

-- =========================
-- TABLE: product_price
-- =========================
CREATE TABLE product_price (
    id_price     INT AUTO_INCREMENT PRIMARY KEY,
    id_product   INT NOT NULL,
    price        DECIMAL(10,2) NOT NULL,
    date_debut   DATETIME NOT NULL,
    date_fin     DATETIME NULL,

    is_active    BOOLEAN AS (date_fin IS NULL) STORED,

    CONSTRAINT fk_price_product
        FOREIGN KEY (id_product)
        REFERENCES product(id_product)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,

    CONSTRAINT chk_price_dates
        CHECK (date_fin IS NULL OR date_fin > date_debut)
) ENGINE=InnoDB;

CREATE UNIQUE INDEX ux_product_active_price
ON product_price (id_product, is_active);

-- =========================
-- TABLE: sale
-- =========================
CREATE TABLE sale (
    id_sale     INT AUTO_INCREMENT PRIMARY KEY,
    sale_date   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status      ENUM('BROUILLON', 'VALIDEE', 'ANNULEE') 
                NOT NULL DEFAULT 'BROUILLON',
    id_user     INT NOT NULL,

    CONSTRAINT fk_sale_user
        FOREIGN KEY (id_user)
        REFERENCES user(id_user)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT
) ENGINE=InnoDB;

-- =========================
-- TABLE: sale_item
-- =========================
CREATE TABLE sale_item (
    id_sale_item  INT AUTO_INCREMENT PRIMARY KEY,
    id_sale       INT NOT NULL,
    id_product    INT NOT NULL,
    quantity      INT NOT NULL CHECK (quantity > 0),
    unit_price    DECIMAL(10,2) NOT NULL CHECK (unit_price >= 0),

    CONSTRAINT fk_sale_item_sale
        FOREIGN KEY (id_sale)
        REFERENCES sale(id_sale)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,

    CONSTRAINT fk_sale_item_product
        FOREIGN KEY (id_product)
        REFERENCES product(id_product)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT
) ENGINE=InnoDB;

-- =========================
-- DATA
-- =========================

-- USERS
INSERT INTO user (role, pin_code, email, active) VALUES
('GERANT', '1234', 'gerant@shop.sn', TRUE),
('VENDEUR', '1111', 'vendeur1@shop.sn', TRUE),
('VENDEUR', '2222', 'vendeur2@shop.sn', TRUE);

-- CATEGORIES
INSERT INTO category (name, active) VALUES
('Boissons', TRUE),
('Alimentation', TRUE),
('Produits ménagers', TRUE);

-- PRODUCTS
INSERT INTO product (name, image_url, active, id_category) VALUES
('Eau minérale 1L', NULL, TRUE, 1),
('Jus mangue', NULL, TRUE, 1),
('Riz local 5kg', NULL, TRUE, 2),
('Savon', NULL, TRUE, 3);

-- PRODUCT PRICES
INSERT INTO product_price (id_product, price, date_debut, date_fin) VALUES
(1, 300, '2024-01-01 00:00:00', '2024-03-31 23:59:59'),
(1, 350, '2024-04-01 00:00:00', NULL),
(2, 500, '2024-01-01 00:00:00', NULL),
(3, 2500, '2024-01-01 00:00:00', '2024-02-28 23:59:59'),
(3, 2700, '2024-03-01 00:00:00', NULL),
(4, 400, '2024-01-01 00:00:00', NULL);

-- SALES
INSERT INTO sale (sale_date, status, id_user) VALUES
('2024-04-05 10:15:00', 'VALIDEE', 2),
('2024-04-06 11:00:00', 'BROUILLON', 3);

-- SALE ITEMS
INSERT INTO sale_item (id_sale, id_product, quantity, unit_price) VALUES
(1, 1, 2, 350),
(1, 3, 1, 2700),
(2, 2, 1, 0),
(2, 4, 3, 0);