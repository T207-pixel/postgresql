CREATE OR REPLACE FUNCTION generate_price_func()
    RETURNS trigger AS
$$
DECLARE
sameServiceQquantity REAL;
realCost MONEY;
priceAccountingDiscount MONEY;
BEGIN
    realCost := (
        SELECT price
        FROM services_in_pricelist
        WHERE id = NEW.services_in_pricelist_id
    );
    RAISE NOTICE 'realCost = %', realCost;
    sameServiceQquantity := (
        SELECT SUM(quantity)
        FROM chosen_services
        WHERE services_in_pricelist_id = NEW.services_in_pricelist_id AND treaty_id = NEW.treaty_id
    );
    RAISE NOTICE 'sameServiceQquantity = %', sameServiceQquantity;
    IF sameServiceQquantity > 1 AND sameServiceQquantity <= 10 THEN
        priceAccountingDiscount := realCost - ((sameServiceQquantity * realCost) / 100);
        UPDATE chosen_services
        SET price = priceAccountingDiscount
        WHERE id = NEW.id;
    ELSEIF sameServiceQquantity > 10 THEN
        priceAccountingDiscount := realCost - ((10 * realCost) / 100);
        UPDATE chosen_services
        SET price = priceAccountingDiscount
        WHERE id = NEW.id;
    ELSE
        UPDATE chosen_services
        SET price = realCost
        WHERE id = NEW.id;
    END IF;
    RETURN NEW;
END;
$$
LANGUAGE 'plpgsql';
