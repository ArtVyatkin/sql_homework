CREATE OR REPLACE FUNCTION place_order(
    customer_name customers.name%TYPE,
    price orders.price%TYPE,
    departure_address orders.departure_address%TYPE,
    arrival_address orders.arrival_address%TYPE,
    payment_method orders.payment_method%TYPE,
    arrival_time_to_customer TIMESTAMP,
    car_license_plate cars.license_plate%TYPE DEFAULT NULL
) RETURNS INT AS
$$
DECLARE
    new_order_id orders.id%TYPE;
    cur_time     TIMESTAMP;
    car_status   orders.status%TYPE;
BEGIN
    car_status := (SELECT status
                   FROM orders
                   WHERE car = car_license_plate
                     AND booking_time = (
                       SELECT MAX(booking_time)
                       FROM orders
                       WHERE car = car_license_plate));

    IF car_status NOT IN ('завершен', 'отменен') THEN
        RAISE EXCEPTION 'Car % unavailable.', car_license_plate;
    END IF;
    cur_time := NOW();

    INSERT INTO orders (arrival_address, departure_address, price, payment_method, customer, car, booking_time,
                        arrival_time_to_client)
    VALUES (place_order.arrival_address, place_order.departure_address, place_order.price, place_order.payment_method,
            customer_name, car_license_plate, cur_time, arrival_time_to_customer)
    RETURNING id INTO new_order_id;

    INSERT INTO logs (order_id, time) VALUES (new_order_id, cur_time);

    RETURN new_order_id;
END;
$$ LANGUAGE plpgsql;


SELECT place_order('Никита', 363.65, 'Василеостровский', 'Фрунзенский', 'карта', '2021-05-27 19:00:00');
