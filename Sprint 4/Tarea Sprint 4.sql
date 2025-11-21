CREATE DATABASE IF NOT EXISTS retail_analytics_db;
USE retail_analytics_db; 
DROP DATABASE IF EXISTS retail_analytics_db;


CREATE TABLE IF NOT EXISTS company(
	Company_ID VARCHAR(36)PRIMARY KEY,
	Company_name VARCHAR(150),
	Phone VARCHAR(20),
	Email VARCHAR(150),
	Country VARCHAR(100),
	Website VARCHAR(255));
    
CREATE TABLE IF NOT EXISTS credit_cards(
	ID VARCHAR(36)PRIMARY KEY,
	User_id VARCHAR(36),
	IBAN VARCHAR (34),
    PAN VARCHAR (34),
	PIN CHAR (4),
    CVV CHAR (4),
    Track_1 VARCHAR(79),
    Track_2 VARCHAR(40),
	Expiring_date DATE);

CREATE TABLE IF NOT EXISTS users(
	ID VARCHAR(36)PRIMARY KEY,
	Name VARCHAR(100),
	Surname VARCHAR(100),
	Phone VARCHAR(20),
	Email VARCHAR(150),
	Birth_date DATE,
	Country VARCHAR(100),
	City VARCHAR(100),
	Postal_code VARCHAR(10),
	Address VARCHAR(255));
    
DROP TABLE transactions;
    
CREATE TABLE IF NOT EXISTS transactions(
	ID VARCHAR(36)PRIMARY KEY,
	Card_id VARCHAR (36),
	Business_id VARCHAR (36), 
	Timestamp TIMESTAMP,
	Amount DECIMAL(10,2),
	Declined TINYINT(1),
	Product_id VARCHAR (36),
	User_id VARCHAR(36),
	Lat DECIMAL(25,20),
	Longitude DECIMAL(25,20),
FOREIGN KEY (User_id) REFERENCES users (ID),
FOREIGN KEY (Business_id) REFERENCES company (Company_ID),
FOREIGN KEY (Card_id) REFERENCES credit_cards (ID));

SHOW VARIABLES LIKE 'local_infile';
SET GLOBAL local_infile = 1;
    
LOAD DATA LOCAL INFILE '/Users/ekaterinasorokopudova/downloads/companies.csv'
INTO TABLE company
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS; 

SELECT * FROM company;

-- пердварительная обработка файла до импорта - изменила формат даты 

LOAD DATA LOCAL INFILE '/Users/ekaterinasorokopudova/downloads/Новая таблица - credit_cards (1).csv'
INTO TABLE credit_cards
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT * FROM credit_cards;
DROP TABLE credit_cards;

-- Предварительная обработка файла до импорта - изменила формат даты рождения. Актуально для обоих файлов с данными пользователей. 
-- Так же была ошибка из-за разделителя в CSV 

LOAD DATA LOCAL INFILE '/Users/ekaterinasorokopudova/downloads/european_users(1).csv'
INTO TABLE users
FIELDS TERMINATED BY ';' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS; 

LOAD DATA LOCAL INFILE '/Users/ekaterinasorokopudova/downloads/american_users(1).csv'
INTO TABLE users
FIELDS TERMINATED BY ';' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS; 

DROP TABLE users; 
SELECT * FROM users;


LOAD DATA LOCAL INFILE '/Users/ekaterinasorokopudova/downloads/transactions.csv'
INTO TABLE transactions
FIELDS TERMINATED BY ';' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS; 

SELECT * FROM transactions;
DROP TABLE transactions;


-- Realitza una subconsulta que mostri tots els usuaris amb més de 80 transaccions utilitzant almenys 2 taules. 

SELECT * FROM users
WHERE id IN 
	(SELECT user_id FROM transactions 
    GROUP BY user_id
    HAVING COUNT(id) > 80);
    
-- Mostra la mitjana d'amount per IBAN de les targetes de crèdit a la companyia Donec Ltd, utilitza almenys 2 taules.

SELECT round(AVG(transactions.amount),2) AS 'Coste medio', 
		credit_cards.IBAN 
FROM credit_cards
JOIN transactions 
	ON transactions.card_id = credit_cards.id
