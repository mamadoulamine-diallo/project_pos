## **Introduction**

Pour mon projet de POS (Point of Sale) destiné aux petits commerces africains, j'ai dû concevoir une base de données qui soit à la fois simple pour le MVP mais suffisamment évolutive pour répondre aux besoins futurs. L'idée était de partir des besoins métier pour arriver à une structure technique solide, sans se perdre dans des fonctionnalités trop complexes dès le départ.

---

# **1. La conception : du métier à la technique**

## **1.1 Le Modèle Conceptuel (MCD) - La vision métier**

Avant de parler technique, j'ai commencé par réfléchir aux **données dont mon application a vraiment besoin**. Pour ça, je me suis mis à la place du commerçant :

- De quoi a-t-il besoin pour vendre ? → Des **produits**
- Qui vend ? → Des **utilisateurs** (vendeurs, gérants)
- Comment organiser les produits ? → Des **catégories**
- Que doit-on garder après une vente ? → Les **ventes** et leur **détail**
- Et pour les prix ? → Ils peuvent changer, donc il faut **garder l'historique**

### **Les entités principales qui en ressortent :**

- **User** – les personnes qui utilisent l'application
- **Product** – les articles vendus
- **Category** – pour organiser les produits (Fruits, Épicerie, Boissons...)
- **Sale** – une vente (avec sa date, son total, le vendeur)
- **Sale_item** – chaque produit dans une vente (quantité, prix unitaire)
- **Product_price** – l'historique des prix (parce qu'un prix peut changer)

### **Comment elles se relient entre elles :**

- Un **produit** appartient forcément à une **catégorie** (et une seule)
- Une **vente** est forcément réalisée par un **utilisateur** (on veut savoir qui a vendu quoi)
- Une **vente** peut contenir plusieurs **lignes de vente** (plusieurs produits achetés)
- Un **produit** peut avoir plusieurs **prix** dans le temps (important pour les stats)

### **Ce que j'ai appris en faisant ce MCD :**

Ça m'a obligé à vraiment **comprendre le métier** avant de coder. Par exemple, je n'avais pas pensé au début à l'historique des prix, mais en discutant avec des commerçants, je me suis rendu compte que c'est essentiel pour eux de savoir à quel prix ils vendaient tel produit il y a 3 mois.

![image.png](attachment:456fe250-aa20-47fb-8fdf-e458dc097a08:image.png)

---

## **1.2 Le Modèle Physique (MPD) - La traduction technique**

Une fois le MCD validé, il fallait le **traduire en tables concrètes** pour la base de données. C'est le passage de la théorie à la pratique.

### **Comment j'ai structuré les tables :**

Prenons l'exemple de la table `product` (produits) :

- `id_product` – l'identifiant unique (clé primaire)
- `name` – le nom du produit ("Riz 50kg", "Eau 1.5L"...)
- `id_category` – pour relier à la table des catégories (clé étrangère)

### **Les relations entre tables :**

- `product.id_category` → `category.id_category` (un produit a une catégorie)
- `sale.id_user` → `user.id_user` (une vente a un vendeur)
- `sale_item.id_sale` → `sale.id_sale` (une ligne appartient à une vente)
- `sale_item.id_product` → `product.id_product` (une ligne concerne un produit)
- `product_price.id_product` → `product.id_product` (un prix concerne un produit)

### **Les contraintes que j'ai dû gérer :**

- **Clés primaires** – pour que chaque ligne soit unique
- **Clés étrangères** – pour garantir qu'on ne relie pas des données à des trucs qui n'existent pas
- **Contraintes d'intégrité** – par exemple, une quantité ne peut pas être négative
- **Unicité** – pour éviter les doublons (comme deux produits avec le même nom)

### **Pourquoi cette structure ?**

J'ai fait le choix d'une base **relationnelle classique** parce que c'est :

- Fiable – les transactions ACID, c'est important pour l'argent
- Cohérent – pas de données qui se contredisent
- Évolutif – on peut ajouter des tables sans tout casser

![image.png](attachment:c98e8147-7553-4438-846f-9155cf687b21:image.png)

---

# **2. La création de la base : passage à l'acte**

## **2.1 Le paramétrage : pourquoi UTF8MB4 ?**

Quand j'ai créé la base, j'ai fait attention à un détail qui a son importance :

sql

```
CREATE DATABASE project_pos
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;
```

**Pourquoi ce choix ?**

- **utf8mb4** permet de stocker tous les caractères Unicode, y compris les emojis. Ça peut paraître gadget, mais dans certaines régions, les gens communiquent beaucoup avec des emojis, et ça peut servir pour les notes ou commentaires.
- **utf8mb4_unicode_ci** gère correctement les accents et la casse. "Épicerie" et "epicerie", c'est pareil pour la recherche.

En gros, ça rend la base **prête pour l'international** sans mauvaises surprises.

---

## **2.2 La structure détaillée des tables**

Pour chaque table, j'ai choisi des types de données adaptés :

- **INT** pour les identifiants (jamais trop grand, mais assez)
- **VARCHAR** pour les textes courts (avec des longueurs raisonnables)
- **DECIMAL** pour les prix – jamais de FLOAT pour l'argent, ça évite les erreurs d'arrondi
- **DATETIME** pour les dates (avec fuseau horaire géré côté application)

### **Exemple concret de création de table :**

sql

```
CREATE TABLE product (
    id_product INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    id_category INT NOT NULL,
    stock INT NOT NULL DEFAULT 0,
    status BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (id_category) REFERENCES category(id_category),
    CHECK (stock >= 0)
);
```

