-- À exécuter avant le script dans le dossier données :
-- Aller dans le cmd depuis le dossier données et executer
/*
docker cp t_client.tsv db:/var/lib/mysql-files/
docker cp t_adresse.tsv db:/var/lib/mysql-files/
docker cp t_article.tsv db:/var/lib/mysql-files/
docker cp t_livreur.tsv db:/var/lib/mysql-files/
docker cp t_commande.tsv db:/var/lib/mysql-files/
docker cp t_ligne_commande.tsv db:/var/lib/mysql-files/
docker cp t_paiement.tsv db:/var/lib/mysql-files/
docker cp t_livraison.tsv db:/var/lib/mysql-files/
*/
-- A executer depuis le cmd aussi dans le dossier ou se trouve script.sql!!!
-- docker cp script.sql db:/var/lib/mysql-files/

-- Commande à rentrer dans MySQL pour exécuter le script
-- SOURCE /var/lib/mysql-files/script.sql

-- Commandes Docker à exécuter pour faire un backup complet
/*Il faut rajouter un dossier backup dans le dossier de mapping (Docker_MYSQL) et ensuite executer cette commande
docker exec -i db mysqldump -u root -proot db_pizzeria > chemin\backupFull.sql
*/

-- Commandes Docker à exécuter pour faire un backup différentiel des tables qui ont été modifiées apres 00:00
/*docker exec -i db mysqldump -u root -proot --where="date_modification >= '2026-01-223 00:00:00'" db_pizzeria t_livreur > chemin\backupDiff.sql*/

/*Commandes Docker à exécuter pour restaurer une BDD à partir d'un fichier
-- Il faut d'abord copier le fichier dans Docker pour que MySQL y ait accès
-- docker cp "chemin_du_volume_Docker\backup\backupFull.sql" db:/backupFull.sql
-- Commande pour restaurer la BDD (il faut s'assurer que la BDD db_pizzeria existe avant d'exécuter la commande)
-- mysql -u root -proot db_pizzeria < /backupFull.sql*/

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


-- Insertion des données avec les loads data
-- ATTENTION SI ERREURS A CETTE ETAPE, VOIR TOUT AU DEBUT DU SCRIPT ET FAIRE CE QUI EST DEMANDEE!!!

LOAD DATA INFILE '/var/lib/mysql-files/t_client.tsv'    -- Choix du fichier qui contient les données
INTO TABLE t_client     -- Table dans laquelle on veut inserer les données
CHARACTER SET utf8mb4   -- Le character cet pour eviter les erreurs de charactere
FIELDS TERMINATED BY '\t'   -- Les champs se termine par des espaces vides car c'est un fichier .tsv
LINES TERMINATED BY '\n'    -- Les lignes se passe avec des tabulations car c'est un fichier .tsv
IGNORE 1 LINES;     -- On ignore la première ligne car c'est la ligne avec le nom des colonnes.

LOAD DATA INFILE '/var/lib/mysql-files/t_adresse.tsv'
INTO TABLE t_adresse
CHARACTER SET utf8mb4
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

LOAD DATA INFILE '/var/lib/mysql-files/t_article.tsv'
INTO TABLE t_article
CHARACTER SET utf8mb4
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

LOAD DATA INFILE '/var/lib/mysql-files/t_livreur.tsv'
INTO TABLE t_livreur
CHARACTER SET utf8mb4
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

LOAD DATA INFILE '/var/lib/mysql-files/t_commande.tsv'
INTO TABLE t_commande
CHARACTER SET utf8mb4
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@commande_id, @client_fk, @type, @adresse_fk, @date_str, @statut)
SET
    commande_id = @commande_id,
    client_fk = @client_fk,
    type = @type,
    adresse_fk = NULLIF(@adresse_fk, ''),       -- On met une adresse en NULL si elle est en espace vide dans le fichier .tsv
    date_creation = STR_TO_DATE(@date_str, '%d.%m.%Y %H:%i'),       -- On change le format de DATETIME car les données ne sont pas au même format
    statut = @statut;

LOAD DATA INFILE '/var/lib/mysql-files/t_ligne_commande.tsv'
INTO TABLE t_ligne_commande
CHARACTER SET utf8mb4
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@ligne_id, @commande_fk, @article_fk, quantite, prix_unitaire, @parent_ligne_fk)
SET
  commande_fk = @commande_fk,
  article_fk = @article_fk,
  parent_ligne_fk = IF(TRIM(@parent_ligne_fk) REGEXP '^[0-9]+$', CAST(@parent_ligne_fk AS UNSIGNED), NULL);     -- J'ai fais cette commande avec CHATGPT car j'ai eu bcp de soucis et il n'y a que cette dernière qui marche.

