-- =========================
-- USERS
-- =========================
INSERT INTO
    user (role, pin_code, email, active)
VALUES (
        'GERANT',
        '1234',
        'gerant@shop.sn',
        TRUE
    ),
    (
        'VENDEUR',
        '1111',
        'vendeur1@shop.sn',
        TRUE
    ),
    (
        'VENDEUR',
        '2222',
        'vendeur2@shop.sn',
        TRUE
    );

-- =========================
-- CATEGORIES
-- =========================
INSERT INTO
    category (name, active)
VALUES ('Boissons', TRUE),
    ('Alimentation', TRUE),
    ('Produits ménagers', TRUE);

-- =========================
-- PRODUCTS
-- =========================
INSERT INTO
    product (
        name,
        image_url,
        active,
        id_category
    )
VALUES (
        'Eau minérale 1L',
        NULL,
        TRUE,
        1
    ),
    ('Jus mangue', NULL, TRUE, 1),
    (
        'Riz local 5kg',
        NULL,
        TRUE,
        2
    ),
    ('Savon', NULL, TRUE, 3);

-- =========================
-- PRODUCT PRICES
-- =========================

-- Eau (inflation)
INSERT INTO
    product_price (
        id_product,
        price,
        date_debut,
        date_fin
    )
VALUES (
        1,
        300,
        '2024-01-01 00:00:00',
        '2024-03-31 23:59:59'
    ),
    (
        1,
        350,
        '2024-04-01 00:00:00',
        NULL
    );

-- Jus
INSERT INTO
    product_price (
        id_product,
        price,
        date_debut,
        date_fin
    )
VALUES (
        2,
        500,
        '2024-01-01 00:00:00',
        NULL
    );

-- Riz
INSERT INTO
    product_price (
        id_product,
        price,
        date_debut,
        date_fin
    )
VALUES (
        3,
        2500,
        '2024-01-01 00:00:00',
        '2024-02-28 23:59:59'
    ),
    (
        3,
        2700,
        '2024-03-01 00:00:00',
        NULL
    );

-- Savon
INSERT INTO
    product_price (
        id_product,
        price,
        date_debut,
        date_fin
    )
VALUES (
        4,
        400,
        '2024-01-01 00:00:00',
        NULL
    );

-- =========================
-- SALES
-- =========================
INSERT INTO
    sale (sale_date, status, id_user)
VALUES (
        '2024-04-05 10:15:00',
        'VALIDEE',
        2
    ),
    (
        '2024-04-06 11:00:00',
        'BROUILLON',
        3
    );

-- =========================
-- SALE ITEMS
-- =========================

-- Vente validée
INSERT INTO
    sale_item (
        id_sale,
        id_product,
        quantity,
        unit_price
    )
VALUES (1, 1, 2, 350),
    (1, 3, 1, 2700);

-- Vente brouillon
INSERT INTO
    sale_item (
        id_sale,
        id_product,
        quantity,
        unit_price
    )
VALUES (2, 2, 1, 0),
    (2, 4, 3, 0);