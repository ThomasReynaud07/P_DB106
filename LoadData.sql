-- Insertion des données avec les loads data
-- ATTENTION SI ERREURS A CETTE ETAPE, VOIR README.md ET FAIRE CE QUI EST DEMANDEE!!!

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
SELECT a.nom AS Pizza, SUM(lc.quantite) AS Total_Quantite
FROM t_ligne_commande lc
JOIN t_article a ON lc.article_fk = a.article_id
WHERE a.type = 'pizza'
GROUP BY a.nom
ORDER BY Total_Quantite DESC
LIMIT 10;          


-- Request 2
SELECT a.nom AS Topping, SUM(lc.quantite) AS Nombre
FROM t_ligne_commande lc
JOIN t_article a ON lc.article_fk = a.article_id
WHERE a.type = 'topping'  -- On cherche uniquement les toppings (type = 'topping')                       
GROUP BY a.nom   -- On regroupe par les noms des toppings
ORDER BY Nombre DESC; -- On affiche du plus grand au plus petit


-- Request 3
SELECT DATE(lv.date_arrivee) AS date_livraison, ROUND(SUM(p.montant), 2) AS chiffre_affaires
FROM t_livraison lv
JOIN t_paiements p ON lv.commande_fk = p.commande_fk
WHERE lv.statut = 'livree'  -- On ne prend en compte que les livraisons livrées
GROUP BY DATE(lv.date_arrivee)  -- On regroupe par date de livraison
ORDER BY date_livraison ASC;  -- On affiche par ordre chronologique


-- Request 4
SELECT ad.npa, ad.localite, ROUND(SUM(p.montant), 2) AS chiffre_affaires
FROM t_livraison lv
JOIN t_commande c ON lv.commande_fk = c.commande_id
JOIN t_adresse ad ON c.adresse_fk = ad.adresse_id
JOIN t_paiements p ON c.commande_id = p.commande_fk
WHERE lv.statut = 'livree'  -- On prend uniquement les commandes livrées
GROUP BY ad.npa, ad.localite  -- On regroupe par zone postale et localité
ORDER BY chiffre_affaires DESC; -- On affiche du plus grand chiffre d'affaires au plus petit


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
