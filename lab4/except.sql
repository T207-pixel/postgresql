CREATE TABLE persone(
    id SERIAL PRIMARY KEY,
    name VARCHAR(255)
);

CREATE TABLE hobby(
    id SERIAL PRIMARY KEY,
    activite VARCHAR(255)
);

INSERT INTO persone(name)
VALUES  ('Tim'),
        ('Alex'),
        ('Gera'),
        ('Vika'),
        ('Mark');

INSERT INTO hobby(activite)
VALUES  ('snowboarding'),
        ('guitar'),
        ('grahity'),
        ('painting'),
        ('fishing');

SELECT * FROM persone;
SELECT * FROM hobby;

ALTER TABLE hobby
ADD fake_id INTEGER 

UPDATE hobby
SET fake_id = 1
WHERE id = 3;


WITH fullTmp AS(
    SELECT  t1.name AS n,
        t2.activite AS a
FROM persone AS t1
FULL JOIN hobby AS t2 ON t1.fake_id = t2.fake_id
), allPeopleTmp AS(
    SELECT  t1.name AS n,
        t2.activite AS a
FROM persone AS t1
LEFT JOIN hobby AS t2 ON t1.fake_id = t2.fake_id
)
SELECT  ft.a AS nobodyHobby
FROM fullTmp AS ft
EXCEPT  SELECT  apt.a AS nobodyHobby
FROM allPeopleTmp AS apt




