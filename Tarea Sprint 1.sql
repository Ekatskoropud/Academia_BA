Select * from transaction;
Select * from company;

#Llistat dels països que estan generant vendes
SELECT country FROM company 
INNER JOIN transaction on company.id=transaction.company_id 
WHERE declined = 0
GROUP BY country; 

#Des de quants països es generen les vendes
SELECT COUNT(DISTINCT country) FROM company 
INNER JOIN transaction ON company.id=transaction.company_id
WHERE declined = 0;

#Mostra totes les transaccions realitzades per empreses d'Alemanya.
SELECT * FROM transaction where company_id in 
(SELECT ID FROM company WHERE country ='Germany');
	 
#Llista les empreses que han realitzat transaccions per un amount superior a la mitjana de totes les transaccions.
SELECT * FROM company WHERE ID IN 
(SELECT company_id FROM transaction 
Where amount > (SELECT AVG(amount) FROM transaction));

#Eliminaran del sistema les empreses que no tenen transaccions registrades, entrega el llistat d'aquestes empreses.
SELECT * FROM company WHERE ID IN (SELECT company_id FROM transaction WHERE declined=1 XOR declined=0);
