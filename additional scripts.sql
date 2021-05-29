CREATE OR REPLACE FUNCTION before_order_status_changing() RETURNS TRIGGER AS
$$
BEGIN
    IF OLD.status != 'завершен' AND NEW.status = 'отменен' OR
       OLD.status = 'едет к заказчику' AND NEW.status = 'поездка началась' OR
       OLD.status = 'поездка началась' AND NEW.status = 'завершен'
    THEN
        RETURN NEW;
    END IF;

    RAISE EXCEPTION 'Invalid status change';
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER before_change_order_status
    BEFORE UPDATE
    ON orders
    FOR EACH ROW
EXECUTE PROCEDURE before_order_status_changing();



CREATE OR REPLACE PROCEDURE change_order_status_by_car(
    car_license_plate cars.license_plate%TYPE,
    new_status orders.status%TYPE
) AS
$$
DECLARE
    order_id orders.id%TYPE;
BEGIN
    order_id := (
        SELECT id
        FROM orders
        WHERE booking_time = (
            SELECT MAX(booking_time)
            FROM orders
            WHERE car = car_license_plate
        )
    );

    IF order_id IS NULL THEN
        RAISE EXCEPTION 'The car % did not fulfill orders', car_license_plate;
    END IF;

    UPDATE
        orders
    SET status = new_status
    WHERE id = order_id;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE PROCEDURE fire_driver(
    driver_name drivers.name%TYPE
) AS
$$
BEGIN
    UPDATE cars SET driver = NULL WHERE driver = driver_name;
    DELETE FROM drivers WHERE name = driver_name;
END
$$ LANGUAGE plpgsql;

CALL fire_driver('')