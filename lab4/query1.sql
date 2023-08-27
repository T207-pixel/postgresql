/******* SELECT 1 *******/
WITH celeb_tables AS(
  SELECT id,
       COUNT(celebrity_id)  AS celebs_quantity
  FROM treaty
  GROUP BY id
), services_table AS(
  SELECT treaty_id,
       COUNT(DISTINCT services_in_pricelist_id) AS dif_services_quantity,
       SUM(services_in_pricelist_id)            AS common_services_quantity,
       SUM(price)                               AS sum_of_services
  FROM chosen_services
  GROUP BY treaty_id
), payment_table AS(
  SELECT linked_treaty,
       SUM(total_price)   AS paid_sum,
       SUM(debts)         AS must_pay
  FROM payment_document
  GROUP BY linked_treaty
)
SELECT _event_.event_name                                         AS "Event_name",
       _event_.client_Lastname                                    AS "Event_Client_name",
       treaty.opening_date                                        AS "Event_opening_date",
       treaty.total_price                                         AS "Event_basic_cost",
       celeb_tables.celebs_quantity                               AS "Celebs_quantity",
       celebrity.price                                            AS "Celebrity_price",
       services_table.dif_services_quantity                       AS "Different_services_quantity",
       services_table.common_services_quantity                    AS "Common_services_quantity",
       services_table.sum_of_services                             AS "Total_services_sum",
       treaty.total_price + services_table.sum_of_services + celebrity.price + place.price AS "Common_event_price",
       place.price                                                AS "Rent_place_price",
       payment_table.paid_sum                                     AS "Event_paid_sum",
       payment_table.must_pay                                     AS "Debts_size"

FROM treaty
LEFT JOIN _event_ ON treaty.event_id = _event_.id
LEFT JOIN celeb_tables ON treaty.event_id = celeb_tables.id
LEFT JOIN celebrity ON treaty.celebrity_id = celebrity.id
LEFT JOIN services_table ON treaty.id = services_table.treaty_id
LEFT JOIN payment_table ON treaty.id = payment_table.linked_treaty
LEFT JOIN place ON treaty.additional_place = place.id
WHERE treaty.treaty_type = 'upper'
ORDER BY payment_table.paid_sum;