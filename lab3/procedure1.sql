CREATE OR REPLACE PROCEDURE cancellation(IN eve_id INTEGER)
AS $$
    DECLARE
    chosenServicesSum MONEY;
    penaltyCost MONEY;
    paymentDocumentsSum MONEY;
    tr_id INTEGER;
    BEGIN
        tr_id := (
            SELECT id
            FROM treaty
            WHERE event_id = eve_id
        );
        chosenServicesSum := (
            SELECT SUM(price * quantity)
            FROM chosen_services
            WHERE treaty_id = tr_id
        );
        penaltyCost := (
            SELECT penalty
            FROM treaty
            WHERE id = tr_id
        );
        paymentDocumentsSum := (
            SELECT COALESCE(SUM(total_price), 0::money)
            FROM payment_document
            WHERE linked_treaty = tr_id
        );
        IF paymentDocumentsSum > penaltyCost + chosenServicesSum THEN
            INSERT INTO payment_orders(total_payment, treaty_id)
                VALUES
                (paymentDocumentsSum, tr_id);
        ELSE
            RAISE 'Payment order can not be created due to debt in size of: %', chosenServicesSum + penaltyCost - paymentDocumentsSum;
        END IF;
    END;
$$
LANGUAGE 'plpgsql';
