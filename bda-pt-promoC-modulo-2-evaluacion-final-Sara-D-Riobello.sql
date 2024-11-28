USE sakila;

-- 1. Selecciona todos los nombres de las películas sin que aparezcan duplicados.

SELECT DISTINCT title
FROM film;

-- 2. Muestra los nombres de todas las películas que tengan una clasificación de "PG-13".

SELECT title
FROM film
WHERE rating = 'PG-13';

-- 3. Encuentra el título y la descripción de todas las películas que contengan la palabra "amazing" en su descripción.

SELECT 
	title,
	description
FROM film
WHERE description LIKE '%amazing%' ;


-- 4. Encuentra el título de todas las películas que tengan una duración mayor a 120 minutos.

SELECT 
	title,
    length -- he querido añadirlo para mostrar la duración de cada uno
FROM film
WHERE length > 120;

-- 5. Recupera los nombres de todos los actores.

SELECT 
	first_name,
	last_name
FROM actor
ORDER BY first_name ASC;


-- 6. Encuentra el nombre y apellido de los actores que tengan "Gibson" en su apellido.

SELECT 
	first_name,
	last_name
FROM actor
WHERE last_name = 'Gibson';



-- 7. Encuentra los nombres de los actores que tengan un actor_id entre 10 y 20.

SELECT
	actor_id,
	first_name,
	last_name
FROM actor
WHERE actor_id BETWEEN 10 AND 20; -- Usamos BETWEEN en vez de >10 OR <20, ya que esta clausula los incluye y el código es más sencillo.


-- 8. Encuentra el título de las películas en la tabla film que no sean ni "R" ni "PG-13" en cuanto a su clasificación.

SELECT 
	title,
	rating
FROM film
WHERE rating NOT IN ('R', 'PG-13'); 

-- 9. Encuentra la cantidad total de películas en cada clasificación de la tabla film y muestra la clasificación junto con el recuento.

SELECT 
	rating,
	COUNT(film_id) 
FROM film
GROUP BY rating;


-- 10. Encuentra la cantidad total de películas alquiladas por cada cliente y muestra el ID del cliente, su nombre y apellido junto con la cantidad de películas alquiladas.

SELECT
	c.customer_id, -- seleccion de las  columnas de la tabla customers que quiero mostrar
	c.first_name,
	c.last_name,
	COUNT(rental.rental_id) AS total_rentals -- recuento del total de películas por cliente
FROM 
customer AS c  -- Abreviamos la tabla para hacerlo más fácil
LEFT JOIN -- unimos con la tabla rental para obtener la información
rental ON rental.customer_id = c.customer_id
GROUP BY c.customer_id;



-- 11. Encuentra la cantidad total de películas alquiladas por categoría y muestra el nombre de la categoría junto con el recuento de alquileres.
-- 1º. Buscamos las tablas que tienen la información: category, film_category y rental. 
-- 2º. Buscamos las columnas que tienen relación entre ellas y las unimos con INNER JOIN para evitar NULL
-- 3º. Hacemos recuento del total de alquileres a través de rental_id

SELECT
	c.name,
	COUNT(rental.rental_id) AS total_rentals -- Nombramos la columna con el recuento
FROM 
category AS c
INNER JOIN
film_category ON film_category.category_id = c.category_id
INNER JOIN
inventory ON inventory.film_id = film_category.film_id
INNER JOIN 
rental ON rental.inventory_id = inventory.inventory_id
GROUP BY c.name
ORDER BY total_rentals DESC; -- Orden descendiente para ver las categorías más alquiladas


-- 12. Encuentra el promedio de duración de las películas para cada clasificación de la tabla film y muestra la clasificación junto con el promedio de duración.

SELECT
	rating, 
	AVG(length) AS average_length 
FROM film
GROUP BY rating;


-- 13. Encuentra el nombre y apellido de los actores que aparecen en la película con title "Indian Love".

SELECT
	first_name,
	last_name
	-- f.title -- Puse esta columna para comprobar que salen en la película, pero he decidido no mostrarla
FROM actor
INNER JOIN film_actor AS fa
	ON fa.actor_id = actor.actor_id
INNER JOIN
film AS F
	ON f.film_id = fa.film_id
WHERE title = 'Indian Love';


-- 14. Muestra el título de todas las películas que contengan la palabra "dog" o "cat" en su descripción.

SELECT
	title,
	description
FROM film
WHERE description LIKE '%dog%' OR description  LIKE '%cat%';


-- 15. Encuentra el título de todas las películas que fueron lanzadas entre el año 2005 y 2010.

-- Salen todas las películas porque tienen el mismo año de lanzamiento. 

SELECT
	title,
	release_year
FROM film
WHERE release_year BETWEEN 2005 AND 2010;


-- 16. Encuentra el título de todas las películas que son de la misma categoría que "Family".
-- Aquí he visto que se puede hacer de dos formas, por lo que las he dejado: 
-- 1. SUBQUERY FILM --> FILM CATEGORY --> CATEGORY:

SELECT
title
FROM film
WHERE film_id IN
		(SELECT film_id FROM film_category WHERE category_id = -- Ponemos un igual para que nos muestre las películas que son de la misma categoría
				(SELECT category_id  FROM category WHERE name = 'Family'));
   
-- 2. Doble LEFT JOIN FILM <--> FILM CATEGORY <--> CATEGORY:   

SELECT f.title
FROM film AS f
LEFT JOIN film_category AS fc 
	ON f.film_id = fc.film_id
LEFT JOIN category c 
	ON fc.category_id = c.category_id
WHERE c.name = 'Family';



