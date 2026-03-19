# Conception de la Base de Données – Projet POS (MVP)

## 1. Contexte

Ce projet consiste en la conception d’une base de données pour une application de caisse et de gestion de stock destinée aux petits commerces de proximité (Afrique de l’Ouest).

L’objectif principal est de :

- gérer les ventes
- gérer les produits et leurs prix
- garantir la cohérence et l’historique des données

---

## 2. Démarche de conception

La conception a été réalisée en suivant une approche structurée :

1. Analyse du besoin métier
2. Identification des entités et événements
3. Construction du Modèle Conceptuel de Données (MCD)
4. Transformation en Modèle Logique (MLD)
5. Implémentation SQL (MySQL)

---

## 3. Principes de modélisation retenus

### 3.1 Séparation Entités / Événements

- Entités : données stables dans le temps
  (User, Product, Category)

- Événements : données évolutives
  (Product_price, Sale, Sale_item)

---

### 3.2 Historisation des prix

Le prix d’un produit n’est pas stocké dans la table produit.

Il est géré via une table dédiée `product_price` avec :

- date_debut
- date_fin

Règle :

> Un produit ne peut avoir qu’un seul prix actif à un instant donné.

---

### 3.3 Figement du prix en vente

Le prix est copié dans `sale_item.unit_price` lors de la validation.

Objectif :

- garantir l’historique
- éviter les incohérences dues aux changements de prix

---

### 3.4 Gestion des ventes

Une vente possède un statut :

- BROUILLON
- VALIDEE
- ANNULEE

Règle :

> Une vente validée ne peut plus être modifiée.

---

## 4. Modèle de données

### Tables principales

- user
- category
- product
- product_price
- sale
- sale_item

---

### Relations

- Un produit appartient à une catégorie
- Un produit possède plusieurs prix dans le temps
- Une vente est réalisée par un utilisateur
- Une vente contient plusieurs lignes
- Une ligne référence un produit

---

## 5. Contraintes de gestion

- Un seul prix actif par produit
- Un prix ne peut pas avoir une date de fin antérieure à sa date de début
- Une vente validée est immuable
- Les données historiques ne sont jamais supprimées

---

## 6. Implémentation technique

SGBD utilisé : MySQL 8

Choix techniques :

- ENUM pour les statuts
- Clés étrangères pour garantir l’intégrité
- Index unique pour garantir un seul prix actif
- Champ calculé `is_active` pour compenser l’absence d’index partiel

---

## 7. Jeu de données

Un jeu de données fictif a été ajouté afin de :

- tester les requêtes SQL
- simuler un contexte réel (inflation, ventes, brouillons)

---

## 8. Exploitation SQL

La base permet de réaliser :

- des requêtes de lecture simple
- des jointures (produits, ventes, utilisateurs)
- des agrégations (chiffre d’affaires, quantités vendues)

---

## 9. Évolutions possibles

- Gestion des stocks via mouvements
- Gestion des achats fournisseurs
- Ajout d’un module client
- Multi-boutiques

---

## 10. Conclusion

Le modèle proposé est :

- simple
- cohérent
- évolutif

Il constitue une base solide pour :

- un MVP fonctionnel
- un apprentissage approfondi du SQL
- une extension vers un système complet de gestion commerciale
