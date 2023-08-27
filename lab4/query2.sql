/******* SELECT 2 *******/
WITH managers_table AS(
  SELECT manager_id,
       COUNT(*)                  AS managers_events_quantity,
       COUNT(DISTINCT client_id) AS managers_unique_clients
  FROM treaty
  WHERE extract(MONTH FROM opening_date) = extract(MONTH FROM CURRENT_DATE) - 1 AND extract(YEAR FROM opening_date) = extract(YEAR FROM CURRENT_DATE)
  GROUP BY manager_id
), accounter_table AS (
  SELECT accounter_id,
       SUM(total_price)           AS total_sum,
       COUNT(*)                   AS accs_payDocs_quantity,
       AVG(total_price::numeric)  AS average_paymentDoc
  FROM payment_document
  WHERE extract(MONTH FROM payment_date) = extract(MONTH FROM CURRENT_DATE) - 1 AND extract(YEAR FROM payment_date) = extract(YEAR FROM CURRENT_DATE)
  GROUP BY accounter_id
), manager_total_sum_tabel AS(
  WITH chosen_serv_tabel AS(
  SELECT treaty_id,
         SUM(price * quantity) AS sum_of_services
  FROM chosen_services
  GROUP BY treaty_id
  )
  SELECT treaty.manager_id                                                                            AS mg_id,
         SUM(treaty.total_price + chosen_serv_tabel.sum_of_services + celebrity.price + place.price)  AS mega_total
  FROM treaty
  LEFT JOIN celebrity ON treaty.celebrity_id = celebrity.id
  LEFT JOIN place ON treaty.additional_place = place.id
  LEFT JOIN chosen_serv_tabel ON treaty.id = chosen_serv_tabel.treaty_id
  WHERE extract(MONTH FROM opening_date) = extract(MONTH FROM CURRENT_DATE) - 1 AND extract(YEAR FROM opening_date) = extract(YEAR FROM CURRENT_DATE)
  GROUP BY mg_id
)

SELECT companys_employee.employee_firstname            AS "Firstname",
       companys_employee.employee_lastname             AS "Lastname",
       companys_employee.employee_patronimic           AS "Patronimic",
       job_title.job_name                              AS "Profession",
       
       managers_table.managers_events_quantity         AS "Managers formed events",
       managers_table.managers_unique_clients          AS "Manager unique clients",
       manager_total_sum_tabel.mega_total              AS "Manager total event sum",
       
       accounter_table.accs_payDocs_quantity           AS "Accounters payment documents",
       accounter_table.total_sum                       AS "Accounters sum of payDocs",
       accounter_table.average_paymentDoc              AS "Accounters average payDoc value"

FROM companys_employee
LEFT JOIN job_title ON companys_employee.job_title_id = job_title.id
LEFT JOIN managers_table ON companys_employee.id = managers_table.manager_id
LEFT JOIN accounter_table ON companys_employee.id = accounter_table.accounter_id
LEFT JOIN manager_total_sum_tabel ON companys_employee.id = manager_total_sum_tabel.mg_id;