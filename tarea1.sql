USE transactions;

/*
Nivel 1

Ejercicio 2
Utilizando JOIN realizarás las siguientes consultas:
Listado de los países que están generando ventas.
Desde cuántos países se generan las ventas.
Identifica a la compañía con la mayor media de ventas.
*/


#Listado de los países que están generando ventas.
SELECT DISTINCT c.country AS total_paises
FROM transaction t
INNER JOIN company c
  ON t.company_id = c.id; 


#Desde cuántos países se generan las ventas.
SELECT COUNT(DISTINCT c.country) AS total_paises
FROM transaction t
INNER JOIN company c
  ON t.company_id = c.id; #compañias que están en la tabla company y en la tabla transaction

#Identifica a la compañía con la mayor media de ventas.
SELECT c.company_name, ROUND(AVG(t.amount),2) as media_ventas  
FROM transaction t
INNER JOIN company c ON t.company_id = c.id
GROUP BY c.company_name
ORDER BY media_ventas DESC
LIMIT 1;

/*
Ejercicio 3
Utilizando sólo subconsultas (sin utilizar JOIN):
Muestra todas las transacciones realizadas por empresas de Alemania.
Lista las empresas que han realizado transacciones por un amount superior a la media de todas las transacciones.
Eliminarán del sistema las empresas que carecen de transacciones registradas, entrega el listado de estas empresas.
*/

# Muestra todas las transacciones realizadas por empresas de Alemania.
SELECT t.id, t.company_id, t.amount, t.declined
FROM transaction t
WHERE EXISTS (
  SELECT 1
  FROM company c
  WHERE c.id = t.company_id
    AND c.country = 'Germany'
);

#Lista las empresas que han realizado transacciones por un amount superior a la media de todas las transacciones.		
SELECT DISTINCT c.company_name
FROM company c
WHERE EXISTS (
    SELECT 1
    FROM transaction t
    WHERE c.id = t.company_id AND t.amount > (SELECT AVG(amount) FROM transaction)
);

#Eliminarán del sistema las empresas que carecen de transacciones registradas, entrega el listado de estas empresas.
SELECT c.company_name
FROM company c
WHERE c.id NOT IN (
    SELECT t.company_id
    FROM transaction t
);

/*
Nivel 2
Ejercicio 1
Identifica los cinco días que se generó la mayor cantidad de ingresos en la empresa por ventas. 
Muestra la fecha de cada transacción junto con el total de las ventas.
*/
SELECT DATE(t.timestamp) AS dia, SUM(t.amount) AS ventas_dia  
FROM transaction t
GROUP BY dia
ORDER BY ventas_dia DESC
LIMIT 5;

#Ejercicio 2 
#¿Cuál es la media de ventas por país? Presenta los resultados ordenados de mayor a menor medio.

SELECT c.country AS país, ROUND(AVG(t.amount),2) AS media_ventas
FROM company c
INNER JOIN transaction t ON c.id =t.company_id
GROUP BY c.country
ORDER BY  media_ventas DESC;

/*
Ejercicio 3: En tu empresa, se plantea un nuevo proyecto para lanzar algunas campañas publicitarias 
para hacer competencia a la compañía “Non Institute”. 
Para ello, te piden la lista de todas las transacciones realizadas por empresas que están ubicadas en el mismo país
que esta compañía.

Muestra el listado aplicando JOIN y subconsultas.
Muestra el listado aplicando solo subconsultas.
*/

#Muestra el listado aplicando JOIN y subconsultas.
SELECT c.id AS id_company , t.id AS id_transaction, c.company_name, c.country
FROM company c
INNER JOIN transaction t ON c.id = t.company_id
WHERE c.country IN ( SELECT c.country
					FROM company c
					WHERE c.company_name = 'Non Institute');

#Muestra el listado aplicando solo subconsultas.
SELECT t.id AS id_transaction 
FROM transaction t
WHERE EXISTS (SELECT 1 #subconsulta1
		FROM company c
        WHERE (c.id = t.company_id 
				AND c.country IN ( SELECT c.country #subconsulta2
									FROM company c
									WHERE c.company_name = 'Non Institute'
								  )
			   )
			  ); 

/*
Nivel 3
Ejercicio 1
Presenta el nombre, teléfono, país, fecha y amount, 
de aquellas empresas que realizaron transacciones con un valor comprendido entre 350 y 400 euros 
y en alguna de estas fechas: 29 de abril de 2015, 20 de julio de 2018 y 13 de marzo de 2024. 
Ordena los resultados de mayor a menor cantidad.
*/

SELECT c.company_name, c.phone, c.country, DATE(t.timestamp) AS fecha, t.amount
FROM company c
INNER JOIN transaction t ON c.id = t.company_id
WHERE t.amount BETWEEN 351 AND 400 
	AND DATE(t.timestamp) IN ('2015-04-29', '2018-07-20', '2024-03-13')
ORDER BY t.amount DESC;

/*
Ejercicio 2 
Necesitamos optimizar la asignación de los recursos y dependerá de la capacidad operativa que se requiera, 
por lo que te piden la información sobre la cantidad de transacciones que realizan las empresas, 
pero el departamento de recursos humanos es exigente y quiere 
un listado de las empresas en las que especifiques si tienen más de 400 transacciones o menos.
*/

SELECT c.company_name, COUNT(t.id) as cant_transacciones, CASE 
           WHEN COUNT(t.id) > 400 THEN 'Sí'  
           ELSE 'No' 
       END AS mas_400_transacciones
FROM transaction t
INNER JOIN company c ON c.id=t.company_id
GROUP BY c.id
ORDER BY cant_transacciones DESC;