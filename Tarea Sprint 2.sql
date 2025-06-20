Select * from transaction;
Select * from company;

#Llistat dels països que estan generant vendes
SELECT country FROM company 
INNER JOIN transaction ON company.id = transaction.company_id 
GROUP BY country; 

#Des de quants països es generen les vendes
SELECT COUNT(DISTINCT country) FROM company 
INNER JOIN transaction ON company.id=transaction.company_id;

#Identifica a la compañía con la mayor media de ventas
SELECT company.company_name, AVG(transaction.amount) as 'media ventas' FROM company
JOIN transaction ON company.id = transaction.company_id
GROUP BY company_name
ORDER BY 'media ventas' DESC 
LIMIT 1;

#Mostra totes les transaccions realitzades per empreses d'Alemanya.
SELECT * FROM transaction WHERE company_id IN 
(SELECT ID FROM company WHERE country ='Germany');
	 
#Llista les empreses que han realitzat transaccions per un amount superior a la mitjana de totes les transaccions.
SELECT * FROM company WHERE ID IN 
(SELECT company_id FROM transaction 
WHERE amount > (SELECT AVG(amount) FROM transaction));

#Eliminaran del sistema les empreses que no tenen transaccions registrades, entrega el llistat d'aquestes empreses.
#INSERT INTO company (id, company_name, phone, email, country, website) VALUES (        'b-0000', 'Ac Fermentum Incorporated', '06 85 56 52 33', 'donec.porttitor.tellus@yahoo.net', 'Germany', 'https://instagram.com/site');

SELECT * FROM company WHERE ID NOT IN (SELECT distinct company_id FROM transaction);

#Identifica els cinc dies que es va generar la quantitat més gran d'ingressos a l'empresa per vendes. Mostra la data de cada transacció juntament amb el total de les vendes.
SELECT DATE(timestamp) as 'Fecha', SUM(amount) AS 'Total' FROM transaction
GROUP BY Fecha
ORDER BY Total DESC 
LIMIT 5; 

#Quina és la mitjana de vendes per país? Presenta els resultats ordenats de major a menor mitjà.

SELECT company.country, AVG(transaction.amount) as 'mitjana' FROM company
JOIN transaction ON company.id=transaction.company_id
GROUP BY country
order by mitjana DESC;

#En la teva empresa, es planteja un nou projecte per a llançar algunes campanyes publicitàries per a fer competència a la companyia "Non Institute". Per a això, et demanen la llista de totes les transaccions realitzades per empreses que estan situades en el mateix país que aquesta companyia
#SELECT country FROM company WHERE company_name LIKE 'Non Institute'; #UK

SELECT * FROM transaction 
WHERE company_ID NOT IN (SELECT ID FROM company WHERE company_name ='Non Institute')
AND company_ID IN (SELECT ID FROM company WHERE country LIKE (SELECT country FROM company WHERE company_name ='Non Institute')); 

SELECT transaction.*, company.company_name FROM transaction 
JOIN company ON transaction.company_id=company.id
WHERE company.country =(SELECT country FROM company WHERE company_name ='Non Institute') AND company_name != 'Non Institute';

#Presenta el nom, telèfon, país, data i amount, d'aquelles empreses que van realitzar transaccions amb un valor comprès entre 350 i 400 euros i en alguna d'aquestes dates: 29 d'abril del 2015, 20 de juliol del 2018 i 13 de març del 2024. Ordena els resultats de major a menor quantitat.
SELECT company.company_name, company.phone, company.country, SUM(transaction.amount) as 'Total' FROM company
JOIN transaction ON company.id=transaction.company_id
WHERE DATE(timestamp) IN ('2015-04-29','2018-07-20','2024-03-13')
GROUP BY company.company_name, company.phone, company.country
HAVING Total BETWEEN 350 AND 400
ORDER BY Total DESC;

#Necessitem optimitzar l'assignació dels recursos i dependrà de la capacitat operativa que es requereixi, per la qual cosa et demanen la informació sobre la quantitat de transaccions que realitzen les empreses, però el departament de recursos humans és exigent i vol un llistat de les empreses on especifiquis si tenen més de 400 transaccions o menys.
SELECT company.company_name, COUNT(transaction.id) as 'Número de transacciones',CASE 
  WHEN COUNT(transaction.id) > 400 THEN 'Más de 400'
  ELSE 'Menos de 400'
END as categoria
FROM company
JOIN transaction ON company.id=transaction.company_id
GROUP BY company.company_name;