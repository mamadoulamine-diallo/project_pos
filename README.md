# Project POS - Database (MVP)

## Description

Base de données d’une application de caisse et gestion de stock destinée aux petits commerces.

## Contenu

- `sql/schema.sql` : structure de la base
- `sql/data.sql` : données fictives

## Installation

```sql
CREATE DATABASE project_pos;
USE project_pos;
```

Puis :

```bash
mysql -u root -p project_pos < sql/schema.sql
mysql -u root -p project_pos < sql/data.sql
```

## Modélisation

- Historisation des prix (`product_price`)
- Prix figé dans `sale_item`
- Gestion des statuts de vente

## Objectif

Projet pédagogique pour apprendre :

- la modélisation de données
- SQL (requêtes, jointures, agrégations)
