# Corporación Favorita — Sales Analysis

## Objetivo

Analisar dados de vendas da rede Corporación Favorita utilizando SQL Server e Power BI.

## Tecnologias

- SQL Server
- SQL Server Management Studio
- Python
- Pandas
- Power BI

## Base de dados

[Favorita Grocery Sales Forecasting — Kaggle](https://www.kaggle.com/competitions/favorita-grocery-sales-forecasting/data)

## Perguntas de negócio

1. Qual a quantidade vendida, devolvida e o balanço de vendas totais ?
2. Quais lojas, cidade e estado apresentam maior volume de vendas?
3. Quais categorias possuem maior demanda?
4. Quais produtos apresentam maior taxa de devolução?
5. Quais produtos e lojas apresentam mais vendas por dia ?
6. Promoções aumentam as vendas?
7. Quais meses/anos apresentam maior quantidade de vendas ?
8. Qual a quantidade média vendida em cada dia da semana ?

## Técnicas SQL utilizadas

- JOIN
- GROUP BY
- CASE WHEN
- CTE
- Subqueries
- DATEPART
- funções de agregação

## Análise
Primeiramente para a análise foi necessário entender o banco de dados, e a base de dados treino (onde se encontra mais de 115 milhões de registros) apresentava unit_sales com valores negativos (o que representavam a devolução daquele produto. Logo para análisar apenas as vendas e não o balanço de vendas (venda - devolução) foram criado duas VIEWS que filtraram as vendas e as devoluções.
```sql
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
WHERE unit_sales > 0)
```

### Qual a quantidade vendida, devolvida e o balanço de vendas totais.

``` sql
SELECT
    FORMAT(ABS((SELECT SUM(unit_sales)
     FROM vwDEVOLUCOES))), 'N') AS 'Quantidade devolvida',
    FORMAT((SELECT SUM(unit_sales)
     FROM vwVENDAS), 'N') AS 'Quantidade vendida' ,
    FORMAT((SELECT SUM(unit_sales)
     FROM train),'N') AS 'Balanço de vendas'
```

<img width="637" height="62" alt="image" src="https://github.com/user-attachments/assets/6d79e272-b514-4656-a5b2-3c7310fd08b3" />
Nessa análise é possível também utilizar o filtro WHERE BETWEEN para filtrar períodos de datas específicos.


###  Quais lojas, cidade e estado apresentam maior volume de vendas?

``` sql
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
```
<img width="373" height="340" alt="image" src="https://github.com/user-attachments/assets/0b42e873-9a19-4498-805d-0a70a4b013b6" />


``` sql
SELECT
    S.city AS 'Cidade',
    s.state AS 'Estado',
    ROUND(SUM(T.unit_sales),2) AS 'Total vendido'
FROM vwVENDAS AS T
LEFT JOIN stores AS S
ON T.store_nbr = S.store_nbr
GROUP BY S.city,S.state
ORDER BY SUM(T.unit_sales) DESC
```
<img width="475" height="338" alt="image" src="https://github.com/user-attachments/assets/5f3b6d83-445e-4680-b86f-21ea2c0bd4ff" />


``` sql
SELECT
    s.state AS 'Estado',
    ROUND(SUM(T.unit_sales),2) AS 'Total vendido'
FROM vwVENDAS AS T
LEFT JOIN stores AS S
ON T.store_nbr = S.store_nbr
GROUP BY S.city,S.state
ORDER BY SUM(T.unit_sales) DESC
```
<img width="366" height="347" alt="image" src="https://github.com/user-attachments/assets/a7ed5a3c-c994-4f59-96a7-ddeb0e853596" />

Com essa análise é possível observar que as lojas que apresentam maior quantidade de vendas são as lojas que estão localizadas na cidade de QUITO e no estado de Pichincha onde há também o maiuor número de lojas.

### Quais categorias possuem maior demanda?
``` sql
SELECT 
    I.family,
    ROUND(SUM(T.unit_sales),2) AS 'Total vendido'
FROM vwVENDAS AS T
LEFT JOIN items AS I
ON T.item_nbr = I.item_nbr
GROUP BY I.family
ORDER BY SUM(T.unit_sales) DESC
```
<img width="296" height="340" alt="image" src="https://github.com/user-attachments/assets/3f3f99f6-ea38-4c49-acda-765d76ae640e" />

### Quais produtos apresentam maior taxa de devolução? 
``` sql
SELECT TOP 10
    item_nbr,
    SUM(CASE
            WHEN unit_sales > 0 THEN unit_sales
            ELSE 0
        END
        ) AS quantidade_vendida,

    SUM(CASE
            WHEN unit_sales < 0 THEN unit_sales
            ELSE 0
        END
        ) AS quantidade_devolvida,

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
    ,'P') AS taxa_devolução
FROM
    train
GROUP BY item_nbr
ORDER BY taxa_devolução DESC
```
6. Quais produtos e lojas apresentam mais vendas por dia ?
4. Promoções aumentam as vendas?
7. Quais meses/anos apresentam maior quantidade de vendas ?
8. Qual a quantidade média vendida em cada dia da semana ?
