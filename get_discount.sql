CREATE OR REPLACE FUNCTION get_discount(
    customer_name customers.name%TYPE
) RETURNS NUMERIC AS
$$
DECLARE
    discount_factor            INT := 50;
    number_of_completed_orders INT;
    cur_order                  orders%ROWTYPE;
BEGIN
    --     number_of_completed_orders := (SELECT COUNT(*) FROM orders WHERE customer = customer_name AND status = 'completed');

    number_of_completed_orders := 0;
    FOR cur_order IN SELECT * FROM orders ORDER BY id
        LOOP
            IF cur_order.customer = customer_name AND cur_order.status = 'завершен' THEN
                number_of_completed_orders := number_of_completed_orders + 1;
            END IF;
        END LOOP;

    RETURN discount_factor * (number_of_completed_orders / 10);
END;
$$ LANGUAGE plpgsql;

SELECT get_discount('Артем')