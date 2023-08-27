CREATE OR REPLACE PROCEDURE createPaymentOrders(IN openingD DATE, IN closingD DATE)
AS $$
    DECLARE
    iterable_tr_id BIGINT;
    treaty_price MONEY;
    chosen_services_price MONEY;
    totalSum MONEY;
    trt_id INTEGER;
    select_open_date DATE;
    select_close_date DATE;
    opening_flag BOOLEAN;
    closing_flag BOOLEAN;
    BEGIN
        FOR iterable_tr_id IN (SELECT * FROM treaty)
        LOOP
            select_open_date := (
                SELECT opening_date
                FROM treaty
                WHERE id = iterable_tr_id;
            );
            RAISE NOTICE 'select_open_date = %', select_open_date;
            select_close_date := (
                SELECT closing_date
                FROM treaty
                WHERE id = iterable_tr_id;
            );
            RAISE NOTICE 'select_close_date = %', select_close_date;
            opening_flag := (SELECT (DATE openingD, DATE closingD) OVERLAPS
                            (DATE select_open_date, DATE select_open_date));
            closing_flag := (SELECT (DATE openingD, DATE closingD) OVERLAPS
                            (DATE select_close_date, DATE select_close_date));
            IF opening_flag = true AND closing_flag = true THEN
                treaty_price := (
                    SELECT total_price
                    FROM treaty
                    WHERE id = iterable_tr_id
                );
                RAISE NOTICE 'treaty_price = %', treaty_price;
                chosen_services_price := (
                    SELECT SUM(price * quantity)
                    FROM chosen_services
                    WHERE treaty_id = iterable_tr_id
                );
                RAISE NOTICE 'chosen_services_price = %', chosen_services_price;
                INSERT INTO payment_orders(total_payment, treaty_id)
                    VALUES
                    (treaty_price + chosen_services_price, iterable_tr_id);
            END IF;
        END LOOP;
    END;
$$
LANGUAGE 'plpgsql';

CALL createPaymentOrders('2023-01-24', '2023-09-01');
