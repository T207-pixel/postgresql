SELECT * FROM beers; --пиво Е1
SELECT * FROM breweries; --пивоварня Е2
SELECT * FROM institutions; --заведение Е8
SELECT * FROM invoices; --накладная поступления Е6
SELECT * FROM positioncontractaboutpurchases; --позиция накладной поступления Е15
SELECT * FROM positionInvoicePurchases; --позиция договора о закупках Е16
SELECT * FROM purchasecontracts; --договор о закупках Е3
SELECT * FROM supplycontracts; --договор о поставках Е9
SELECT * FROM supplyitems; --позиция поставки Е17
SELECT * FROM warehouses; --склад Е7

WITH breweriesTmpT AS(
    SELECT  pc.purchasecontractid AS id,
            b.breweryname AS breweryname
    FROM purchasecontracts AS pc
    INNER JOIN breweries AS b ON b.breweryid = pc.breweryid
), invoicesTmpT AS(
    SELECT  COUNT(i.invoiceid) AS invoicesQuantity,
            MAX(i.invoicedate) AS latestDate,
            i.purchasecontractid AS id
    FROM invoices AS i
    INNER JOIN purchasecontracts AS pc ON pc.purchasecontractid = i.purchasecontractid
    GROUP BY i.purchasecontractid
), breweriesInvoicesJTmp AS( --таблица, в которой содержится id_договора_о_закупках + название_пивоварни + количество_накладных_по_этому_договору + дата_самой_последней_накладной_по_договору
    SELECT  b.id AS purchaseId,
        b.breweryname,
        i.invoicesQuantity,
        i.latestDate
FROM breweriesTmpT AS b
LEFT JOIN invoicesTmpT AS i ON b.id = i.id
), E15E3 AS( --E15 + E3 (кол-во товара из E15 для одного договора)
    SELECT  SUM(pip.productquantiy) AS productQuantitySum,
            pc.purchasecontractid AS contractId
    FROM positioncontractaboutpurchases AS pip
    RIGHT JOIN purchasecontracts AS pc ON pc.purchasecontractid = pip.purchasecontractid
    GROUP BY pc.purchasecontractid
), E6E3 AS( --E6 + E3 (кол-во товара из E6 для одного договора)
    SELECT  SUM(i.quantity) AS invoicedProductsQuantity,
            pc.purchasecontractid AS contractId
    FROM purchasecontracts AS pc
    LEFT JOIN invoices AS i ON i.purchasecontractid = pc.purchasecontractid
    GROUP BY pc.purchasecontractid
), signTmp AS( --признак (да/нет), одинаковое ли количество товара пришло
    SELECT  t1.contractId AS purchaseId,
            t2.contractId AS invoiceId,
            CASE
                WHEN t1.productQuantitySum = t2.invoicedProductsQuantity THEN 'YES'
                ELSE 'NO'
            END
    FROM E15E3 AS t1
    INNER JOIN E6E3 AS t2 ON t1.contractId = t2.contractId
)
SELECT  b.purchaseId,
        b.breweryname,
        b.invoicesQuantity,
        s.case AS sign,
        b.latestDate
FROM breweriesInvoicesJTmp AS b
INNER JOIN signTmp AS s ON s.purchaseId = b.purchaseId;




















INSERT INTO PurchaseContracts(BreweryId, ContractDate, ContractTotalUS)
VALUES(1, '2023-03-03', '50000'),
      (1, '2023-04-03', '40000'),
      (3, '2023-05-03', '30000');

INSERT INTO Invoices(WareHouseId, PurchaseContractId, Quantity, GoodsCost)
VALUES(1, 1, 14738, '3000');
    --(1, 3, 45, '3000'),
    --(1, 5, 12, '20333');

INSERT INTO PositionContractAboutPurchases(PurchaseId, PurchaseContractId, BeerId, ProductQuantiy)
VALUES(4, 2, 3, 3456),
      (5, 3, 3, 5644),
      (6, 2, 3, 3456),
      (7, 3, 3, 5644),
      (8, 2, 3, 3456),
      (9, 5, 3, 5644),
      (10, 4, 2, 5643);

