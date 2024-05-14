-- Ejercicio de evaluación final del módulo 2

USE sakila;

-- 1. Selecciona todos los nombres de las películas sin que aparezcan duplicados.
SELECT DISTINCT title
FROM film;


-- 2. Muestra los nombres de todas las películas que tengan una clasificación de "PG-13".
-- Also select column 'rating' for verification.
SELECT title, rating
FROM film
WHERE rating = "PG-13";


-- 3. Encuentra el título y la descripción de todas las películas que contengan la palabra "amazing" en su descripción.
SELECT title, description
FROM film
WHERE description LIKE '%amazing%';


-- 4. Encuentra el título de todas las películas que tengan una duración mayor a 120 minutos.
-- Also select column 'length' for verification.
SELECT title, length
FROM film
WHERE length > 120;


-- 5. Recupera los nombres de todos los actores.
-- Just first name.
SELECT first_name
FROM actor;

-- Full name.
SELECT CONCAT(first_name, ' ', last_name) AS full_name
FROM actor;


-- 6. Encuentra el nombre y apellido de los actores que tengan "Gibson" en su apellido.
-- Using IN.
SELECT first_name, last_name
FROM actor
WHERE last_name IN ('Gibson');

-- Using LIKE.
SELECT first_name, last_name
FROM actor
WHERE last_name LIKE '%Gibson%';


-- 7. Encuentra los nombres de los actores que tengan un actor_id entre 10 y 20.
-- Using AND. Also select column 'actor_id' for verification.
SELECT actor_id, first_name
FROM actor
WHERE actor_id >=10 AND actor_id <=20;

-- Using BETWEEN. I also select the column 'actor_id' for verification.
SELECT actor_id, first_name
FROM actor
WHERE actor_id BETWEEN 10 AND 20;


-- 8. Encuentra el título de las películas en la tabla film que no sean ni "R" ni "PG-13" en cuanto a su clasificación.
-- Using NOT IN. Also select 'rating' for verification.
SELECT title, rating
FROM film
WHERE rating NOT IN ('R', 'PG-13');

-- Using NOT LIKE. Also select 'rating' for verification.
SELECT title, rating
FROM film
WHERE rating NOT LIKE 'R' AND rating NOT LIKE 'PG-13';


-- 9. Encuentra la cantidad total de películas en cada clasificación de la tabla film y muestra la clasificación junto con el recuento.
-- Count how many different film_id there are and group them by rating.
SELECT COUNT(DISTINCT film_id) AS amount_films, rating AS clasification
FROM film
GROUP BY rating;


-- 10. Encuentra la cantidad total de películas alquiladas por cada cliente y muestra el ID del cliente, su nombre y apellido junto con la cantidad de películas alquiladas.
/* TABLE rental --> customer_id, inventory_id
TABLE customer --> customer_id, first_name, last_name
TABLE inventory --> inventory_id, film_id
Note: whether if it counts by rental_id or by inventory_id it pulls the same result: how many times has each customer rented any film.
But this is not exactly what the exercise asks, because a customer could have rented the same film more than once, having therefore a higher number of rentals than rented films.
As an example, the customer_id 1 has rented the movies 317 and 663 twice, having a total number of rentals of 32 but only 30 different films rented.*/

		-- Discarded option as it counts the total of rentals.
		SELECT rental.customer_id, COUNT(DISTINCT rental.inventory_id) AS total_rented_films, customer.first_name, customer.last_name -- count inventory_id
		FROM rental
		INNER JOIN customer -- join rental & customer by customer_id
		ON rental.customer_id = customer.customer_id
		GROUP BY customer_id;

		-- Discarded option as it counts the total rental times.
		SELECT rental.customer_id, COUNT(DISTINCT rental.rental_id) AS total_rented_films, customer.first_name, customer.last_name -- count rental_id
		FROM rental
		INNER JOIN customer -- join rental & customer by customer_id
		ON rental.customer_id = customer.customer_id
		GROUP BY customer_id;

/* Choosen option. It counts the total amount of different films rented by each customer.
1. Count how many different film_id (from inventory) have been rented.
2. Join rental & inventory by inventory_id
3. Join inventory & customer by customer_id
4. Group by customer so it shows how may different films (COUNT) has rented each customer.
INNER JOIN and LEFT JOIN pull the same result.
*/
SELECT rental.customer_id, customer.first_name, customer.last_name, COUNT(DISTINCT inventory.film_id) AS total_rented_films
FROM rental
INNER JOIN inventory
ON rental.inventory_id = inventory.inventory_id
INNER JOIN customer
ON rental.customer_id = customer.customer_id
GROUP BY customer_id;