-- 17. Encuentra el título de todas las películas que son "R" y tienen una duración mayor a 2 horas en la tabla film.

SELECT
	title,
	rating,
	length
FROM film
WHERE rating = 'R' AND length > 120;

-- 18. Muestra el nombre y apellido de los actores que aparecen en más de 10 películas.
-- Tablas relacionadas = ACTOR - FILM ACTOR 

SELECT 
	first_name,
	last_name,
	COUNT(DISTINCT film_id) AS total_films -- Recuento del total de películas
FROM actor AS a
INNER JOIN film_actor AS fa
	ON fa.actor_id = a.actor_id
GROUP BY a.actor_id 
HAVING COUNT(DISTINCT film_id) > 10 -- Claúsula para seleccionar los actores que han aparecido en más de 10 películas 
ORDER BY first_name; 


-- 19. Hay algún actor o actriz que no apareca en ninguna película en la tabla film_actor.
-- Nuevamente hice dos opciones para obtener los resultados, que me salió el mismo: vacío.

-- OPCIÓN 1: Subquery
SELECT
	first_name,
	last_name
FROM actor
WHERE actor_id NOT IN (SELECT actor_id FROM film_actor) -- Primero comprobé con IN y luego añadí NOT IN, pero todos los actores aparecen en alguna película
GROUP BY actor.actor_id;

-- OPCIÓN 2: LEFT JOIN

SELECT
	first_name,
	last_name
FROM actor AS a
LEFT JOIN film_actor AS fa
	ON fa.actor_id = a.actor_id
WHERE film_id is NULL;


-- 20. Encuentra las categorías de películas que tienen un promedio de duración superior a 120 minutos y muestra el nombre de la categoría junto con el promedio de duración.
-- Mostrar= nombre categoria y AVG length
-- Tablas relacionadas = CATEGORY - FILM CATEGORY - FILM

SELECT
	c.name,
	AVG(length) AS average_length 
FROM category AS c
LEFT JOIN
film_category AS fc
	ON fc.category_id = c.category_id
LEFT JOIN 
film  
	ON film.film_id = fc.film_id
WHERE length > 120
GROUP BY c.name; 

      

-- 21. Encuentra los actores que han actuado en al menos 5 películas y muestra el nombre del actor junto con la cantidad de películas en las que han actuado.

SELECT 
	first_name,
	last_name,
	COUNT(DISTINCT film_id) AS total_films
FROM actor
INNER JOIN
film_actor 
	ON film_actor.actor_id = actor.actor_id
GROUP BY actor.actor_id 
HAVING COUNT(DISTINCT film_id) > 5;



-- 22. Encuentra el título de todas las películas que fueron alquiladas por más de 5 días. Utiliza una subconsulta para encontrar los rental_ids con una duración superior a 5 días y luego selecciona las películas correspondientes.
-- Resultado= titulo peliculas alquiladas + 5 dias

SELECT DISTINCT
	title
FROM film
WHERE film_id IN (
	SELECT film_id 
    FROM inventory 
    WHERE inventory_id IN(
		SELECT inventory_id
        FROM rental
        WHERE (DATEDIFF(DATE(return_date), DATE(rental_date)) > 5))); -- Cáculo de los días de alquiler mayores de 5
                    
                    
-- 23. Encuentra el nombre y apellido de los actores que no han actuado en ninguna película de la categoría "Horror". Utiliza una subconsulta para encontrar los actores que han actuado en películas de la categoría "Horror" y luego exclúyelos de la lista de actores.

SELECT
	first_name,
    last_name    
FROM actor
WHERE actor_id NOT IN (
		SELECT DISTINCT actor_id
        FROM film_actor
        INNER JOIN film_category 
			ON film_actor.film_id =  film_category.film_id
		INNER JOIN category
			ON film_category.category_id = category.category_id
        WHERE name = 'Horror');
        


-- 24. Encuentra el título de las películas que son comedias y tienen una duración mayor a 180 minutos en la tabla film.

SELECT
	title,
	length
	-- category.name (volví a ocultar la columna para comprobrar que el resultado era correcto)
FROM film
INNER JOIN 
film_category AS fc
	ON film.film_id = fc.film_id
INNER JOIN 
category AS c
	ON fc.category_id = c.category_id
WHERE name = 'Comedy' AND length > 180;


-- 25. Encuentra todos los actores que han actuado juntos en al menos una película. La consulta debe mostrar el nombre y apellido de los actores y el número de películas en las que han actuado juntos.
-- En este caso se usa el Self Join, ya que necesita ver el mismo dato de la tabla. 

-- No fui capaz de terminarlo, pero llegué a ver que con esto el id de los actores muestra el número de películas en las que aparecen juntos:

 SELECT   
	fa1.actor_id AS actor1_id,
    fa2.actor_id AS actor2_id, 
    COUNT(fa1.film_id) AS shared_films
FROM film_actor fa1
JOIN film_actor fa2 
	ON fa1.film_id = fa2.film_id
WHERE fa1.actor_id <> fa2.actor_id
GROUP BY fa1.actor_id, fa2.actor_id
HAVING COUNT(fa1.film_id) > 1;  


-- Y que con este muestra la relación de los actores, por lo que creo que uniendo las dos saldría el resultado, pero no he encontrado la manera de juntarlos para que salga correctamente:

SELECT
	a1.first_name AS actor1_name,
	a1.last_name AS actor1_surname,
	a2.first_name AS actor2_name,
	a2.last_name AS actor2_surname
FROM
actor AS a1
JOIN
actor AS a2 ON a1.actor_id <> a2.actor_id ; 