### **Ce que j'ai appris :**

- Le **AUTO_INCREMENT** simplifie la gestion des IDs
- Les **CHECK** évitent les données incohérentes (stock négatif impossible)
- Les **FOREIGN KEY** protègent l'intégrité des relations

---

## **2.3 La gestion des clés étrangères**

Au début, je me demandais si c'était vraiment utile de mettre des clés étrangères. Puis j'ai compris que c'est **une protection automatique** :

- Impossible de supprimer une catégorie qui contient encore des produits
- Impossible d'avoir une vente sans utilisateur valide
- La base elle-même empêche les incohérences

C'est un peu comme avoir un **garde-fou** qui veille en permanence.

---

## **2.4 L'historique des prix : un détail qui change tout**

La table `product_price` mérite qu'on s'y attarde :

sql

```
CREATE TABLE product_price (
    id_product_price INT PRIMARY KEY AUTO_INCREMENT,
    id_product INT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    date_start DATETIME NOT NULL,
    date_end DATETIME,
    FOREIGN KEY (id_product) REFERENCES product(id_product)
);
```

**Pourquoi cette table ?**

- Un produit peut changer de prix (promo, inflation, nouveau fournisseur)
- Pour les statistiques, on a besoin de savoir quel était le prix au moment de la vente
- Ça permet de suivre l'évolution des prix dans le temps

C'est un bon exemple de **feature simple qui apporte beaucoup de valeur** plus tard.

---

# **3. La sécurité : parce que l'argent, ça compte**

## **3.1 Un utilisateur dédié, pas de root**

Première règle : **ne jamais utiliser root** pour l'application. J'ai créé un utilisateur spécifique :

sql

```
CREATE USER 'pos_app'@'localhost' IDENTIFIED BY 'mot_de_passe_complexe';
```

Pourquoi ? Si l'application est piratée, le pirate n'a accès qu'à cette base, pas à tout le serveur. C'est le principe du **moindre privilège**.

---

## **3.2 Des permissions au compte-gouttes**

J'ai donné à cet utilisateur **uniquement les droits nécessaires** :

sql

```
GRANT SELECT, INSERT, UPDATE, DELETE
ON project_pos.*
TO 'pos_app'@'localhost';
```

- Pas de droit de créer ou supprimer des tables (DROP, ALTER)
- Pas d'accès aux autres bases
- Juste ce qu'il faut pour faire son travail

---

## **3.3 La protection des données sensibles**

### **Pour les mots de passe :**

- Jamais stockés en clair (évidemment)
- Hachés avec **bcrypt** côté application
- Le hachage est salé et lent (résiste aux attaques par brute force)

### **Contre les injections SQL :**

- Utilisation systématique de **requêtes préparées**
- Jamais de concaténation directe dans les requêtes
- Les entrées utilisateur sont toujours nettoyées

Exemple (en PHP) :

php

```
$stmt = $pdo->prepare("SELECT * FROM product WHERE id_category = ?");
$stmt->execute([$categoryId]);
```

Ça paraît basique, mais c'est ce qui arrête 99% des attaques.

---

## **3.4 Les index : vitesse et performance**

Avec le temps, les tables vont grossir. Sans index, les recherches deviendraient lentes. J'ai donc ajouté des index stratégiques :

sql

```
CREATE INDEX idx_product_category ON product(id_category);
CREATE INDEX idx_sale_date ON sale(sale_date);
CREATE INDEX idx_product_price_active ON product_price(id_product, date_end);
```

**Où j'ai mis des index :**

- Sur les clés étrangères (accélère les jointures)
- Sur les dates (pour les recherches par période)
- Sur les colonnes souvent utilisées dans les filtres

**Ce qu'il faut savoir :** les index accélèrent la lecture mais ralentissent l'écriture. C'est un équilibre à trouver. Pour un POS, on lit beaucoup plus qu'on n'écrit, donc j'ai privilégié la lecture.

---

# **4. Ce que j'ai appris et ce que j'aurais pu améliorer**

## **Ce qui fonctionne bien :**

- La structure est **simple mais extensible** – on peut ajouter des fonctionnalités sans tout casser
- L'historique des prix est une **bonne surprise** – je ne pensais pas que ce serait si utile
- Les index bien placés font une **vraie différence** en termes de performances

## **Ce que je ferais différemment :**

- J'aurais peut-être prévu un **système de multi-boutiques** dès le départ (pour les chaînes)
- La gestion des **stocks par lot** pourrait être utile pour certains produits
- Un **système de logs** plus détaillé pour tracer qui fait quoi

## **Les choix que j'assume :**

- Base relationnelle plutôt que NoSQL – la cohérence des données est trop importante
- UTF8MB4 même si un peu plus lourd – l'internationalisation, c'est important
- Pas de trigger ni de procédure stockée – je préfère garder la logique dans l'application

---

# **5.  Pour finir**

Cette base de données, c'est un peu le **squelette de tout le projet**. Si elle est bien pensée, le reste suit plus facilement. J'ai essayé de trouver le bon équilibre entre :

- **Simplicité** – pour que le MVP soit réalisable rapidement
- **Robustesse** – pour que les données soient fiables
- **Évolutivité** – pour que le projet puisse grandir

Le prochain défi, ce sera de **connecter tout ça à l'application** et de gérer la synchronisation quand il n'y a pas de réseau. Mais ça, c'est une autre histoire...