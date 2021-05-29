CREATE OR REPLACE FUNCTION get_available_cars(
    address_to orders.arrival_address%TYPE
)
    RETURNS TABLE
            (
                license_plate  cars.license_plate%TYPE,
                driver         drivers.name%TYPE,
                time_to_arrive INTERVAL
            )
AS
$$
DECLARE
    starting_address_for_cars customers.address%TYPE := 'Петродворцовый';
BEGIN
    DROP TABLE IF EXISTS result;
    DROP TABLE IF EXISTS cars_and_their_addresses;

    CREATE TEMP TABLE cars_and_their_addresses AS (
        WITH logs_and_cars AS (
            SELECT cars.license_plate,
                   logs."time",
                   logs.status_change_id,
                   orders.arrival_address
            FROM cars
                     LEFT JOIN orders ON cars.license_plate = orders.car
                     LEFT JOIN logs ON orders.id = logs.order_id
            WHERE cars.driver IS NOT NULL
        ),
             max_times AS (
                 SELECT logs_and_cars.license_plate,
                        max(logs_and_cars."time") AS max_time
                 FROM logs_and_cars
                 GROUP BY logs_and_cars.license_plate
             ),
             cars_and_approximate_addresses AS (
                 SELECT max_times.license_plate,
                        logs_and_cars.status_change_id,
                        logs_and_cars.arrival_address
                 FROM max_times
                          LEFT JOIN logs_and_cars ON logs_and_cars."time" = max_times.max_time AND
                                                     logs_and_cars.license_plate = max_times.license_plate
             )
        SELECT cars.driver,
               cars.license_plate,
               cars_and_approximate_addresses.arrival_address AS current_address
        FROM cars_and_approximate_addresses
                 JOIN cars ON cars.license_plate = cars_and_approximate_addresses.license_plate
        WHERE cars_and_approximate_addresses.status_change_id = 3
           OR cars_and_approximate_addresses.status_change_id = 4
           OR cars_and_approximate_addresses.status_change_id IS NULL
    );

    UPDATE cars_and_their_addresses
    SET current_address = starting_address_for_cars
    WHERE current_address IS NULL;

    CREATE TEMP TABLE result AS (
        WITH avg_times AS (SELECT orders.departure_address, AVG(right_logs.time - left_logs.time) AS lead_time
                           FROM orders
                                    JOIN logs right_logs on orders.id = right_logs.order_id
                                    JOIN logs left_logs on orders.id = left_logs.order_id
                           WHERE arrival_address = address_to
                             AND right_logs.status_change_id = 3
                             AND left_logs.status_change_id = 2
                           GROUP BY orders.departure_address)
        SELECT cars_and_their_addresses.license_plate,
               lead_time as time_to_arrive,
               cars_and_their_addresses.driver,
               cars_and_their_addresses.current_address
        FROM cars_and_their_addresses
                 LEFT JOIN avg_times ON avg_times.departure_address = current_address
    );

    UPDATE result SET time_to_arrive = INTERVAL '0' WHERE result.current_address = address_to;

    RETURN query SELECT result.license_plate, result.driver, result.time_to_arrive
                 FROM result
                 ORDER BY time_to_arrive;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM get_available_cars('Пушкинский')