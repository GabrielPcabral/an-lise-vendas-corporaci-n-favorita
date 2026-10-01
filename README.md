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
4. Promoções aumentam as vendas?
5. Quais produtos apresentam maior taxa de devolução?
6. Quais produtos e lojas apresentam mais vendas por dia ?
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

### Qual a quantidade vendida, devolvida e o balanço de vendas totais.

``` sql
SELECT
    FORMAT(ABS((SELECT SUM(unit_sales)
     FROM train
     WHERE unit_sales < 0)), 'N') AS 'Quantidade devolvida',
    FORMAT((SELECT SUM(unit_sales)
     FROM train
     WHERE unit_sales > 0), 'N') AS 'Quantidade vendida' ,
    FORMAT((SELECT SUM(unit_sales)
     FROM train),'N') AS 'Balanço de vendas'
```

<img width="637" height="62" alt="image" src="https://github.com/user-attachments/assets/6d79e272-b514-4656-a5b2-3c7310fd08b3" />
