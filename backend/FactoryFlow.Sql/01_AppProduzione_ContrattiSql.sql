/*
    FactoryFlow - contratti SQL per lo sprint Dichiarazione Produzione.

    Le procedure sono richiamate dal backend FactoryFlow.Infrastructure.
    Adeguare il corpo alle tabelle AdHoc installate mantenendo invariati nomi,
    parametri e colonne restituite.
*/

CREATE OR ALTER PROCEDURE dbo.sp_AppProduzione_GetArticoliProducibili
    @DatabaseAdHoc NVARCHAR(128)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @sql NVARCHAR(MAX) = N'
        SELECT
            LTRIM(RTRIM(AR_CODART)) AS Codice,
            LTRIM(RTRIM(AR_DESART)) AS Descrizione,
            LTRIM(RTRIM(ISNULL(AR_UNMIS, ''''))) AS Um,
            LTRIM(RTRIM(ARCODDIS)) AS CodiceDistinta
        FROM ' + QUOTENAME(@DatabaseAdHoc) + N'.dbo.ART_ICOL
        WHERE ISNULL(LTRIM(RTRIM(ARCODDIS)), '''') <> ''''
        ORDER BY AR_CODART;';

    EXEC sys.sp_executesql @sql;
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_AppProduzione_GetDistinta
    @DatabaseAdHoc NVARCHAR(128),
    @CodArticolo VARCHAR(50),
    @Quantita DECIMAL(18, 6)
AS
BEGIN
    SET NOCOUNT ON;

    /*
        Sostituire questa SELECT con la lettura della distinta base AdHoc.
        Colonne obbligatorie:
        Codice, Descrizione, Um, QuantitaTeorica, QuantitaProposta, GestioneLotti.
    */
    SELECT
        CAST('' AS VARCHAR(50)) AS Codice,
        CAST('' AS VARCHAR(255)) AS Descrizione,
        CAST('' AS VARCHAR(10)) AS Um,
        CAST(0 AS DECIMAL(18, 6)) AS QuantitaTeorica,
        CAST(0 AS DECIMAL(18, 6)) AS QuantitaProposta,
        CAST(0 AS BIT) AS GestioneLotti
    WHERE 1 = 0;
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_AppProduzione_GetLottiDisponibili
    @DatabaseAdHoc NVARCHAR(128),
    @CodArticolo VARCHAR(50),
    @Magazzino VARCHAR(20),
    @DataProduzione DATE
AS
BEGIN
    SET NOCOUNT ON;

    /*
        Sostituire questa SELECT con la disponibilita lotti AdHoc.
        Restituire solo lotti con disponibilita positiva, ordinati per scadenza.
    */
    SELECT
        CAST('' AS VARCHAR(50)) AS CodiceLotto,
        CAST(0 AS DECIMAL(18, 6)) AS QuantitaDisponibile,
        CAST(NULL AS DATE) AS DataScadenza
    WHERE 1 = 0
    ORDER BY DataScadenza, CodiceLotto;
END;
GO

/*
    La procedura dbo.sp_FactoryFlow_CreaDichiarazioneProduzione e mantenuta in:

        stored/dbo.sp_FactoryFlow_CreaDichiarazioneProduzione.sql

    Il backend non ricostruisce la logica documentale in C#.
    Valida solo i dati minimi e passa testata + componenti JSON alla stored.
*/


