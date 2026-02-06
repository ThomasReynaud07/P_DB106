# 🍕 Projet Pizzeria – Base de Données Relationnelle

![MySQL](https://img.shields.io/badge/MySQL-8.0-blue)
![SQL](https://img.shields.io/badge/SQL-Structured_Query_Language-lightgrey)
![Docker](https://img.shields.io/badge/Docker-Container-blue)
![Status](https://img.shields.io/badge/Project-Academic-success)

---

## 📌 Description

Ce projet consiste en la **conception et l’implémentation complète d’une base de données relationnelle pour une pizzeria**.  
Il permet de gérer les **clients, adresses, commandes, articles, paiements et livraisons**, en respectant l’intégrité référentielle et les bonnes pratiques SQL.

Le projet inclut :
- un **modèle de données (MLD)** réalisé avec Looping
- un **script SQL complet et commenté**
- une **exécution via MySQL dans un conteneur Docker**
- des **imports automatisés depuis des fichiers `.tsv`**

---

## 📑 Sommaire

- [Modèle de données](#-modèle-de-données)
- [Technologies utilisées](#-technologies-utilisées)
- [Fonctionnement du script SQL](#-fonctionnement-du-script-sql)
- [Installation et exécution](#-installation-et-exécution)
- [Fonctionnalités couvertes](#-fonctionnalités-couvertes)
- [Auteur](#-auteur)

---

## 🧱 Modèle de données

La base repose sur les tables principales suivantes :

- **t_client** : clients de la pizzeria  
- **t_adresse** : adresses associées aux clients  
- **t_article** : produits (pizzas, boissons, toppings…)  
- **t_commande** : commandes clients  
- **t_ligne_commande** : détails des articles commandés  
- **t_paiements** : paiements liés aux commandes  
- **t_livraison** : livraisons  
- **t_livreur** : livreurs  

Les relations permettent :
- plusieurs adresses par client
- plusieurs articles par commande
- une livraison unique par commande
- un suivi précis des paiements et livraisons

---

## 🛠️ Technologies utilisées

- **MySQL**
- **SQL**
- **Docker**
- **Looping** (conception du MLD)

---

## ⚙️ Fonctionnement du script SQL

Le fichier `script.sql` est **entièrement commenté** et suit une logique précise.

### 1️⃣ Préparation des fichiers de données

Les fichiers `.tsv` doivent être copiés dans le conteneur Docker MySQL afin d’être accessibles par la commande `LOAD DATA INFILE` :

```bash
docker cp t_client.tsv db:/var/lib/mysql-files/
docker cp t_adresse.tsv db:/var/lib/mysql-files/
docker cp t_article.tsv db:/var/lib/mysql-files/
docker cp t_livreur.tsv db:/var/lib/mysql-files/
docker cp t_commande.tsv db:/var/lib/mysql-files/
docker cp t_ligne_commande.tsv db:/var/lib/mysql-files/
docker cp t_paiement.tsv db:/var/lib/mysql-files/
docker cp t_livraison.tsv db:/var/lib/mysql-files/
```
---

## 📁 Copie du script dans le conteneur Docker

Le script SQL doit être copié dans le conteneur MySQL afin de pouvoir être exécuté :

```bash
docker cp script.sql db:/var/lib/mysql-files/
```
## ▶️ Exécution du script

Une fois connecté à MySQL, le script est lancé avec la commande :

```bash
SOURCE /var/lib/mysql-files/script.sql;
```

## 🗄️ Création de la base de données

Le script commence par :

🧹 la suppression de la base si elle existe déjà

🆕 la création d’une nouvelle base

🔤 l’utilisation de l’encodage utf8mb4

📌 la sélection de la base active

```bash
DROP DATABASE IF EXISTS db_thanos_pizzeria;
CREATE DATABASE db_thanos_pizzeria CHARACTER SET utf8mb4;
USE db_thanos_pizzeria;
```

## 🏗️ Création des tables

Les tables sont créées dans un ordre logique, afin de respecter les dépendances entre clés étrangères.

Principes appliqués :

🔑 clés primaires auto-incrémentées

🔗 clés étrangères garantissant l’intégrité référentielle

📋 types ENUM pour limiter les valeurs possibles

🔁 gestion des relations récursives (parent_ligne_fk)

📥 Import des données (LOAD DATA INFILE)

Les données sont importées depuis des fichiers .tsv avec les règles suivantes :

séparation par tabulation (\t)

encodage utf8mb4

première ligne ignorée (en-têtes de colonnes)

## 🧠 Traitements spécifiques

Gestion des valeurs NULL

adresse_fk = NULLIF(@adresse_fk, '')


Conversion des dates

date_creation = STR_TO_DATE(@date_str, '%d.%m.%Y %H:%i')


Gestion des relations conditionnelles

parent_ligne_fk = IF(
  TRIM(@parent_ligne_fk) REGEXP '^[0-9]+$',
  CAST(@parent_ligne_fk AS UNSIGNED),
  NULL
);

## 💾 Sauvegardes et restauration (Docker)

🔹 Backup complet
```bash
docker exec -i db mysqldump -u root -proot db_pizzeria > backupFull.sql
```

🔹 Backup différentiel

```bash
docker exec -i db mysqldump -u root -proot \
--where="date_modification >= '2026-01-23 00:00:00'" \
db_pizzeria t_livreur > backupDiff.sql
```

🔹 Restauration

```bash
mysql -u root -proot db_pizzeria < backupFull.sql
```

## 👤 Auteur

Thomas Reynaud