-- Shrinked code
SELECT r.customer_id, c.first_name, c.last_name, COUNT(DISTINCT i.film_id) AS total_rented_films
FROM rental AS r
INNER JOIN inventory AS i
ON r.inventory_id = i.inventory_id
INNER JOIN customer AS c
ON r.customer_id = c.customer_id
GROUP BY customer_id;


-- 11. Encuentra la cantidad total de películas alquiladas por categoría y muestra el nombre de la categoría junto con el recuento de alquileres.
-- INNER JOIN and LEFT JOIN pull the same result.
/* TABLE rental --> inventory_id
TABLE inventory --> inventory_id, film_id
TABLE film_category --> film_id, category_id
TABLE category --> category_id, name
1. Count how many different film_id have been rented
2. Join rental & inventory by inventory id
3. Join inventory & film_category by film_id
4. Join film_category & category by category_id
5. Group by category_id
*/
SELECT film_category.category_id, category.name, COUNT(inventory.film_id) AS total_rented_films
FROM rental
INNER JOIN inventory
ON rental.inventory_id = inventory.inventory_id
INNER JOIN film_category
ON inventory.film_id = film_category.film_id
INNER JOIN category
ON film_category.category_id = category.category_id
GROUP BY film_category.category_id;

-- Using LEFT JOIN instead of INNER JOIN. It pulls the same result.
SELECT film_category.category_id, category.name, COUNT(inventory.film_id) AS total_rented_films
FROM rental
LEFT JOIN inventory
ON rental.inventory_id = inventory.inventory_id
LEFT JOIN film_category
ON inventory.film_id = film_category.film_id
LEFT JOIN category
ON film_category.category_id = category.category_id
GROUP BY film_category.category_id
ORDER BY film_category.category_id;

-- Shrinked code
SELECT fc.category_id, c.name, COUNT(i.film_id) AS total_rented_films
FROM rental AS r
LEFT JOIN inventory AS i
ON r.inventory_id = i.inventory_id
LEFT JOIN film_category AS fc
ON i.film_id = fc.film_id
LEFT JOIN category AS c
ON fc.category_id = c.category_id
GROUP BY fc.category_id
ORDER BY fc.category_id;

-- 12. Encuentra el promedio de duración de las películas para cada clasificación de la tabla film y muestra la clasificación junto con el promedio de duración.
/* All the data is in table film.
1. Average of length, round it to 2 decimals.
2. Group by rating (clasification).
*/
SELECT rating AS clasification, ROUND(AVG(length),2) AS lenght_average
FROM film
GROUP BY rating;


-- 13. Encuentra el nombre y apellido de los actores que aparecen en la película con title "Indian Love".
/* TABLE film --> film_id
TABLE film_actor --> film_id, actor_id
TABLE actor --> actor_id, first_name, last_name
1. Join film & film_actor by film_id
2. Join film_actor & actor by actor_id
3. Condition title = 'Indian Love'
4. Alphabetical order by first_name 
*/
-- INNER JOIN and LEFT JOIN pull the same result.
SELECT a.first_name, a.last_name, f.title
FROM film AS f
INNER JOIN film_actor AS fa
ON f.film_id = fa.film_id
INNER JOIN actor AS a
ON fa.actor_id = a.actor_id
WHERE title = 'Indian Love'
ORDER BY first_name;

--
SELECT a.first_name, a.last_name, f.title
FROM film AS f
LEFT JOIN film_actor AS fa
ON f.film_id = fa.film_id
LEFT JOIN actor AS a
ON fa.actor_id = a.actor_id
WHERE title = 'Indian Love'
ORDER BY first_name;

-- Using a CTE
/* 1. Create de subquery:
1.1. Join film & film_actor by film_id
1.2. Condition title = 'Indian Love'
2. Join subquery & actor by actor_id
3. Alphabetical order by first_name
*/
WITH indian_love_id_actor AS
	(SELECT title, actor_id
	FROM film AS f
	INNER JOIN film_actor AS fa
	ON f.film_id = fa.film_id
	WHERE title = 'Indian Love')
SELECT first_name, last_name, title
FROM indian_love_id_actor AS i
INNER JOIN actor AS a
ON i.actor_id = a.actor_id
ORDER BY first_name;


-- 14. Muestra el título de todas las películas que contengan la palabra "dog" o "cat" en su descripción.
SELECT title, description
FROM film
WHERE description LIKE '%dog%' OR description LIKE '%cat%';


