-- =========================
-- DATABASE: project_pos
-- =========================

-- =========================
-- TABLE: user
-- =========================
CREATE TABLE user (
    id_user INT AUTO_INCREMENT PRIMARY KEY,
    role ENUM('VENDEUR', 'GERANT') NOT NULL,
    pin_code VARCHAR(10) NOT NULL,
    email VARCHAR(255) UNIQUE,
    active BOOLEAN NOT NULL DEFAULT TRUE
) ENGINE = InnoDB;

-- =========================
-- TABLE: category
-- =========================
CREATE TABLE category (
    id_category INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    active BOOLEAN NOT NULL DEFAULT TRUE
) ENGINE = InnoDB;

-- =========================
-- TABLE: product
-- =========================
CREATE TABLE product (
    id_product INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    image_url TEXT,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    id_category INT NOT NULL,
    CONSTRAINT fk_product_category FOREIGN KEY (id_category) REFERENCES category (id_category) ON UPDATE RESTRICT ON DELETE RESTRICT
) ENGINE = InnoDB;

-- =========================
-- TABLE: product_price
-- =========================
CREATE TABLE product_price (
    id_price INT AUTO_INCREMENT PRIMARY KEY,
    id_product INT NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    date_debut DATETIME NOT NULL,
    date_fin DATETIME NULL,
    is_active BOOLEAN AS (date_fin IS NULL) STORED,
    CONSTRAINT fk_price_product FOREIGN KEY (id_product) REFERENCES product (id_product) ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT chk_price_dates CHECK (
        date_fin IS NULL
        OR date_fin > date_debut
    )
) ENGINE = InnoDB;

-- Contrainte : un seul prix actif par produit
CREATE UNIQUE INDEX ux_product_active_price ON product_price (id_product, is_active);

-- =========================
-- TABLE: sale
-- =========================
CREATE TABLE sale (
    id_sale INT AUTO_INCREMENT PRIMARY KEY,
    sale_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status ENUM(
        'BROUILLON',
        'VALIDEE',
        'ANNULEE'
    ) NOT NULL DEFAULT 'BROUILLON',
    id_user INT NOT NULL,
    CONSTRAINT fk_sale_user FOREIGN KEY (id_user) REFERENCES user (id_user) ON UPDATE RESTRICT ON DELETE RESTRICT
) ENGINE = InnoDB;

-- =========================
-- TABLE: sale_item
-- =========================
CREATE TABLE sale_item (
    id_sale_item INT AUTO_INCREMENT PRIMARY KEY,
    id_sale INT NOT NULL,
    id_product INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10, 2) NOT NULL CHECK (unit_price >= 0),
    CONSTRAINT fk_sale_item_sale FOREIGN KEY (id_sale) REFERENCES sale (id_sale) ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT fk_sale_item_product FOREIGN KEY (id_product) REFERENCES product (id_product) ON UPDATE RESTRICT ON DELETE RESTRICT
) ENGINE = InnoDB;