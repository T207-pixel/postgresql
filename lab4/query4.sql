/******* SELECT 4 *******/
WITH months_days AS( -- генерация таблицы дней в текущем месяце (месяц, дата)
       SELECT TO_CHAR(days::DATE, 'Month') AS mnth,
              days::DATE
       FROM generate_series((SELECT DATE_TRUNC('month', CURRENT_DATE - INTERVAL '1 month')), (SELECT DATE_TRUNC('month', CURRENT_DATE) - INTERVAL '1 day'), INTERVAL '1 day') AS days
), treaties_info AS( -- все оформленные договоры за прошлый месяц
       SELECT tr.opening_date AS dates,
              tr.total_price AS basic_cost,
              tr.id
       FROM treaty AS tr
       WHERE extract(YEAR FROM tr.opening_date) = extract(YEAR FROM CURRENT_DATE)
       AND extract(MONTH FROM tr.opening_date) = extract(MONTH FROM CURRENT_DATE) - 1 
), payment_documents_info AS( -- кол-во payDoc, sum(payDoc) по id (пока не по месяцам), по тем treaty, которые были оформлены в этом мес и дата payDoc, которых входит в этот месяц
       SELECT pd.linked_treaty AS lk_treaties,
              COUNT(pd.linked_treaty) AS quantity,
              SUM(pd.total_price) AS payment_sum
       FROM payment_document AS pd
       INNER JOIN treaties_info AS ti ON ti.id = pd.linked_treaty
       WHERE pd.payment_date >= ti.dates AND extract(MONTH FROM CURRENT_DATE) - 1 = extract(MONTH FROM pd.payment_date) 
       GROUP BY pd.linked_treaty
), group_for_payDocs_treaties AS( --совмещенная таблица из предыдущих двух
       SELECT SUM(pdi.quantity) AS payDocs_quantity_day,
              SUM(pdi.payment_sum) AS payDocs_sum_payment_day,
              MIN(pdi.lk_treaties) AS linked_tr_id, 
              ti.dates AS dates,
              SUM(ti.basic_cost) AS sum_basic_cost_treaty,
              COUNT(ti.dates) AS quantity_treaty
       FROM treaties_info AS ti
       LEFT JOIN payment_documents_info AS pdi ON pdi.lk_treaties = ti.id
       GROUP BY ti.dates
), all_dates_treaties_paydocs AS(
       SELECT md.mnth AS months,
              md.days AS dates,
              pt.payDocs_quantity_day AS payDocs_quantity_day,
              pt.payDocs_sum_payment_day AS payDocs_sum_payment_day,
              pt.linked_tr_id AS linked_tr_id,
              pt.sum_basic_cost_treaty AS sum_basic_cost_treaty,
              pt.quantity_treaty AS quantity_treaty
       FROM group_for_payDocs_treaties AS pt
       RIGHT JOIN months_days AS md ON md.days = pt.dates
), all_columns AS(
       SELECT dtp.months AS months,
              dtp.dates AS dates,
              dtp.payDocs_quantity_day AS payDocs_quantity_day,
              dtp.payDocs_sum_payment_day AS payDocs_sum_payment_day,
              --dtp.linked_tr_id AS linked_tr_id,
              dtp.sum_basic_cost_treaty AS sum_basic_cost_treaty,
              dtp.quantity_treaty AS quantity_treaty,
              (SELECT COALESCE(SUM(sum_basic_cost_treaty) - SUM(payDocs_sum_payment_day), 0::MONEY) FROM all_dates_treaties_paydocs AS adtp
              WHERE adtp.dates <= dtp.dates) AS debts_endDay,
              (SELECT COALESCE(SUM(sum_basic_cost_treaty), 0::MONEY) FROM all_dates_treaties_paydocs AS adtp
              WHERE adtp.dates <= dtp.dates) -
              (SELECT COALESCE(SUM(payDocs_sum_payment_day), 0::MONEY) FROM all_dates_treaties_paydocs AS adtp
              WHERE adtp.dates < dtp.dates) AS debts_beginningDay
       FROM all_dates_treaties_paydocs AS dtp
), for_union AS(
       SELECT 'Total' AS months,
              MIN(a.dates) AS dates,
              SUM(a.payDocs_quantity_day) AS payDocs_quantity_day,
              SUM(a.payDocs_sum_payment_day) AS payDocs_sum_payment_day,
              --SUM(a.linked_tr_id) AS linked_tr_id,
              SUM(a.sum_basic_cost_treaty) AS sum_basic_cost_treaty,
              SUM(a.quantity_treaty) AS quantity_treaty,
              SUM(a.debts_endDay) AS debts_endDay,
              SUM(a.debts_beginningDay) AS debts_beginningDay
       FROM all_columns AS a
       GROUP BY a.months
)
SELECT a.* 
FROM all_columns AS a
UNION SELECT * FROM for_union









SELECT * FROM _event_;
SELECT * FROM treaty;
SELECT * FROM payment_document;

INSERT INTO payment_document(id, linked_treaty, payment_date, total_price, document_type, companys_employee_id, client_id, accounter_id)
    VALUES
    (40, 26, '2023-05-27', 29000, false, 6, 2, 7);

INSERT INTO treaty(id, treaty_type, total_price, treaty_number, opening_date, closing_date, extra_pay, manager_id, client_id, event_id, celebrity_id, additional_place, penalty)
        VALUES--(26, 'basic', 300000, 26, '2023-05-10', '2023-08-12', 10000, 1, 3, 22, 3, 1, 70000),
              (28, 'basic', 700000, 28, '2023-05-24', '2023-09-09', 10000, 1, 4, 23, 4, 4, 80000);

INSERT INTO _event_(event_name, client_Firstname, client_Lastname, manager_Firstname, manager_Lastname, companys_employee_id)
    VALUES
    ('AAA', 'QWE', 'sck', 'Daniel', 'Figurson', 1),
    ('BBB', 'QWQ', 'white', 'Daniel', 'Figurson', 1);