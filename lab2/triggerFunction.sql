CREATE OR REPLACE FUNCTION check_paymentDocs_total_price_func()
    RETURNS trigger AS
$$
DECLARE
twoPercent MONEY;
installmentsSum MONEY;
-------------------------
placeCost MONEY;
celebrityCost MONEY;
chosenServicesCost MONEY;
treatyCost MONEY;
-------------------------
placeId INTEGER;
celebrityId INTEGER;
-------------------------
BEGIN
    placeId := (
        SELECT additional_place
        FROM treaty
        WHERE treaty.id = NEW.linked_treaty
    );
    RAISE NOTICE 'placeId = %', placeId;
    placeCost := (
        SELECT price
        FROM place
        WHERE place.id = placeId
    );
    RAISE NOTICE 'placeCost = %', placeCost;
    celebrityId := (
        SELECT celebrity_id
        FROM treaty
        WHERE treaty.id = NEW.linked_treaty
    );
    RAISE NOTICE 'celebrityId = %', celebrityId;
    celebrityCost := (
        SELECT price
        FROM celebrity
        WHERE celebrity.id = celebrityId
    );
    RAISE NOTICE 'celebrityCost = %', celebrityCost;
    chosenServicesCost := (
        SELECT SUM(price * quantity)
        FROM chosen_services
        WHERE treaty_id = NEW.linked_treaty
    );
    RAISE NOTICE 'chosenServicesCost = %', chosenServicesCost;
    treatyCost := (
        SELECT total_price
        FROM treaty
        WHERE id = NEW.linked_treaty
    );
    RAISE NOTICE 'treatyCost = %', treatyCost;
    twoPercent := 2 * (treatyCost + chosenServicesCost + celebrityCost + placeCost) / 100;
    installmentsSum := (
        SELECT SUM(total_price)
        FROM payment_document
        WHERE linked_treaty = NEW.linked_treaty
    );
    RAISE NOTICE 'twoPercent = %', twoPercent;
    RAISE NOTICE 'payment_document = %', installmentsSum;
    RAISE NOTICE 'MAX SUM, = %', treatyCost + chosenServicesCost + celebrityCost + placeCost + twoPercent;
    IF installmentsSum > treatyCost + chosenServicesCost + celebrityCost + placeCost + twoPercent THEN
        RAISE 'Installments can not be greater than total sum of event';
    ELSE
        RAISE NOTICE 'succeed!';
    END IF;
    RETURN NEW;
END;    
$$
LANGUAGE 'plpgsql';