-- 15. ¿Hay algún actor o actriz que no apareca en ninguna película en la tabla film_actor?
/* 1. Select all the actor_id from film_actor (subquery). It pulls all the actor that have been in any film.
2. Select actor_id from actor if it is not in previous subquery.
*/
SELECT actor_id
FROM actor
WHERE actor_id NOT IN
	(SELECT actor_id FROM film_actor);
/* This query pulls a table with an unique value NULL, which means there is no actor_id in the table actor that it is not in table film_actor.
Therefore, the answer is no.*/

-- Using LEFT JOIN it gets the common values in both tables.
/* 1. Join actor & film_actor by actor_id.
2. Condition if actor_id in film_actor is NULL --> that means there is no common values with table actor
*/
SELECT a.actor_id, a.first_name, a.last_name
FROM actor AS a
LEFT JOIN film_actor AS fa
ON a.actor_id = fa.actor_id
WHERE fa.actor_id IS NULL;
/* This query pulls an empty table, which means there is no actor_id in the table actor that it is not in table film_actor.
Therefore, the answer is no.*/


-- 16. Encuentra el título de todas las películas que fueron lanzadas entre el año 2005 y 2010.
SELECT title, release_year
FROM film
WHERE release_year BETWEEN 2005 AND 2010;


-- 17. Encuentra el título de todas las películas que son de la misma categoría que "Family".
/* TABLE film --> title, film_id
TABLE film_category --> film_id, category_id
TABLE category --> category_id, name
1. Join film & film_category by film_id
2. Join film_category & category by category_id
*/
SELECT f.title, c.name
FROM film AS f
INNER JOIN film_category AS fc
ON f.film_id = fc.film_id
INNER JOIN category AS c
ON fc.category_id = c.category_id
WHERE c.name = 'Family';


-- 18. Muestra el nombre y apellido de los actores que aparecen en más de 10 películas.
/* TABLE film_actor --> film_id, actor_id
TABLE actor --> actor_id, first_name, last_name
1. Join film_actor & actor by actor_id
2. Group by actor_id.
3. Condition: the sum of each actor_id > 10.
4. Order by amount of films.
*/
-- INNER JOIN and LEFT JOIN pull the same result.
SELECT a.first_name, a.last_name, COUNT(DISTINCT fa.film_id) AS films_by_actor
FROM film_actor AS fa
INNER JOIN actor AS a
ON fa.actor_id = a.actor_id
GROUP BY fa.actor_id
HAVING COUNT(fa.actor_id)>10
ORDER BY films_by_actor DESC;

-- Using a CTE
/* 1. Create a subquery:
1.1. Count how may different film_id there are in film_actor.
1.2. Group by actor_id
1.3. Condition: the sum of each actor_id > 10.
2. Join subquery & actor by actor_id
3. Order by amount of films.
*/
WITH recurring_actors AS
-- 1: table film_actor: count film_id, group by actor_id, having >10
	(SELECT actor_id, COUNT(DISTINCT fa.film_id) AS films_by_actor
	FROM film_actor AS fa
	GROUP BY actor_id
	HAVING films_by_actor > 10)
-- 2: join with actors in order to get their names
SELECT a.first_name, a.last_name, films_by_actor
FROM recurring_actors
INNER JOIN actor AS a
ON recurring_actors.actor_id = a.actor_id
ORDER BY films_by_actor DESC;


-- 19. Encuentra el título de todas las películas que son "R" y tienen una duración mayor a 2 horas en la tabla film.
/* All the data is in table film */
SELECT title, rating, length
FROM film
WHERE rating = 'R' AND length >120;


-- 20. Encuentra las categorías de películas que tienen un promedio de duración superior a 120 minutos y muestra el nombre de la categoría junto con el promedio de duración.
/* TABLE film --> length, film_id
TABLE film_category --> film_id, category_id
TABLE category --> category_id, name
1. Join film & film_category by film_id.
2. Join film_category & category by category_id.
3. Group by category_id.
4. Condition: average length > 120 minutes.
*/
-- INNER JOIN and LEFT JOIN pull the same result.
SELECT c.name, AVG(f.length) AS average_length
FROM film AS f
INNER JOIN film_category AS fc
ON f.film_id = fc.film_id
INNER JOIN category AS c
ON fc.category_id = c.category_id
GROUP BY c.category_id
HAVING AVG(f.length) > 120;


