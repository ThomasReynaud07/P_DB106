-- Creation Db
DROP DATABASE IF EXISTS db_thanos_pizzeria;     -- Suppression de la database si elle existe déjà!
CREATE DATABASE db_thanos_pizzeria CHARACTER SET utf8mb4;       -- Création de la database
USE db_thanos_pizzeria;     -- Choix de la database

-- Création des différentes tables en fonction des données fournies par le prof
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
   statut ENUM('livree','annulee') NOT NULL,   -- Mettre ENMU pour avoir 2 choix et pas juste un VARCHAR
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
   mode ENUM('cash','carte','twint') NOT NULL,  -- Mettre ENMU pour avoir 3 choix et pas juste un VARCHAR
   montant FLOAT NOT NULL,
   date_paiement DATETIME NOT NULL,
   PRIMARY KEY(paiements_id),
   FOREIGN KEY(commande_fk) REFERENCES t_commande(commande_id)
);