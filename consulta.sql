-- Separa as transações de vendas e devoluções em views.
CREATE VIEW vwVENDAS AS (
SELECT
*
FROM
train
WHERE unit_sales > 0)

CREATE VIEW vwDEVOLUCOES AS (
SELECT
*
FROM
train
WHERE unit_sales < 0)



-- Cálculo da quantidade vendida, devolvida e o balanço de vendas no periodo.
SELECT
    FORMAT(ABS((SELECT SUM(unit_sales)
     FROM vwDEVOLUCOES))), 'N') AS 'Quantidade devolvida',
    FORMAT((SELECT SUM(unit_sales)
     FROM vwVENDAS), 'N') AS 'Quantidade vendida' ,
    FORMAT((SELECT SUM(unit_sales)
     FROM train),'N') AS 'Balanço de vendas'

-- Balanço de vendas por loja/ cidade e estado.

SELECT
    T.store_nbr AS 'N° loja',
    S.city AS 'Cidade',
    S.state 'Estado',
    ROUND(SUM(T.unit_sales),2) AS 'Total vendido'
FROM vwVENDAS AS T
LEFT JOIN stores AS S
ON T.store_nbr = S.store_nbr
GROUP BY T.store_nbr, S.city, S.state
ORDER BY SUM(T.unit_sales) DESC


SELECT
    S.city AS 'Cidade',
    s.state AS 'Estado',
    ROUND(SUM(T.unit_sales),2) AS 'Total vendido'
FROM vwVENDAS AS T
LEFT JOIN stores AS S
ON T.store_nbr = S.store_nbr
GROUP BY S.city,S.state
ORDER BY SUM(T.unit_sales) DESC

SELECT
    s.state AS 'Estado',
    ROUND(SUM(T.unit_sales),2) AS 'Total vendido'
FROM vwVENDAS AS T
LEFT JOIN stores AS S
ON T.store_nbr = S.store_nbr
GROUP BY S.city,S.state
ORDER BY SUM(T.unit_sales) DESC



-- Balanço de vendas por família de produtos
SELECT 
    I.family,
    ROUND(SUM(T.unit_sales),2) AS 'Total vendido'
FROM vwVENDAS AS T
LEFT JOIN items AS I
ON T.item_nbr = I.item_nbr
GROUP BY I.family
ORDER BY SUM(T.unit_sales) DESC

-- Taxa de devolução por produtos
SELECT TOP 10
    item_nbr AS Item,
    SUM(CASE
            WHEN unit_sales > 0 THEN unit_sales
            ELSE 0
        END
        ) AS 'Quantidade vendida',

    SUM(CASE
            WHEN unit_sales < 0 THEN unit_sales
            ELSE 0
        END
        ) AS 'Quantidade devolvida',

    FORMAT(
        ABS(
            SUM(
                (CASE
                    WHEN unit_sales < 0 THEN unit_sales
                    ELSE 0
                 END)
            )
        )     
                 /
                NULLIF (
                    SUM(
                        (CASE
                            WHEN unit_sales > 0 THEN unit_sales
                            ELSE 0

                            END)
                        )
                ,0)
    ,'P') AS 'Taxa de devolução'
FROM
    train
GROUP BY item_nbr
ORDER BY [Taxa de devolução] DESC


-- 2O0 Produtos com mais vendas por dia
DECLARE @qtd_dias INT;

SET @qtd_dias = (
    SELECT COUNT(DISTINCT date)
    FROM train
);

SELECT TOP 200
   item_nbr,
   ROUND((SUM(unit_sales)/@qtd_dias),2) AS 'Quantidade vendida por dias' 
FROM vwDEVOLUCOES
GROUP BY item_nbr
ORDER BY SUM(unit_sales)/@qtd_dias DESC 


--Lojas com mais vendas por dia
DECLARE @qtd_dias INT;

SET @qtd_dias = (
    SELECT COUNT(DISTINCT date)
    FROM train
);

SELECT
   store_nbr,
   ROUND((SUM(unit_sales)/@qtd_dias),2) AS 'Quantidade vendida por dias',
   ROUND(SUM(unit_sales),2) AS 'Vendas totais'
FROM vwVENDAS
GROUP BY store_nbr
ORDER BY SUM(unit_sales)/@qtd_dias DESC 


-- Análise desempenho em promoção
DECLARE @qtd_vendida FLOAT
SET @qtd_vendida = (
SELECT 
   SUM(unit_sales)
FROM vwVENDAS);

SELECT
    onpromotion AS Promoção,
    ROUND(SUM( unit_sales),2) AS 'Quantidade vendida',
    ROUND(AVG(unit_sales),2) AS 'Média vendas',
    FORMAT((SUM(unit_sales)/@qtd_vendida),'P') AS 'Porcentagem vendida',
    COUNT(*) AS 'Quantidade de registros'
FROM vwVENDAS
GROUP BY onpromotion


-- Quantidade vendida por ano/mês
SELECT
    YEAR(date) AS Ano,
    MONTH(date) AS Mês,
    ROUND(    
        SUM(
            CASE
                WHEN unit_sales > 0 THEN unit_sales
                ELSE 0
            END),2) AS 'Quantidade vendida'
FROM vwVENDAS
GROUP BY YEAR(date), MONTH(date)
ORDER BY [Quantidade vendida] DESC

-- Quantidade vendida por dia de semana
WITH vendas_dias AS (
SELECT
    date,
    DATENAME(WEEKDAY,date) AS dia_semana,
    SUM(unit_sales) AS Total_vendido
FROM 
    train
GROUP BY date , DATENAME(WEEKDAY,date))

SELECT 
    DATENAME(WEEKDAY, date) AS 'Dia semana',
    ROUND(AVG(Total_vendido),2) AS 'Média de vendas'
FROM
    vendas_dias
GROUP BY
    DATENAME(WEEKDAY, date)
ORDER BY [Média de vendas] DESC
