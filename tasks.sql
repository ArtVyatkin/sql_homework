-- 1. Выбор а/м с числом мест >= 10
SELECT * FROM cars WHERE number_of_seats >= 10;

-- 2. Выбор легковых а/м

SELECT *
FROM cars
WHERE type IN ('седан', 'лимузин', 'кабриолет', 'универсал', 'хэтчбек', 'пикап');

-- 3. Выбор отмененных заказов

SELECT *
FROM orders
WHERE status = 'отменен';

-- 4. Выбор заказов, оплаченных кредитной картой

SELECT *
FROM orders
WHERE payment_method = 'карта';

-- 5. Выбор заказов, сделанных определенным клиентом

SELECT *
FROM orders
WHERE customer = 'Никита';

-- 6. Выбор клиентов, отменявших свои заказы

SELECT DISTINCT customer
FROM orders
WHERE status = 'отменен';

-- 7. Подсчет прибыли (подсчет по неотмененным заказам)

SELECT SUM(price)
FROM orders
WHERE status = 'завершен';

-- 8. Подсчет общего числа выполненных заказов

SELECT COUNT(*)
FROM orders
WHERE status = 'завершен';

-- 9. Список наиболее занятых водителей

SELECT driver, COUNT(*) as number_of_orders
FROM orders
         JOIN cars ON orders.car = cars.license_plate
GROUP BY driver
ORDER BY number_of_orders DESC;

-- Кол-во заказов больше одного

-- 10. Выбор постоянных клиентов (не менее 5 выполненных заказов)

SELECT customer
FROM orders
WHERE status = 'завершен'
GROUP BY customer HAVING COUNT(*) >= 5;