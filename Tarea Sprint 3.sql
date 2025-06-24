-- Crear una nueva tabla
CREATE TABLE IF NOT EXISTS credit_card (
	id VARCHAR(15) PRIMARY KEY,
	iban VARCHAR(40),
	pan VARCHAR(25),
	pin CHAR(4) CHECK (LENGTH(pin) = 4),
	cvv CHAR(4) CHECK (LENGTH(cvv) BETWEEN 3 AND 4),
	expiring_date VARCHAR(10)
);

-- Descardar los datos del 'datos introducir sprint 3 user'
-- Cambiar el nombre de la tabla a temporal para hacer transferencia de datos
RENAME TABLE credit_card TO temp_credit_card;

-- Crear una nueva tabla (otra vez) 
CREATE TABLE IF NOT EXISTS credit_card (
	id VARCHAR(15) PRIMARY KEY,
	iban VARCHAR(40),
	pan VARCHAR(25),
	pin CHAR(4) CHECK (LENGTH(pin) = 4),
	cvv CHAR(4) CHECK (LENGTH(cvv) BETWEEN 3 AND 4),
	expiring_date TIMESTAMP(10)
);
-- Cambio de tipo de datos a TIMESTAMP 
INSERT INTO credit_card (id, iban, pan, pin, cvv, expiring_date)
SELECT
  id,
  iban,
  pan,
  pin,
  cvv,
  STR_TO_DATE(expiring_date, '%m/%d/%y')
FROM temp_credit_card;

-- Compruebe si los datos cargados son correctos
SELECT * FROM credit_card;

-- Eliminar tabla temporal
DROP TABLE temp_credit_card;

-- Vincular las tablas de tarjetas de credit y de transacción. Añadir FK para una tabla de transacciones
ALTER TABLE transaction
ADD FOREIGN KEY (credit_card_id) REFERENCES credit_card(id);

-- Trae una lista de todos los FK para la base de datos
SELECT 
    TABLE_NAME, 
    COLUMN_NAME, 
    CONSTRAINT_NAME, 
    REFERENCED_TABLE_NAME, 
    REFERENCED_COLUMN_NAME
FROM 
    information_schema.KEY_COLUMN_USAGE
WHERE 
    CONSTRAINT_SCHEMA = 'transactions'
    AND REFERENCED_TABLE_NAME IS NOT NULL;

-- El departamento de Recursos Humanos ha identificado un error en el número de cuenta asociado a su tarjeta de crédito con ID CcU-2938. 
-- La información que debe mostrarse para este registro es: TR323456312213576817699999. Recuerda mostrar que el cambio se realizó.
UPDATE credit_card SET iban = 'TR323456312213576817699999' WHERE id = 'CcU-2938';

SELECT * FROM credit_card WHERE ID = 'CcU-2938';

-- En la tabla "transaction" ingresa un nuevo usuario con la siguiente información
INSERT INTO company (id) VALUES ('b-9999');
INSERT INTO credit_card (id) VALUES ('CcU-9999');

INSERT INTO transaction (id, credit_card_id, company_id, user_id, lat, longitude, timestamp, amount, declined) 
VALUES('108B1D1D-5B23-A76C-55EF-C568E49A99DD', 'CcU-9999', 'b-9999', '9999', '829.999', '-117.999',NULL,'111.11', '0');

-- O
SET FOREIGN_KEY_CHECKS = 0; #Отключение проверок
ALTER TABLE transactions DROP FOREIGN KEY 'transaction_ibfk_1';
SET FOREIGN_KEY_CHECKS = 1; # Включение проверок
 
INSERT INTO transaction (id, credit_card_id, company_id, user_id, lat, longitude, timestamp, amount, declined) 
VALUES('108B1D1D-5B23-A76C-55EF-C568E49A99DD', 'CcU-9999', 'b-9999', '9999', '829.999', '-117.999',NULL,'111.11', '0');

ALTER TABLE transaction
ADD FOREIGN KEY (company_id) REFERENCES company(id) ;

-- Desde recursos humanos te solicitan eliminar la columna "pan" de la tabla credit_card. Recuerda mostrar el cambio realizado. 
SELECT * FROM credit_card; 
ALTER TABLE credit_card DROP COLUMN pan; 

-- Elimina de la taula transaction el registre amb ID 000447FE-B650-4DCF-85DE-C7ED0EE1CAAD de la base de dades.
SELECT * FROM Transaction WHERE ID = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';
DELETE FROM transaction WHERE ID = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';

