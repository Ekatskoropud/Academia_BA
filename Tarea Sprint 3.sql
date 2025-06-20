#Запрос для создания новой таблицы. СПРАВОЧНИК ТИПОВ ПОЛЕЙ https://opennet.ru/docs/RUS/mysqlcli/glava05.html 
CREATE TABLE IF NOT EXISTS credit_card (
	id VARCHAR(15) PRIMARY KEY,
	iban VARCHAR(40),
	pan VARCHAR(25),
	pin CHAR(4) CHECK (LENGTH(pin) = 4),
	cvv CHAR(4) CHECK (LENGTH(cvv) BETWEEN 3 AND 4),
	expiring_date TIMESTAMP
);

RENAME TABLE credit_card TO temp_credit_card;

#Изменение типа поля в TIMESTAMP 
INSERT INTO credit_card (id, iban, pan, pin, cvv, expiring_date)
SELECT
  id,
  iban,
  pan,
  pin,
  cvv,
  STR_TO_DATE(expiring_date, '%m/%d/%y')
FROM temp_credit_card;

#Добавить данные из datos_intriducir_sprin3_credit 
SELECT * FROM credit_card;

DROP TABLE temp_credit_card;

 #FK для credit_card_id VARCHAR(15) из таблицы транзакций, 
 #тип связи 1 к 1  FK для credit_card_id VARCHAR(15) из таблицы транзакций  -- credit_card_id VARCHAR(15) из таблицы транзакций 
 #Следовательно нужно добавить в таблицу транзакций новый FOREIGN KEY (credit_card_id) REFERENCES credit_card(id) 
 
 #Consulta para añadir FK a la tabla transaction
ALTER TABLE transaction
ADD FOREIGN KEY (credit_card_id) REFERENCES credit_card(id);

#Сделать запрос ответом которого будут все FK и PK таблицы транзакций 
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

#Заменить iban на правильный в таблице credit_card. El departamento de Recursos Humanos ha identificado un error en el número de cuenta asociado a su tarjeta de crédito con ID CcU-2938. La información que debe mostrarse para este registro es: TR323456312213576817699999. Recuerda mostrar que el cambio se realizó.
UPDATE credit_card SET iban = 'TR323456312213576817699999' WHERE id = 'CcU-2938';

SELECT * FROM credit_card WHERE ID = 'CcU-2938';

#En la tabla "transaction" ingresa un nuevo usuario con la siguiente información
INSERT INTO transaction (id, credit_card_id, company_id, user_id, lat, longitude, timestamp, amount, declined) 
VALUES('108B1D1D-5B23-A76C-55EF-C568E49A99DD', 'CcU-9999', 'b-9999', '9999', '829.999', '-117.999',NULL,'111.11', '0');

INSERT INTO company (id) VALUES ('b-9999');
INSERT INTO credit_card (id) VALUES ('CcU-9999');

#ИЛИ
SET FOREIGN_KEY_CHECKS = 0; #Отключение проверок
ALTER TABLE transactions DROP FOREIGN KEY 'transaction_ibfk_1';
SET FOREIGN_KEY_CHECKS = 1; # Включение проверок
 
INSERT INTO transaction (id, credit_card_id, company_id, user_id, lat, longitude, timestamp, amount, declined) 
VALUES('108B1D1D-5B23-A76C-55EF-C568E49A99DD', 'CcU-9999', 'b-9999', '9999', '829.999', '-117.999',NULL,'111.11', '0');

ALTER TABLE transaction
ADD FOREIGN KEY (company_id) REFERENCES company(id) ;

#Desde recursos humanos te solicitan eliminar la columna "pan" de la tabla credit_card. Recuerda mostrar el cambio realizado. 
SELECT * FROM credit_card; 
ALTER TABLE credit_card DROP COLUMN pan; 

#Удалить из таблицы транзакций все операции пользователя ID 000447FE-B650-4DCF-85DE-C7ED0EE1CAAD ВАЖНО: Строки содержат инфу связанные FK поэтому нужно удалять по-особенному 
SELECT * FROM Transaction WHERE ID = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';
DELETE FROM transaction WHERE ID = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';

#Представление для отдела маркетинга 
CREATE VIEW VistaMarketing AS
SELECT company.company_name, company.phone, company.country, 
        AVG(transaction.amount) as 'Average amount'
FROM company 
JOIN transaction ON company.id = transaction.company_id
GROUP BY company.company_name, company.phone, company.country
ORDER BY `Average amount` DESC;

DROP VIEW VistaMarketing;

#Отфильтровать компании из Германии для представления 
SELECT * FROM vistamarketing
WHERE country = 'Germany'; 

#Написать все запросы, которые выполнил коллега-долбоеб 
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

#Проверка значений поля юзер ид
SELECT DISTINCT user_id
FROM transaction
WHERE user_id IS NOT NULL
  AND user_id NOT IN (SELECT id FROM user);

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