LOAD DATA INFILE '/var/lib/mysql-files/t_paiement.tsv'
INTO TABLE t_paiements
CHARACTER SET utf8mb4
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(paiements_id, @commande_fk, mode, montant, @date_paiement)
SET
  commande_fk = @commande_fk,
  date_paiement = STR_TO_DATE(@date_paiement, '%d.%m.%Y %H:%i');    -- On change le format de DATETIME car les données ne sont pas au même format

LOAD DATA INFILE '/var/lib/mysql-files/t_livraison.tsv'
INTO TABLE t_livraison
CHARACTER SET utf8mb4
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@livraison_id, @commande_fk, @livreur_fk, @statut, @date_depart, @date_arrivee)
SET
    livraison_id = NULLIF(@livraison_id, ''),   -- On met une livraison en NULL si elle est en espace vide dans le fichier .tsv
    commande_fk = NULLIF(@commande_fk, ''),     -- On met une commande en NULL si elle est en espace vide dans le fichier .tsv
    livreur_fk = NULLIF(@livreur_fk, ''),       -- On met un livreur en NULL si elle est en espace vide dans le fichier .tsv
    statut = @statut,
    date_depart = STR_TO_DATE(@date_depart, '%d.%m.%Y %H:%i'),      -- On change le format de DATETIME car les données ne sont pas au même format
    date_arrivee = STR_TO_DATE(@date_arrivee, '%d.%m.%Y %H:%i');    -- On change le format de DATETIME car les données ne sont pas au même format

ALTER TABLE t_adresse
ADD COLUMN date_modification DATETIME DEFAULT CURRENT_TIMESTAMP 
ON UPDATE CURRENT_TIMESTAMP;

ALTER TABLE t_client
ADD COLUMN date_modification DATETIME DEFAULT CURRENT_TIMESTAMP 
ON UPDATE CURRENT_TIMESTAMP;
 
ALTER TABLE t_article
ADD COLUMN date_modification DATETIME DEFAULT CURRENT_TIMESTAMP 
ON UPDATE CURRENT_TIMESTAMP;

ALTER TABLE t_livreur
ADD COLUMN date_modification DATETIME DEFAULT CURRENT_TIMESTAMP 
ON UPDATE CURRENT_TIMESTAMP;

ALTER TABLE t_commande
ADD COLUMN date_modification DATETIME DEFAULT CURRENT_TIMESTAMP 
ON UPDATE CURRENT_TIMESTAMP;

ALTER TABLE t_ligne_commande
ADD COLUMN date_modification DATETIME DEFAULT CURRENT_TIMESTAMP 
ON UPDATE CURRENT_TIMESTAMP;

ALTER TABLE t_paiements
ADD COLUMN date_modification DATETIME DEFAULT CURRENT_TIMESTAMP 
ON UPDATE CURRENT_TIMESTAMP;

ALTER TABLE t_livraison
ADD COLUMN date_modification DATETIME DEFAULT CURRENT_TIMESTAMP 
ON UPDATE CURRENT_TIMESTAMP;

-- Request Select

-- Request 1
SELECT t_article.nom AS Pizza, COUNT(quantite) AS Total
FROM t_ligne_commande
JOIN t_article
ON article_id = article_fk
WHERE article_fk BETWEEN 1 AND 8    -- Car dans les articles il n'y a que les 8 premières qui sont des pizzas, le reste c'est boissons, desserts et toppings
GROUP BY t_article.nom              -- On regroupe par pizza 
ORDER BY Total DESC;                -- On affiche du plus grand au plus petit

SELECT 
  a.nom AS pizza,
  SUM(lc.quantite) AS quantite_totale
FROM t_ligne_commande lc
JOIN t_article a ON a.article_id = lc.article_fk
WHERE a.type = 'pizza'
GROUP BY a.nom
ORDER BY quantite_totale DESC
LIMIT 10;


-- Request 2
SELECT a.nom AS Topping, COUNT(l.ligne_id) AS Nombre
FROM t_ligne_commande AS l
JOIN t_article a ON l.article_fk = a.article_id
WHERE a.type = 'topping'            -- On cherche uniquement les toppings (type = 'topping')
GROUP BY a.nom                      -- On regroupe par les noms des toppings
ORDER BY Nombre DESC;               -- On affiche du plus grand au plus petit

SELECT
  a.nom AS topping,
  SUM(lc.quantite) AS nombre