JOIN company 
	ON transactions.business_id = company.company_id
WHERE company.company_name = 'Donec Ltd'
GROUP BY credit_cards.IBAN;

-- Crea una nova taula que reflecteixi l'estat de les targetes de crèdit basat en si les últimes tres transaccions van ser declinades i genera 
-- la següent consulta: Quantes targetes estan actives

-- Averiguar qué tarjetas tienen secuencialmente 
-- las tres últimas operaciones y encontrar al menos una tarjeta en la que podamos comprobar el resultado final.

SELECT credit_cards.id, 
		transactions.timestamp, 
        Transactions.declined,
ROW_NUMBER () OVER (
	PARTITION BY credit_cards.id 
    ORDER BY transactions.timestamp DESC) AS 'test'
FROM credit_cards
JOIN transactions 
	ON credit_cards.id = transactions.card_id
WHERE transactions.declined !=0;

-- CcS-4870 ID va bien para las condiciones de ejercicio 

CREATE TABLE IF NOT EXISTS credit_card_status (
	id VARCHAR (36),
    status VARCHAR (36));

INSERT INTO credit_card_status (id, status)
WITH last_three AS (
	SELECT 
		credit_cards.id,
		transactions.timestamp, 
		transactions.declined,
		ROW_NUMBER() OVER (
			PARTITION BY credit_cards.id
			ORDER BY transactions.timestamp DESC) AS rn
	FROM credit_cards
	JOIN transactions
		ON credit_cards.id = transactions.card_id
)
SELECT 
	id,
	CASE 
		WHEN SUM(declined) = 3 THEN 'Inactive'
		ELSE 'Active'
	END AS status
FROM last_three
WHERE rn <= 3
GROUP BY id;

-- Comprobar el resultado 
SELECT * FROM credit_card_status
WHERE id = 'CcS-4870';

-- Quantes targetes estan actives
SELECT COUNT(id) FROM credit_card_status 
WHERE status = "Active"; 

-- Crea una tabla con la que podamos unir los datos del nuevo archivo products.csv con la base de datos creada, 
-- teniendo en cuenta que desde transaction tienes product_ids. 
CREATE TABLE IF NOT EXISTS products(
	id VARCHAR(36)PRIMARY KEY,
	product_name VARCHAR(150),
	price DECIMAL (10,2),
	colour VARCHAR(50),
	weight DECIMAL (8,3),
	warehouse_id Varchar(20));

-- Не загружалась колонка с ценами из-за наличия $ в графе. Предварительно отредактировала файл. 
LOAD DATA LOCAL INFILE '/Users/ekaterinasorokopudova/downloads/products(2).csv'
INTO TABLE products
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS; 

SELECT * FROM products;
DROP TABLE products;

CREATE TABLE IF NOT EXISTS transaction_product (
transaction_id VARCHAR(36),
product_id VARCHAR(36),
FOREIGN KEY (product_id) REFERENCES products(ID),
FOREIGN KEY (transaction_id) REFERENCES transactions(ID)); 


INSERT INTO transaction_product(transaction_id, product_id) 
WITH RECURSIVE split_ids AS (
  SELECT 
    id AS transaction_id,
    TRIM(SUBSTRING_INDEX(product_id, ',', 1)) AS product_id,
    SUBSTRING(product_id, LENGTH(SUBSTRING_INDEX(product_id, ',', 1)) + 2) AS rest
  FROM transactions

  UNION ALL

  SELECT
    transaction_id,
    TRIM(SUBSTRING_INDEX(rest, ',', 1)),
    SUBSTRING(rest, LENGTH(SUBSTRING_INDEX(rest, ',', 1)) + 2)
  FROM split_ids 
  WHERE rest != ''
)
SELECT transaction_id, product_id FROM split_ids;

SELECT * FROM transaction_product
ORDER BY transaction_id;

-- Para mantener la coherencia de los datos y normalizar la base de datos 

ALTER TABLE transactions
DROP COLUMN Product_id;

-- Necessitem conèixer el nombre de vegades que s'ha venut cada producte.
SELECT COUNT(product_name) AS 'cantidad', 
		product_name 
		FROM products 
JOIN transaction_product 
	ON products.ID = transaction_product.product_id 
GROUP BY id;