-- La secció de màrqueting desitja tenir accés a informació específica per a realitzar anàlisi i estratègies efectives. 
-- S'ha sol·licitat crear una vista que proporcioni detalls clau sobre les companyies i les seves transaccions. 
-- Serà necessària que creïs una vista anomenada VistaMarketing que contingui la següent informació: 
-- Nom de la companyia. Telèfon de contacte. País de residència. Mitjana de compra realitzat per cada companyia. 
-- Presenta la vista creada, ordenant les dades de major a menor mitjana de compra.

CREATE VIEW VistaMarketing AS
SELECT company.company_name, company.phone, company.country, 
        AVG(transaction.amount) as 'Average amount'
FROM company 
JOIN transaction ON company.id = transaction.company_id
GROUP BY company.company_name, company.phone, company.country
ORDER BY `Average amount` DESC;

-- Método de supresión de una vista
DROP VIEW VistaMarketing;

-- Filtra la vista VistaMarketing per a mostrar només les companyies que tenen el seu país de residència en "Germany"
SELECT * FROM vistamarketing
WHERE country = 'Germany'; 

-- La setmana vinent tindràs una nova reunió amb els gerents de màrqueting. 
-- Un company del teu equip va realitzar modificacions en la base de dades, però no recorda com les va realitzar. 
-- Et demana que l'ajudis a deixar els comandos executats per a obtenir el següent diagrama:

-- Crear la tabla inicial "user"
CREATE TABLE IF NOT EXISTS user (
	id CHAR(10) PRIMARY KEY,
	name VARCHAR(100),
	surname VARCHAR(100),
	phone VARCHAR(150),
	email VARCHAR(150),
	birth_date VARCHAR(100),
	country VARCHAR(150),
	city VARCHAR(150),
	postal_code VARCHAR(100),
	address VARCHAR(255));

-- Modificar el tipo de datos de la columna "id" en la tabla "data_user"
ALTER TABLE user MODIFY COLUMN id INT;

-- Para identificar a los usuarios que no están en la nueva tabla user
SELECT DISTINCT user_id
FROM transaction
WHERE user_id IS NOT NULL
  AND user_id NOT IN (SELECT id FROM user);

-- Borrar todas las transacciones de este usuario que no estaba en la nueva tabla de la tabla transaction
SELECT * FROM transaction WHERE user_id='9999';
DELETE FROM transaction WHERE id='108B1D1D-5B23-A76C-55EF-C568E49A99DD';

-- Crear relación entre las tablas "transaction" y "user"
ALTER TABLE transaction
ADD FOREIGN KEY (user_id) REFERENCES user(id);

-- Cambiar el nombre de la tabla "user" a "data_user"
RENAME TABLE user TO data_user;

-- Eliminar la columna "website" de la tabla "company"
ALTER TABLE company DROP COLUMN website;

-- Añadir nueva columna "fecha_actual" en la tabla "credit_card"
ALTER TABLE credit_card ADD COLUMN fecha_actual DATE;

-- Modificar tipo de datos de columnas en la tabla "credit_card"
ALTER TABLE credit_card MODIFY COLUMN cvv INT;
ALTER TABLE credit_card MODIFY COLUMN pin VARCHAR(4);
ALTER TABLE credit_card MODIFY COLUMN expiring_date VARCHAR(20);

-- Cambiar el nombre de la columna "email" a "personal_email"
ALTER TABLE data_user RENAME COLUMN email TO personal_email;

-- Cambiar longitud de las filas
ALTER TABLE credit_card MODIFY COLUMN id VARCHAR(20);
ALTER TABLE transaction MODIFY COLUMN credit_card_id VARCHAR(20);

-- L'empresa també us demana crear una vista anomenada "InformeTecnico" que contingui la següent informació 
CREATE VIEW InformeTecnico AS
SELECT 
transaction.ID AS 'ID de la transacció', 
data_user.name AS 'Nom',
data_user.surname AS 'Cognom', 
credit_card.iban AS 'IBAN',
company.company_name AS 'Nom de la companyia'
FROM transaction
JOIN data_user ON data_user.id = transaction.user_id
JOIN company ON company.id = transaction.company_id 
JOIN credit_card ON credit_card.id = transaction.credit_card_id
ORDER BY transaction.ID DESC;