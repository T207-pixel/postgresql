WITH months_days AS( -- генерация таблицы месяцев с прошлого года
       SELECT TO_CHAR(days::DATE, 'Month') AS mnth,
              days::DATE
       FROM generate_series((SELECT DATE_TRUNC('year', CURRENT_DATE - INTERVAL '1 year')), (SELECT DATE_TRUNC('month', CURRENT_DATE)), INTERVAL '1 month') AS days
), treaties AS( -- общая таблица для treaty
    SELECT  t.opening_date AS dates,
            extract(MONTH FROM t.opening_date) AS months,
            extract(YEAR FROM t.opening_date) AS years,
            t.id AS id,
            t.total_price AS tr_price
    FROM treaty AS t
    WHERE extract(YEAR FROM t.opening_date) >= extract(YEAR FROM CURRENT_DATE) - 1
), chosen_services_all AS( -- смешенная сервисы и treaty
    SELECT  cs.treaty_id AS tr_id,
            cs.price AS serv_price,
            cs.quantity AS quantity,
            cs.services_in_pricelist_id AS serv_priceLst_id,
            t.dates AS dates,
            t.months AS months,
            t.years AS years,
            t.tr_price AS tr_price
    FROM chosen_services AS cs
    RIGHT JOIN treaties AS t ON t.id = cs.treaty_id
), average_price_prepare AS( -- суммирую стоимость мероприяти со всеми услугами ПОДГОТОВКА TMP таблицы
        SELECT SUM(csa.serv_price) + MAX(csa.tr_price) AS sum_day_tr_plus_serv,
                MAX(csa.dates) AS dates,
                MAX(csa.months) AS months,
                MAX(csa.years) AS years
        FROM chosen_services_all AS csa
        GROUP BY csa.tr_id
), avg_sum_table AS( --считаю среднее значение в днях
        SELECT MAX(app.dates) AS dates,
                app.months AS months,
                app.years AS years,
                AVG(sum_day_tr_plus_serv::numeric) AS average
        FROM average_price_prepare AS app
        GROUP BY app.months, app.years
), events_servs_group AS(  --количество мероприятий за каждый месяц + сумма_мероприятия_с_учетом_услуг 
    SELECT  COUNT(DISTINCT csa.tr_id) AS quantity_of_formed_events,
            csa.months AS months,
            csa.years AS years,
            SUM(serv_price) + SUM(DISTINCT tr_price) AS sum_events_and_services,
            MAX(ast.average) AS average_price,
            --AVG((serv_price + tr_price)::numeric) AS average_price, -- считать общие услуги неверено
            mode() WITHIN GROUP (ORDER BY csa.serv_priceLst_id) AS most_frequent_serv_ids
            
    FROM chosen_services_all AS csa
    INNER JOIN avg_sum_table AS ast ON ast.months = csa.months AND ast.years = csa.years
    GROUP BY csa.months, csa.years
), qnt_frequent_ser AS( -- сколько раз была оформлена самая популярная услуга месяца
    SELECT  COUNT(csa.serv_priceLst_id) AS qntity_mst_freqent_serv,
            csa.months AS months,
            csa.years AS years
    FROM chosen_services_all AS csa
    LEFT JOIN events_servs_group AS esg ON esg.months = csa.months AND csa.years = esg.years
    WHERE csa.serv_priceLst_id = esg.most_frequent_serv_ids
    GROUP BY csa.months, csa.years
), treaties_servs_popServs AS( --все из пердыдущего + сколько раз встречалась самая популярная услуга
    SELECT  esg.years AS years,
            esg.months AS months,
            esg.quantity_of_formed_events AS quantity_of_formed_events,
            esg.sum_events_and_services AS sum_events_and_services,
            esg.average_price AS average_price,
            esg.most_frequent_serv_ids AS most_frequent_serv_ids,
            qfs.qntity_mst_freqent_serv AS qntity_mst_freqent_serv
    FROM events_servs_group AS esg
    INNER JOIN qnt_frequent_ser AS qfs ON esg.years = qfs.years AND esg.months = qfs.months
), all_dates_all_inf AS( --все даты и все кроме процентного изменения
    SELECT  tsp.years AS years, --в конечном выводе лучше убрать
            tsp.months AS months, --в конечном выводе лучше убрать
            tsp.quantity_of_formed_events AS quantity_of_formed_events,
            tsp.sum_events_and_services AS sum_events_and_services,
            tsp.average_price AS average_price,
            tsp.most_frequent_serv_ids AS most_frequent_serv_ids,
            tsp.qntity_mst_freqent_serv AS qntity_mst_freqent_serv,
            md.mnth AS month_str,
            md.days AS months_dates
    FROM treaties_servs_popServs AS tsp
    RIGHT JOIN months_days AS md ON tsp.years = extract(YEAR FROM md.days) 
                                AND tsp.months = extract(MONTH FROM md.days)
), offset_table AS( -- считаю процент
    WITH tmp AS(
        SELECT  t1.sum_events_and_services AS prices,
            t2.sum_events_and_services AS comparable,
            t1.years AS years,
            t1.months AS months
    FROM all_dates_all_inf t1
    LEFT JOIN all_dates_all_inf t2 ON t1.months - 1 = t2.months AND t1.years = t2.years
    RIGHT JOIN months_days AS md ON t1.years = extract(YEAR FROM md.days) 
                                AND t1.months = extract(MONTH FROM md.days)
    )
    SELECT  tmp.prices AS prices,
            tmp.comparable AS comparable,
            tmp.years AS years,
            tmp.months AS months,
            COALESCE((tmp.prices::numeric - tmp.comparable::numeric) * 100 / tmp.comparable::numeric, 0::numeric) AS percent_dif
            -- относительно пред comparable
            -- сделать ордер бай months_dates
    FROM tmp
)
SELECT  --ada.years AS years, --в конечном выводе лучше убрать
        --ada.months AS months, --в конечном выводе лучше убрать
        ada.month_str AS month_str,
        ada.months_dates AS months_dates,
        ada.quantity_of_formed_events AS quantity_of_formed_events,
        ada.sum_events_and_services AS sum_events_and_services,
        ada.average_price AS average_price,
        ada.most_frequent_serv_ids AS most_frequent_serv_ids,
        ada.qntity_mst_freqent_serv AS qntity_mst_freqent_serv,
        of.percent_dif AS percent_dif
        FROM all_dates_all_inf AS ada
        LEFT JOIN offset_table AS of ON of.months = ada.months AND of.years = ada.years
        ORDER BY ada.months_dates



SELECT * FROM _event_;
SELECT * FROM treaty;
SELECT * FROM chosen_services;
