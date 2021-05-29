CREATE TYPE car_data_for_before_order_adding AS
(
    license_plate  CHAR(6),
    driver         VARCHAR(15),
    time_to_arrive INTERVAL
);

CREATE FUNCTION before_order_adding() RETURNS TRIGGER
    LANGUAGE plpgsql
AS
$$
DECLARE
    available_car_data car_data_for_before_order_adding;
BEGIN
    IF NEW.car IS NULL THEN
        SELECT license_plate, driver, time_to_arrive
        INTO available_car_data
        FROM get_available_cars(NEW.departure_address)
        LIMIT 1;

        IF available_car_data IS NULL OR
           available_car_data.time_to_arrive IS NULL OR
           available_car_data.time_to_arrive + NEW.booking_time > NEW.arrival_time_to_client THEN
            RAISE EXCEPTION 'Cars unavailable.';
        END IF;
        NEW.car := available_car_data.license_plate;
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER on_order_adding
    BEFORE INSERT
    ON orders
    FOR EACH ROW
EXECUTE PROCEDURE before_order_adding();