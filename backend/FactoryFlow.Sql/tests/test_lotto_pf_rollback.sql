DECLARE @LottoPf varchar(20) = 'FFROLLBACK01';
DECLARE @json nvarchar(max) = N'[
  {"codice":"CHERRYAA","lotto":"439/F","magazzino":"MP","quantita":1800.000},
  {"codice":"COLOMBIASUPR","lotto":null,"magazzino":"MP","quantita":249.999},
  {"codice":"NICARAGUA","lotto":null,"magazzino":"MP","quantita":249.999},
  {"codice":"SANTOS MOGIANA","lotto":"436/B","magazzino":"MP","quantita":699.999}
]';

BEGIN TRAN;

EXEC dbo.sp_FactoryFlow_CreaDichiarazioneProduzione
    @CodAzi = 'MOROS',
    @Esercizio = 2023,
    @DataRilevazione = '20260630',
    @ArticoloProdotto = 'TOST/1',
    @LottoProdotto = @LottoPf,
    @MagazzinoProdotto = 'WP',
    @QuantitaProdotta = 3,
    @ComponentiJson = @json;

SELECT
    'LOTTIART_IN_TRAN' AS CheckName,
    RTRIM(LOCODART) AS Articolo,
    RTRIM(LOCODICE) AS Lotto,
    RTRIM(LOSERIAL) AS LOSERIAL,
    RTRIM(LOCODESE) AS Esercizio,
    LODATCRE,
    RTRIM(LOTIPCON) AS LOTIPCON,
    RTRIM(LOFLSTAT) AS LOFLSTAT
FROM MOROSLOTTIART
WHERE LOCODART = 'TOST/1'
  AND LOCODICE = @LottoPf;

SELECT
    'SALDILOT_IN_TRAN' AS CheckName,
    RTRIM(SUCODART) AS Articolo,
    RTRIM(SUCODMAG) AS Magazzino,
    RTRIM(SUCODLOT) AS Lotto,
    SUQTAPER,
    SUQTRPER
FROM MOROSSALDILOT
WHERE SUCODART = 'TOST/1'
  AND SUCODMAG = 'WP'
  AND SUCODLOT = @LottoPf;

ROLLBACK;

SELECT
    'LOTTIART_AFTER_ROLLBACK' AS CheckName,
    COUNT(*) AS Righe
FROM MOROSLOTTIART
WHERE LOCODART = 'TOST/1'
  AND LOCODICE = @LottoPf;

SELECT
    'SALDILOT_AFTER_ROLLBACK' AS CheckName,
    COUNT(*) AS Righe
FROM MOROSSALDILOT
WHERE SUCODART = 'TOST/1'
  AND SUCODMAG = 'WP'
  AND SUCODLOT = @LottoPf;
