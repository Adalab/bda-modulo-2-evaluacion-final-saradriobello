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

SELECT title
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
WHERE actor_id > 10 AND actor_id < 20;


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
customer.customer_id,
customer.first_name,
customer.last_name,
COUNT(rental.rental_id) AS total_rentals
FROM 
customer
LEFT JOIN
rental ON rental.customer_id = customer.customer_id
GROUP BY customer.customer_id;



-- 11. Encuentra la cantidad total de películas alquiladas por categoría y muestra el nombre de la categoría junto con el recuento de alquileres.
-- 1. total de películas alquiladas por categoría
-- 2. nombre de la categoría
-- 3. recuento de alquileres

SELECT
category.name,
COUNT(rental.rental_id) AS total_rentals
FROM 
category
LEFT JOIN
film_category ON film_category.category_id = category.category_id
LEFT JOIN
inventory ON inventory.film_id = film_category.film_id
LEFT JOIN 
rental ON rental.inventory_id = inventory.inventory_id
GROUP BY category.name;


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
-- film.title
FROM actor
left JOIN 
film_actor ON film_actor.actor_id = actor.actor_id
INNER JOIN
film ON film.film_id = film_actor.film_id
WHERE title = 'Indian Love';


-- 14. Muestra el título de todas las películas que contengan la palabra "dog" o "cat" en su descripción.

SELECT
title,
description
FROM film
WHERE description LIKE '%dog%' OR description  LIKE '%cat%'
GROUP BY title;


-- 15. Encuentr a el título de todas las películas que fueron lanzadas entre el año 2005 y 2010.
SELECT
title,
release_year
FROM film
WHERE release_year BETWEEN 2005 AND 2010;


-- 16. Encuentra el título de todas las películas que son de la misma categoría que "Family".
-- SUBQUERY FILM - FILM CATEGORY - CATEGORY

SELECT
title
FROM film
WHERE film_id IN
		(SELECT film_id FROM film_category WHERE category_id =
				(SELECT category_id  FROM category WHERE name = 'Family'));



-- 17. Encuentra el título de todas las películas que son "R" y tienen una duración mayor a 2 horas en la tabla film.

SELECT
title,
rating,
length
FROM film
WHERE rating = 'R' AND length > 120;

-- 18. Muestra el nombre y apellido de los actores que aparecen en más de 10 películas.
-- ACTOR - FILM ACTOR 

SELECT 
first_name,
last_name,
COUNT(DISTINCT film_id) AS total_films
FROM actor
INNER JOIN
film_actor ON film_actor.actor_id = actor.actor_id
GROUP BY actor.actor_id 
HAVING COUNT(DISTINCT film_id) > 10;


-- 19. Hay algún actor o actriz que no apareca en ninguna película en la tabla film_actor.

SELECT
first_name,
last_name
FROM actor
WHERE actor_id NOT IN (SELECT actor_id FROM film_actor)
GROUP BY actor.actor_id;

SELECT
first_name,
last_name
FROM actor
LEFT JOIN
film_actor on film_actor.actor_id = actor.actor_id
WHERE film_id is NULL;


-- 20. Encuentra las categorías de películas que tienen un promedio de duración superior a 120 minutos y muestra el nombre de la categoría junto con el promedio de duración.
-- Mostrar= nombre categoria y AVG length

SELECT
category.name,
AVG(length) AS average_length
FROM category 
LEFT JOIN
film_category ON film_category.category_id = category.category_id
LEFT JOIN 
film ON film.film_id = film_category.film_id
WHERE length > 120
GROUP BY category.name;

      

-- 21. Encuentra los actores que han actuado en al menos 5 películas y muestra el nombre del actor junto con la cantidad de películas en las que han actuado.

SELECT 
first_name,
last_name,
COUNT(DISTINCT film_id) AS total_films
FROM actor
INNER JOIN
film_actor ON film_actor.actor_id = actor.actor_id
GROUP BY actor.actor_id 
HAVING COUNT(DISTINCT film_id) > 5;



-- 22. Encuentra el título de todas las películas que fueron alquiladas por más de 5 días. Utiliza una subconsulta para encontrar los rental_ids con una duración superior a 5 días y luego selecciona las películas correspondientes.
-- Resultado= titulo peliculas alquiladas + 5 dias

SELECT DISTINCT
	title
FROM 
	film
WHERE film_id IN (
	SELECT film_id 
    FROM inventory 
    WHERE inventory_id IN(
		SELECT inventory_id
        FROM rental
        WHERE (DATEDIFF(DATE(return_date), DATE(rental_date)) > 5)));
                    
                    
-- 23. Encuentra el nombre y apellido de los actores que no han actuado en ninguna película de la categoría "Horror". Utiliza una subconsulta para encontrar los actores que han actuado en películas de la categoría "Horror" y luego exclúyelos de la lista de actores.

SELECT
	first_name,
    last_name    
FROM actor
WHERE actor_id NOT IN (
		SELECT DISTINCT actor_id
        FROM film_actor
        INNER JOIN film_category ON film_actor.film_id =  film_category.film_id
		INNER JOIN category ON film_category.category_id = category.category_id
        WHERE name = 'Horror');
        


-- 24. Encuentra el título de las películas que son comedias y tienen una duración mayor a 180 minutos en la tabla film.

SELECT
	title,
	length
	-- category.name
FROM film
INNER JOIN film_category ON film.film_id = film_category.film_id
INNER JOIN category ON film_category.category_id = category.category_id
WHERE name = 'Comedy' AND length > 180;


-- 25. Encuentra todos los actores que han actuado juntos en al menos una película.
--  La consulta debe mostrar el nombre y apellido de los actores y el número de películas en las que han actuado juntos.


SELECT
first_name,
last_name,
film.title AS film_title
FROM
actor
LEFT JOIN
film_actor ON actor.actor_id = film_actor.actor_id
LEFT JOIN
film ON film_actor.film_id = film.film_id
GROUP BY film.title
HAVING COUNT(DISTINCT film_id) > 1;




