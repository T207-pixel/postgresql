--Query5 CASE Замерить время
    EXPLAIN ANALYZE WITH tmp AS(
        WITH create_table AS(
            WITH tmp1 AS(
            SELECT  COUNT(DISTINCT client_id) AS quantity_clients
            FROM treaty
            GROUP BY client_id
            ), tmp2 AS(
                SELECT  COUNT(DISTINCT manager_id) AS mg_id
                FROM treaty
                GROUP BY manager_id
            )
            SELECT  sir1 AS clients,
                    sir2 AS managers
            FROM generate_series(1, (SELECT SUM(tmp1.quantity_clients) FROM tmp1)) sir1, generate_series(1, (SELECT SUM(tmp2.mg_id) FROM tmp2)) sir2
        ), crosses AS(
            SELECT  client_id AS client_id,
                    manager_id AS manager_id,
                    COUNT(client_id) AS crosser
            FROM treaty 
            GROUP BY client_id, manager_id ORDER BY manager_id
        )
        SELECT  ct.clients AS clients_id,
                ct.managers AS managers_id,
                COALESCE(cr.crosser, 0) AS crosser
        FROM create_table AS ct
        LEFT JOIN crosses AS cr ON ct.clients = cr.client_id AND cr.manager_id = ct.managers
        ORDER BY ct.clients
    )
    SELECT  t.clients_id AS clients_id,
            MAX(CASE WHEN t.managers_id  = 1 THEN t.crosser ELSE 0 END) AS mg1,
            MAX(CASE WHEN t.managers_id  = 2 THEN t.crosser ELSE 0 END) AS mg2,
            MAX(CASE WHEN t.managers_id  = 3 THEN t.crosser ELSE 0 END) AS mg3
    FROM tmp AS t 
    GROUP BY t.clients_id    

--Query5 FILTER -- Замерить время
EXPLAIN ANALYZE WITH tmp AS(
    WITH create_table AS(
        WITH tmp1 AS(
        SELECT  COUNT(DISTINCT client_id) AS quantity_clients
        FROM treaty
        GROUP BY client_id
        ), tmp2 AS(
            SELECT  COUNT(DISTINCT manager_id) AS mg_id
            FROM treaty
            GROUP BY manager_id
        )
        SELECT  sir1 AS clients,
                sir2 AS managers
        FROM generate_series(1, (SELECT SUM(tmp1.quantity_clients) FROM tmp1)) sir1, generate_series(1, (SELECT SUM(tmp2.mg_id) FROM tmp2)) sir2
    ), crosses AS(
        SELECT  client_id AS client_id,
                manager_id AS manager_id,
                COUNT(client_id) AS crosser
        FROM treaty 
        GROUP BY client_id, manager_id ORDER BY manager_id
    )
    SELECT  ct.clients AS clients_id,
            ct.managers AS managers_id,
            COALESCE(cr.crosser, 0) AS crosser
    FROM create_table AS ct
    LEFT JOIN crosses AS cr ON ct.clients = cr.client_id AND cr.manager_id = ct.managers
    ORDER BY ct.clients
)
SELECT  t.clients_id AS clients_id,
        MAX(t.crosser) FILTER (WHERE t.managers_id = 1) AS mg1,
        MAX(t.crosser) FILTER (WHERE t.managers_id = 2) AS mg2,
        MAX(t.crosser) FILTER (WHERE t.managers_id = 3) AS mg3
FROM tmp AS t 
GROUP BY t.clients_id



----------------------------------------------------------------------------------------------------------------------------









--------------------------------------------------------------------------------------------------------------
SELECT * FROM crosstab('WITH create_table AS(
        WITH tmp1 AS(
        SELECT  COUNT(DISTINCT client_id) AS quantity_clients
        FROM treaty
        GROUP BY client_id
        ), tmp2 AS(
            SELECT  COUNT(DISTINCT manager_id) AS mg_id
            FROM treaty
            GROUP BY manager_id
        )
        SELECT  sir1 AS clients,
                sir2 AS managers
        FROM generate_series(1, (SELECT SUM(tmp1.quantity_clients) FROM tmp1)) sir1, generate_series(1, (SELECT SUM(tmp2.mg_id) FROM tmp2)) sir2
    ), crosses AS(
        SELECT  client_id AS client_id,
                manager_id AS manager_id,
                COUNT(client_id) AS crosser
        FROM treaty 
        GROUP BY client_id, manager_id ORDER BY manager_id
    )
    SELECT  ct.clients AS clients_id,
            ct.managers AS managers_id,
            COALESCE(cr.crosser, 0) AS crosser
    FROM create_table AS ct
    LEFT JOIN crosses AS cr ON ct.clients = cr.client_id AND cr.manager_id = ct.managers
    ORDER BY ct.clients')
    AS final_result (clients_id INTEGER, mg_1 INTEGER, mg_2 INTEGER, mg_3 INTEGER)



        
-- UPDATE treaty
-- SET  manager_id = 2
-- WHERE manager_id = 6;
-- UPDATE treaty
-- SET  manager_id = 3
-- WHERE manager_id = 9
    


SELECT * FROM _event_;
SELECT * FROM treaty;
SELECT * FROM payment_document;
SELECT * FROM companys_employee;
SELECT * FROM chosen_services;
SELECT * FROM services_in_pricelist;
SELECT * FROM celebrity;
SELECT * FROM place;
SELECT * FROM client;