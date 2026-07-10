SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
SET XACT_ABORT ON;

IF COL_LENGTH('dbo.FF_OPERATORI', 'DataObsolescenza') IS NULL
    ALTER TABLE dbo.FF_OPERATORI ADD DataObsolescenza date NULL;

IF COL_LENGTH('dbo.FF_OPERATORI', 'MotivoObsolescenza') IS NULL
    ALTER TABLE dbo.FF_OPERATORI ADD MotivoObsolescenza varchar(255) NULL;

IF COL_LENGTH('dbo.FF_MACCHINE', 'ConsumoKwSpunto') IS NULL
    ALTER TABLE dbo.FF_MACCHINE ADD ConsumoKwSpunto decimal(18,4) NULL;

IF COL_LENGTH('dbo.FF_MACCHINE', 'ConsumoKwFunzione') IS NULL
    ALTER TABLE dbo.FF_MACCHINE ADD ConsumoKwFunzione decimal(18,4) NULL;

IF COL_LENGTH('dbo.FF_MACCHINE', 'UnitaMinutoBenchmark') IS NULL
    ALTER TABLE dbo.FF_MACCHINE ADD UnitaMinutoBenchmark decimal(18,6) NULL;

IF COL_LENGTH('dbo.FF_MACCHINE', 'NoteTecniche') IS NULL
    ALTER TABLE dbo.FF_MACCHINE ADD NoteTecniche varchar(500) NULL;

EXEC(N'
UPDATE dbo.FF_OPERATORI
SET DataObsolescenza = COALESCE(DataObsolescenza, CONVERT(date, DataModifica), CONVERT(date, GETDATE()))
WHERE Attivo = 0 AND DataObsolescenza IS NULL;
');