FROM t_ligne_commande AS lc
JOIN t_article a ON a.article_id = lc.article_fk
WHERE a.type = 'topping'
GROUP BY a.nom
ORDER BY nombre DESC;


-- Request 3
SELECT DATE(liv.date_arrivee) AS date_livraison, ROUND(SUM(p.montant), 2) AS chiffre_affaires
FROM t_livraison liv
JOIN t_paiements p ON liv.commande_fk = p.commande_fk
WHERE liv.statut = 'livree'         -- On ne prend en compte que les livraisons livrées
GROUP BY DATE(liv.date_arrivee)     -- On regroupe par date de livraison
ORDER BY DATE(liv.date_arrivee);    -- On affiche par ordre chronologique

SELECT 
  DATE(lv.date_arrivee) AS date_livraison,
  ROUND(SUM(p.montant), 2) AS chiffre_affaires
FROM t_livraison lv
JOIN t_paiements p ON p.commande_fk = lv.commande_fk
WHERE lv.statut = 'livree'
GROUP BY DATE(lv.date_arrivee)
ORDER BY DATE(lv.date_arrivee);


-- Request 4
SELECT a.npa, a.localite, ROUND(SUM(p.montant), 2) AS chiffre_affaires
FROM t_livraison l
JOIN t_commande c ON l.commande_fk = c.commande_id
JOIN t_adresse a ON c.adresse_fk = a.adresse_id
JOIN t_paiements p ON c.commande_id = p.commande_fk
WHERE l.statut = 'livree'           -- On prend uniquement les commandes livrées
GROUP BY a.npa, a.localite          -- On regroupe par zone postale et localité
ORDER BY chiffre_affaires DESC;     -- On affiche du plus grand chiffre d'affaires au plus petit

SELECT
  a.npa,
  a.localite,
  ROUND(SUM(p.montant), 2) AS chiffre_affaires
FROM t_livraison lv
JOIN t_commande c  ON c.commande_id = lv.commande_fk
JOIN t_adresse a   ON a.adresse_id = c.adresse_fk
JOIN t_paiements p ON p.commande_fk = c.commande_id
WHERE lv.statut = 'livree'
GROUP BY a.npa, a.localite
ORDER BY chiffre_affaires DESC;


-- Request 5
SELECT HOUR(date_creation) AS heure, COUNT(commande_id) AS nombre_commandes
FROM t_commande
GROUP BY heure                      -- On regroupe les commandes par heure de création
ORDER BY nombre_commandes DESC;     -- On affiche les heures les plus actives en premier

-- Request 6
SELECT c.client_id, c.nom, c.prenom, COUNT(cmd.commande_id) AS nombre_commandes
FROM t_commande AS cmd
JOIN t_client AS c ON cmd.client_fk = c.client_id
GROUP BY c.client_id, c.nom, c.prenom
HAVING COUNT(cmd.commande_id) >= 5          -- On garde uniquement les clients ayant passé au moins 5 commandes
ORDER BY nombre_commandes DESC, c.nom ASC;  -- On trie par nombre de commandes puis par nom

-- Request 7
SELECT lc.commande_fk AS commande_id, ROUND(SUM(lc.quantite * lc.prix_unitaire), 2) AS montant_du
FROM t_ligne_commande AS lc
GROUP BY lc.commande_fk     -- On calcule le total dû par commande
ORDER BY lc.commande_fk ASC;        -- On affiche par ordre d'ID de commande

-- Request 8
SELECT commande_fk AS commande_id, ROUND(SUM(montant), 2) AS total_paye
FROM t_paiements
GROUP BY commande_fk
HAVING total_paye > 5       -- On garde uniquement les commandes payées à plus de 5 CHF
ORDER BY commande_fk ASC;   -- On affiche dans l'ordre des ID de commande

-- Request 9
SELECT type, COUNT(*) AS nombre_commandes
FROM t_commande
GROUP BY type                       -- On regroupe par type de commande (sur place, à emporter, livraison)
ORDER BY nombre_commandes DESC;     -- On affiche le type le plus fréquent en premier

-- Request 10
SELECT l.livreur_id, l.nom, ROUND(AVG(TIMESTAMPDIFF(MINUTE, lv.date_depart, lv.date_arrivee)), 2) AS delai_moyen_minutes
FROM t_livraison AS lv
JOIN t_livreur AS l ON lv.livreur_fk = l.livreur_id
GROUP BY l.livreur_id, l.nom        -- On regroupe par livreur
ORDER BY delai_moyen_minutes ASC;   -- On affiche du plus rapide au plus lent

-- Index