-- 21. Encuentra los actores que han actuado en al menos 5 películas y muestra el nombre del actor junto con la cantidad de películas en las que han actuado.
/* TABLE film_actor --> film_id, actor_id
TABLE actor --> actor_id, first_name, last_name
1. Join film_actor & actor by actor_id.
2. Group by actor_id.
3. Condition: count actor_id >5.
4. Order by amount of films.
*/
-- INNER JOIN and LEFT JOIN pull the same result.
SELECT a.first_name, a.last_name, COUNT(DISTINCT film_id) AS films_by_actor
FROM film_actor AS fa
INNER JOIN actor AS a -- join film_actor & actor by actor_id
ON fa.actor_id = a.actor_id
GROUP BY fa.actor_id
HAVING COUNT(fa.actor_id)>5
ORDER BY films_by_actor DESC; -- order by films_by actor

-- Using CTE
/* 1. Create a subquery:
1.1. Count how many different film_id there are in film_actor.
1.2. Group by actor_id.
1.3. Condition: sum of films per actor > 5.
2. Join subquery & actor by actor_id.
3. Order by amount of films per actor.
*/
WITH recurring_actors AS
-- 1: table film_actor: count film_id, group by actor_id, having >5
	(SELECT fa.actor_id, COUNT(DISTINCT fa.film_id) AS films_by_actor
	FROM film_actor AS fa
	GROUP BY actor_id
	HAVING films_by_actor>5)
-- 2: join with actors
SELECT a.first_name, a.last_name, films_by_actor
FROM recurring_actors
INNER JOIN actor AS a
ON recurring_actors.actor_id = a.actor_id
ORDER BY films_by_actor DESC;


-- 22. Encuentra el título de todas las películas que fueron alquiladas por más de 5 días. Utiliza una subconsulta para encontrar los rental_ids con una duración superior a 5 días y luego selecciona las películas correspondientes.
/* TABLE rental --> rental_id, rental_date, return_date, inventory_id,
TABLE inventory --> inventory_id, film_id
TABLE film --> film_id, title
**DATEDIFF returns the difference between two date values --> DATEDIFF(end_date, start_date) AS result*/
/* 1. Create the subquery (rental days > 5):
1. Rental days = return_date - rental date.
1.1. Condition: rental days > 5.
*/
SELECT rental_id, DATEDIFF(return_date, rental_date) AS rental_days
FROM rental
WHERE DATEDIFF(return_date, rental_date) >5
ORDER BY rental_days;

/* 2. Create the joins and combine them with the subquery:
2.1 Select different titles, so it will not pull duplicates.
2.2. Join film & inventory by film_id.
2.3. Join inventory & rental by inventory_id.
3. Condition: if the rental_id is in the subquery.
*/
SELECT DISTINCT f.title
FROM film AS f
INNER JOIN inventory AS i
ON f.film_id = i.film_id
INNER JOIN rental AS r
ON i.inventory_id = r.inventory_id
WHERE r.rental_id IN
	(SELECT rental_id
    FROM rental
    WHERE DATEDIFF(return_date, rental_date) >5);


-- 23. Encuentra el nombre y apellido de los actores que no han actuado en ninguna película de la categoría "Horror". Utiliza una subconsulta para encontrar los actores que han actuado en películas de la categoría "Horror" y luego exclúyelos de la lista de actores.
/* TABLE category --> name, category_id
TABLE film_category --> category_id, film_id
TABLE film --> film_id, 
TABLE film_actor --> film_id, actor_id
TABLE actor --> actor_id, first_name, last_name
*/
/* 1. Create the subquery (will pull the actors that has been in 'Horror' movies):
1.1.  Join film_actor & film_category by film_id.
1.2. Join film_category & category by category_id.
1.3. Condition: category name = 'Horror'.
*/
SELECT fa.actor_id, c.name  -- also select c.name for verification
FROM film_actor AS fa
INNER JOIN film_category AS fc
ON fa.film_id = fc.film_id
INNER JOIN category AS c
ON fc.category_id = c.category_id
WHERE c.name = 'Horror';

/*2. Create the main SELECT FROM table actor.
2.1. Condition: actor_id is not in the previous subquery (has not been in 'Horror' movies).
*/
SELECT a.actor_id, a.first_name, a.last_name
FROM actor AS a
WHERE a.actor_id NOT IN
	(SELECT fa.actor_id
	FROM film_actor AS fa
	INNER JOIN film_category AS fc
	ON fa.film_id = fc.film_id
	INNER JOIN category AS c
	ON fc.category_id = c.category_id
	WHERE c.name = 'Horror');


