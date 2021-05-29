CREATE OR REPLACE FUNCTION after_order_status_changing() RETURNS TRIGGER AS
$$
DECLARE
    new_status_change_id INT;
BEGIN
    CASE NEW.status
        WHEN 'поездка началась' THEN new_status_change_id := 2;
        WHEN 'завершен' THEN new_status_change_id := 3;
        WHEN 'отменен' THEN new_status_change_id := 4;
        END CASE;

    INSERT INTO logs (order_id, time, status_change_id) VALUES (NEW.id, NOW(), new_status_change_id);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER on_change_order_status
    AFTER UPDATE
    ON orders
    FOR EACH ROW
EXECUTE PROCEDURE after_order_status_changing()