-- 1)
SELECT c.commande_id, c.date_creation, c.statut, cl.nom AS client
FROM t_commande AS c
JOIN t_client AS cl ON c.client_fk = cl.client_id
WHERE c.statut = 'en_livraison' AND c.date_creation > '2025-01-01'
ORDER BY c.date_creation DESC;

-- Accélère le filtrage par statut et date
CREATE INDEX idx_commande_statut_date ON t_commande(statut, date_creation);

-- Optimise la jointure avec t_commande.
CREATE INDEX idx_client_id ON t_client(client_id);

-- 2)
SELECT a.npa AS zone_npa, COUNT(c.commande_id) AS nb
FROM t_commande AS c
JOIN t_adresse AS a ON c.adresse_fk = a.adresse_id
WHERE c.type = 'livraison' AND HOUR(c.date_creation) BETWEEN 18 AND 21
GROUP BY a.npa
ORDER BY nb DESC;

-- Accélère le filtrage par type et heure
CREATE INDEX idx_commande_type_date ON t_commande(type, date_creation);

-- Optimise la jointure avec t_commande.
CREATE INDEX idx_adresse_id ON t_adresse(adresse_id);

-- Accélère le GROUP BY sur la zone postale.
CREATE INDEX idx_adresse_npa ON t_adresse(npa);

-- Rôle


-- 1. Création des rôles
DROP ROLE IF EXISTS 'admin', 'manager', 'pizzaiolo', 'livreur', 'agent_caisse', 'analyste';
CREATE ROLE 'admin';
CREATE ROLE 'manager';
CREATE ROLE 'pizzaiolo';
CREATE ROLE 'livreur';
CREATE ROLE 'agent_caisse';
CREATE ROLE 'analyste';

-- 2. Attribution rôle

-- ADMIN : 
    GRANT ALL PRIVILEGES ON db_thanos_pizzeria.* TO 'admin';

-- MANAGER :
    GRANT SELECT, INSERT, UPDATE ON db_thanos_pizzeria.t_commande TO 'manager';
    GRANT SELECT, INSERT, UPDATE ON db_thanos_pizzeria.t_livraison TO 'manager';
	GRANT SELECT ON db_thanos_pizzeria.t_paiements TO 'manager';
	GRANT SELECT, INSERT, UPDATE ON db_thanos_pizzeria.t_article TO 'manager';

-- PIZZAIOLO : 
    GRANT SELECT, UPDATE ON db_thanos_pizzeria.t_commande TO 'pizzaiolo';

-- LIVREUR : 
    GRANT SELECT, UPDATE ON db_thanos_pizzeria.t_livraison TO 'livreur';
	GRANT SELECT ON db_thanos_pizzeria.t_commande TO 'livreur';

-- AGENT_CAISSE : 
    GRANT SELECT ON db_thanos_pizzeria.t_commande TO 'agent_caisse';
    GRANT INSERT, UPDATE ON db_thanos_pizzeria.t_paiements TO 'agent_caisse';

-- ANALYSTE : 
    GRANT SELECT ON db_thanos_pizzeria.* TO 'analyste';

-- 3. Creation usr + role attr

-- Users
DROP USER IF EXISTS 
  'admin_user'@'%',
  'manager_user'@'%',
  'pizzaiolo_user'@'%',
  'livreur_user'@'%',
  'caisse_user'@'%',
  'analyste_user'@'%';

CREATE USER 'admin_user'@'%' IDENTIFIED BY 'adminpass';
CREATE USER 'manager_user'@'%' IDENTIFIED BY 'managerpass';
CREATE USER 'pizzaiolo_user'@'%' IDENTIFIED BY 'pizzaiolopass';
CREATE USER 'livreur_user'@'%' IDENTIFIED BY 'livreurpass';
CREATE USER 'caisse_user'@'%' IDENTIFIED BY 'caissepass';
CREATE USER 'analyste_user'@'%' IDENTIFIED BY 'analystepass';

-- Roles
GRANT 'admin' TO 'admin_user'@'%';
GRANT 'manager' TO 'manager_user'@'%';
GRANT 'pizzaiolo' TO 'pizzaiolo_user'@'%';
GRANT 'livreur' TO 'livreur_user'@'%';
GRANT 'agent_caisse' TO 'caisse_user'@'%';
GRANT 'analyste' TO 'analyste_user'@'%';

-- Roles actifs
SET DEFAULT ROLE ALL TO
  'admin_user'@'%',
  'manager_user'@'%',
  'pizzaiolo_user'@'%',
  'livreur_user'@'%',
  'caisse_user'@'%',
  'analyste_user'@'%';
