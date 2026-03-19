-- =========================
-- RESET DATABASE
-- =========================

DROP DATABASE IF EXISTS project_pos;

CREATE DATABASE project_pos
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE project_pos;

-- =========================
-- LOAD STRUCTURE
-- =========================
SOURCE sql/schema.sql;

-- =========================
-- LOAD DATA
-- =========================
SOURCE sql/data.sql; 