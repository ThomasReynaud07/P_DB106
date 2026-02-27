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
- un **modèle de données (MLD)** réalisé avec Looping voir image ci dessous
[image looping](MLD.png)
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
- **Looping** 

---

## ⚙️ Fonctionnement du script SQL

Les fichiers `Database.sql` et `LoadData.sql` sont **entièrement commentés** et suivent une logique précise.

### 1️⃣ Préparation des fichiers de données

Les fichiers `.tsv` doivent être copiés dans le conteneur Docker MySQL afin d’être accessibles par la commande `LOAD DATA INFILE` :
Pour ce faire vous allez allé dans le dossier où se trouve tous les fichiers de données .tsv, et vous allez ensuite executer les commandes ci-dessous!

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

## 📁 Copie des scripts dans le conteneur Docker

Les scripts SQL doivent être copié dans le conteneur MySQL afin de pouvoir être exécuté !
Pour ce faire vous allez allé dans le dossier où se trouve les scripts et vous allez executer ces 2 commandes :

```bash
docker cp Database.sql db:/var/lib/mysql-files/
docker cp LoadData.sql db:/var/lib/mysql-files/
```
## 🔌 Connexion à MySQL

Afin d'executer les scripts il faut vous connecter à MySQL ! 
Pour ce faire il faudra vous rendre dans la console db de votre docker et executer cette commande ci dessous : 

```bash
mysql -u{Username} -p{Password}
```
## ▶️ Exécution du script

Une fois connecté à MySQL, les script sont lancé avec ces 2 commandes :

```bash
SOURCE /var/lib/mysql-files/Database.sql;
SOURCE /var/lib/mysql-files/LoadData.sql;
```

## 🗄️ Création de la base de données

Le script `Database.sql` commence par :

```bash
DROP DATABASE IF EXISTS db_thanos_pizzeria;
CREATE DATABASE db_thanos_pizzeria CHARACTER SET utf8mb4;
USE db_thanos_pizzeria;
```

## 🏗️ Création des tables
```bash
CREATE TABLE t_client(
   client_id INT AUTO_INCREMENT,
   nom VARCHAR(50) NOT NULL,
   prenom VARCHAR(50) NOT NULL,
   courriel VARCHAR(255) NOT NULL,
   telephone VARCHAR(50) NOT NULL,
   PRIMARY KEY(client_id)
);

CREATE TABLE t_adresse(
   adresse_id INT AUTO_INCREMENT,
   client_fk INT NOT NULL,
   rue VARCHAR(255) NOT NULL,
   npa SMALLINT NOT NULL,
   localite VARCHAR(50) NOT NULL,
   longitude FLOAT,
   latitude FLOAT,
   PRIMARY KEY(adresse_id),
   FOREIGN KEY(client_fk) REFERENCES t_client(client_id)
);

CREATE TABLE t_article(
   article_id INT AUTO_INCREMENT,
   type VARCHAR(50) NOT NULL,
   nom VARCHAR(50) NOT NULL,
   prix FLOAT NOT NULL,
   tva FLOAT NOT NULL,
   actif BOOLEAN NOT NULL,
   PRIMARY KEY(article_id)
);

CREATE TABLE t_livreur(
   livreur_id INT AUTO_INCREMENT,
   nom VARCHAR(50) NOT NULL,
   actif BOOLEAN NOT NULL,		
   PRIMARY KEY(livreur_id)
);

CREATE TABLE t_commande(
   commande_id INT AUTO_INCREMENT,
   client_fk INT NOT NULL,
   type ENUM('sur_place','emporter','livraison') NOT NULL,  
   adresse_fk INT,
   date_creation DATETIME NOT NULL,   
   statut VARCHAR(50) NOT NULL,      
   PRIMARY KEY(commande_id),
   FOREIGN KEY(client_fk) REFERENCES t_client(client_id),
   FOREIGN KEY(adresse_fk) REFERENCES t_adresse(adresse_id)
);

CREATE TABLE t_ligne_commande(
   ligne_id INT AUTO_INCREMENT,
   commande_fk INT NOT NULL,
   article_fk INT NOT NULL,
   quantite INT,
   prix_unitaire FLOAT NOT NULL,
   parent_ligne_fk INT,  
   PRIMARY KEY(ligne_id),
   FOREIGN KEY(parent_ligne_fk) REFERENCES t_ligne_commande(ligne_id),
   FOREIGN KEY(article_fk) REFERENCES t_article(article_id),
   FOREIGN KEY(commande_fk) REFERENCES t_commande(commande_id)
);

CREATE TABLE t_livraison(
   livraison_id INT AUTO_INCREMENT,
   commande_fk INT NOT NULL,
   livreur_fk INT NOT NULL,
   statut ENUM('livree','annulee') NOT NULL,   
   date_depart DATETIME NOT NULL,
   date_arrivee DATETIME NOT NULL,  
   PRIMARY KEY(livraison_id),
   UNIQUE(commande_fk),
   FOREIGN KEY(livreur_fk) REFERENCES t_livreur(livreur_id),
   FOREIGN KEY(commande_fk) REFERENCES t_commande(commande_id)
);

CREATE TABLE t_paiements(
   paiements_id INT AUTO_INCREMENT,
   commande_fk INT NOT NULL,
   mode ENUM('cash','carte','twint') NOT NULL,  
   montant FLOAT NOT NULL,
   date_paiement DATETIME NOT NULL,
   PRIMARY KEY(paiements_id),
   FOREIGN KEY(commande_fk) REFERENCES t_commande(commande_id)
);
```

## 🧠 Traitements spécifiques

# Gestion des valeurs NULL
```bash
adresse_fk = NULLIF(@adresse_fk, '')
```
Cette ligne ci-dessus sert à eviter les erreurs quand une valeurs n'est pas remplis. 
Elle dit à MySQL "Si tu vois une valeur (Dans notre cas c'est adresse_fk) qui est vide, alors tu transforme cette valeur en null

# Conversion des dates
```bash
date_creation = STR_TO_DATE(@date_str, '%d.%m.%Y %H:%i')
```
Cette ligne ci-dessus sert à convertir les dates que nous humains écrivont (Exemple : 22.11.2007 00:13) en date que MySQL comprends qui ressemble plus à (2007-11-22)

# Gestion des relations conditionnelles
```bash
parent_ligne_fk = IF(
  TRIM(@parent_ligne_fk) REGEXP '^[0-9]+$',
  CAST(@parent_ligne_fk AS UNSIGNED),
  NULL
);
```
Cette ligne est utile pour faire la liaison entre les pizzas et le toppings ! (Exemple : Le topping champignons doit être lier à une pizza, mais si une pizza est seule alors il n'y a pas de toppings / parent)
TRIM : Enlève les espaces inutiles autour du texte.
REGEXP : Vérifie que le contenu est bien un nombre entier.
CAST : Transforme le texte exemple "12" en vrai nombre 12 ! Mais si la case est vide ou non valide, on mets NULL
Resumé : Si une pizza n'a pas de parents alors la case est null, Mais si un toppings est sur la pizza "10", alors le 10 est mis en Number et il est lié avec la pizza ! 

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

## 💻 Approfonidssement Application Web

Afin d'approfondir le projet db, j'ai réalisé une application web qui simule une pizzeria.
Nous pouvons faire une simulation de commande de pizza, et les entrées sont enregistrées dans la base de donnée.
Le but est d'approfondir mes connaissance en javascript et de continuer le projet DB.




## 👤 Auteur

Thomas Reynaud
