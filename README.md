# Corporación Favorita — Sales Analysis
>Projeto de análise exploratória de vendas da Corporación Favorita, desenvolvido com SQL Server e Power BI, com foco em demanda, devoluções, desempenho de lojas, promoções e comportamento temporal das vendas.

## Objetivo
Analisar o comportamento das vendas da rede Corporación Favorita e identificar padrões relacionados a:
- volume de vendas e devoluções;
- desempenho de lojas, cidades e estados;
- demanda por categoria e produto;
- taxa de devolução;
- média diária de vendas;
- comportamento de itens em promoção;
- sazonalidade mensal e anual;
- comportamento das vendas por dia da semana.

## Tecnologias

- SQL Server


## Base de dados

[Favorita Grocery Sales Forecasting — Kaggle](https://www.kaggle.com/competitions/favorita-grocery-sales-forecasting/data)

Entre as principais tabelas utilizadas nas consultas estão:
- train — registros de vendas por data, loja e produto;
- stores — informações sobre as lojas, como cidade e estado;
- items — informações sobre os produtos e suas categorias.


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

### Preparação da base de dados

Antes das análises, foi necessário interpretar corretamente a coluna unit_sales.
- unit_sales > 0 → venda;
- unit_sales < 0 → devolução.
Para facilitar as consultas seguintes, foram criadas duas views:

``` sql
CREATE VIEW vwVENDAS AS
SELECT *
FROM train
WHERE unit_sales > 0


CREATE VIEW vwDEVOLUCOES AS
SELECT *
FROM train
WHERE unit_sales < 0
```
Essa separação permite analisar vendas e devoluções de forma independente, evitando que os valores negativos sejam interpretados incorretamente como redução de demanda em análises específicas.


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

O indicador de balanço de vendas representa o resultado líquido entre vendas e devoluções. A mesma lógica pode ser combinada com filtros de data para analisar períodos específicos.


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

Os resultados mostram concentração de vendas em Quito e no estado de Pichincha. Como essa região também possui maior presença de lojas, o volume total deve ser interpretado em conjunto com a quantidade de unidades existentes em cada localidade.

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

Essa análise permite identificar as categorias com maior demanda acumulada e pode servir de ponto de partida para análises de estoque, sortimento e comportamento de consumo

### Quais produtos apresentam maior taxa de devolução? 
``` sql
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
```
<img width="529" height="264" alt="image" src="https://github.com/user-attachments/assets/9065e98f-1623-4720-ad66-a92dbf40d976" />

A análise identificou produtos com volume relevante de vendas e taxa de devolução superior a 1%. Esses casos merecem investigação adicional, pois uma taxa elevada pode indicar um comportamento específico do produto que não aparece apenas observando o volume total vendido.

### Quais produtos e lojas apresentam mais vendas por dia ?
``` sql
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


SELECT
   store_nbr,
   ROUND((SUM(unit_sales)/@qtd_dias),2) AS 'Quantidade vendida por dias',
   ROUND(SUM(unit_sales),2) AS 'Vendas totais'
FROM vwVENDAS
GROUP BY store_nbr
ORDER BY SUM(unit_sales)/@qtd_dias DESC 
```
<img width="307" height="343" alt="image" src="https://github.com/user-attachments/assets/db67d2a2-05ac-4891-aa6d-f34041017464" />
<img width="410" height="340" alt="image" src="https://github.com/user-attachments/assets/01eb0542-090d-4fa6-b80e-ca34090bbc36" />

**Interpretação**
Esse indicador representa a quantidade média vendida por dia considerando todo o período do dataset. Ele não representa necessariamente a média apenas nos dias em que cada produto ou loja esteve ativo.
Por isso, produtos introduzidos posteriormente ou lojas que não operaram durante todo o período podem apresentar médias menores simplesmente por possuírem menos tempo de atividade.


Mesmo com essa limitação, o indicador é útil para identificar itens e lojas com maior demanda média durante o período analisado e pode servir como base para estudos posteriores de previsão de demanda e planejamento de estoque.


###  Promoções aumentam as vendas?
``` sql
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
```
<img width="685" height="102" alt="image" src="https://github.com/user-attachments/assets/d8e2bf20-651a-453f-a75b-b6c731cf7766" />

A maior parte dos registros ocorreu sem promoção ou sem informação de promoção, o que explica o maior volume total vendido nesses grupos.
Entretanto, nos resultados obtidos, a média de unit_sales por registro foi aproximadamente 66% maior nos registros em promoção.
Esse resultado mostra uma associação entre promoção e maior quantidade vendida por registro, mas não permite concluir, sozinho, que a promoção causou o aumento das vendas. Uma análise mais robusta pode comparar o mesmo produto em períodos com e sem promoção, controlando diferenças de demanda entre os itens.

##Quais meses/anos apresentam maior quantidade de vendas ?
``` sql
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
```
<img width="277" height="342" alt="image" src="https://github.com/user-attachments/assets/03dd26b2-560f-4f0a-ba81-3841ad4a96e0" />

O agrupamento por mês e ano permite identificar períodos de maior volume de vendas e é um primeiro passo para investigar sazonalidade.

8. Qual a quantidade média vendida em cada dia da semana ?

``` sql
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
```

<img width="280" height="196" alt="image" src="https://github.com/user-attachments/assets/70b14463-1d8b-4118-934d-a5cfea2eb111" />

Essa abordagem evita calcular simplesmente a média das linhas individuais. Primeiro, todas as vendas de uma mesma data são consolidadas e, somente depois, é calculada a média dos totais diários para cada dia da semana.



## Principais aprendizados
O projeto permitiu aplicar SQL a uma base com grande volume de registros e transformar dados transacionais em indicadores de negócio. Entre os principais pontos trabalhados estão:
- separação entre vendas e devoluções;
- uso de joins para enriquecer a análise com informações de lojas e produtos;
- criação de indicadores agregados por produto, loja, localidade e período;
- cálculo de taxa de devolução;
- construção de métricas de demanda média diária;
- análise descritiva do comportamento de vendas em promoção;
- análise temporal por mês, ano e dia da semana;
- interpretação dos resultados considerando as limitações das métricas utilizadas.
