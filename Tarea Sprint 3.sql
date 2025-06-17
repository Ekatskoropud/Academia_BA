#Запрос для создания новой таблицы
CREATE TABLE IF NOT EXISTS credit_card (
	id VARCHAR(15) PRIMARY KEY,
	iban VARCHAR(100),
	pan INT,
	pin INT,
	cvv INT,
	expiring_date TIMESTAMP
);

 #FK для credit_card_id VARCHAR(15) из таблицы транзакций, 
 #тип связи 1 к 1  FK для credit_card_id VARCHAR(15) из таблицы транзакций  -- credit_card_id VARCHAR(15) из таблицы транзакций 
 #Следовательно нужно добавить в таблицу транзакций новый FOREIGN KEY (credit_card_id) REFERENCES credit_card(id) 
 
 #Consulta para añadir FK a la tabla transaction
ALTER TABLE transaction
ADD FOREIGN KEY (credit_card_id) REFERENCES credit_card(id);

#Заменить iban на правильный в таблице credit_card. El departamento de Recursos Humanos ha identificado un error en el número de cuenta asociado a su tarjeta de crédito con ID CcU-2938. La información que debe mostrarse para este registro es: TR323456312213576817699999. Recuerda mostrar que el cambio se realizó.
UPDATE credit_card SET iban = 'TR323456312213576817699999' WHERE id = 'CcU-2938';

#En la tabla "transaction" ingresa un nuevo usuario con la siguiente información
INSERT INTO transaction (id, credit_card_id, company_id, user_id, lat, longitude, timestamp, amount, declined) VALUES('108B1D1D-5B23-A76C-55EF-C568E49A99DD', 'CcU-9999', 'b-9999', '9999', '829.999', '-117.999','111.11', '0');

#Desde recursos humanos te solicitan eliminar la columna "pan" de la tabla credit_card. Recuerda mostrar el cambio realizado. 
ALTER TABLE credit_card DROP COLUMN pan; 