-- 24. BONUS: Encuentra el título de las películas que son comedias y tienen una duración mayor a 180 minutos en la tabla film.
/* TABLE film --> title, length, film_id
TABLE film_categoty --> film_id, category_id
TABLE category --> category_id, name
1. Join film & film_category by film_id.
2. Join film_category & category by category_id.
3. Condition: category name is 'Comedy' and film length is > 180.
*/
SELECT f.title, c.name, f.length
FROM film AS f
INNER JOIN film_category AS fc -- join film & film_category by film_id
ON f.film_id = fc.film_id
INNER JOIN category AS c -- join with category by category_id
ON fc.category_id = c.category_id
WHERE c.name = 'Comedy' AND f.length > 180;


-- 25. BONUS: Encuentra todos los actores que han actuado juntos en al menos una película. La consulta debe mostrar el nombre y apellido de los actores y el número de películas en las que han actuado juntos.
/* SELF JOIN TO COMPARE A TABLE WITH ITSELF AND SELECT PAIRS. USE AS FOR EACH INSTANCE.
TABLE actor --> actor_id, first_name, last_name
TABLE film_actor --> actor_id, film_id */

-- 1. Create FROM actor and JOINS
-- 1.1 CROSS JOIN will bring all the possible comibnations of the selected columns
-- 1.2 INNER JOIN film_actor, join tables actor & film_actor, for actor1, by actor_id
-- 1.3 INNER JOIN film_actor, join tables actor & film_actor, for actor2, by actor_id
-- 1.3.1 AND also join film_actor.film_id for both actors
-- 2. SELECT
-- 2.1 SELECT both actor's names (discarded actor_id because it is easier to read seeing the names)
-- 2.2 SELECT COUNT how many different movies does actor1 have
-- 3. WHERE avoids that the same pair is checked twice
-- 4. GROUP BY if both actors are present, ignoring those films without actor1 or actor 2
-- 5. HAVING takes de 2.2
-- *Note: there are some actors that are registered twice by name, but once by id, for example Susan Davis has the id 101 and 110

-- This pulls 10.385 results. It counts by actor's name.
SELECT CONCAT(a1.first_name, ' ', a1.last_name) AS actor1,
	   CONCAT(a2.first_name, ' ', a2.last_name) AS actor2,
	   COUNT(DISTINCT fa1.film_id) AS amount_films
FROM actor AS a1 CROSS JOIN actor a2
INNER JOIN film_actor AS fa1 ON a1.actor_id = fa1.actor_id
INNER JOIN film_actor AS fa2 ON a2.actor_id = fa2.actor_id AND fa1.film_id = fa2.film_id
WHERE a1.actor_id < a2.actor_id
GROUP BY actor1, actor2
HAVING amount_films > 0;

-- This pulls 10.434 results. It counts by actor's id.
SELECT CONCAT(a1.first_name, ' ', a1.last_name) AS actor1, CONCAT(a2.first_name, ' ', a2.last_name) AS actor2,
	(SELECT COUNT(*)
	FROM film_actor AS fa1
    INNER JOIN film_actor AS fa2
    ON fa1.film_id = fa2.film_id
	WHERE fa1.actor_id = a1.actor_id AND fa2.actor_id = a2.actor_id) AS common_films
FROM actor AS a1
INNER JOIN actor AS a2
ON a1.actor_id < a2.actor_id
GROUP BY a1.actor_id, a2.actor_id
HAVING common_films >0
ORDER BY actor1, actor2;

-- ------------------------------
-- Previous steps
-- This pulls 40.000 results but it relates actor1 with actor1
SELECT CONCAT(a1.first_name, ' ', a1.last_name) AS actor1, CONCAT(a2.first_name, ' ', a2.last_name) AS actor2,
	(SELECT COUNT(*)
	FROM film_actor AS fa1, film_actor AS fa2
	WHERE fa1.actor_id = a1.actor_id AND fa2.actor_id = a2.actor_id) AS common_films
FROM actor AS a1, actor AS a2
GROUP BY a1.actor_id, a2.actor_id
ORDER BY actor1, actor2;

-- This pulls 19.900 results but also pulls those combinations without any common films
SELECT CONCAT(a1.first_name, ' ', a1.last_name) AS actor1, CONCAT(a2.first_name, ' ', a2.last_name) AS actor2,
	(SELECT COUNT(*)
	FROM film_actor AS fa1
    INNER JOIN film_actor AS fa2
    ON fa1.film_id = fa2.film_id
	WHERE fa1.actor_id = a1.actor_id AND fa2.actor_id = a2.actor_id) AS common_films
FROM actor AS a1
INNER JOIN actor AS a2
ON a1.actor_id < a2.actor_id
GROUP BY a1.actor_id, a2.actor_id
ORDER BY actor1, actor2;


