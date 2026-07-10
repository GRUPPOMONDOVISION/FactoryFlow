-- FactoryFlow - aggiunta intervallo temporale evento produttivo
-- Database: DB_FARMFLOW

IF COL_LENGTH('dbo.FF_DICHIARAZIONI_PRODUZIONE', 'OraInizioProduzione') IS NULL
BEGIN
    ALTER TABLE dbo.FF_DICHIARAZIONI_PRODUZIONE
        ADD OraInizioProduzione datetime2(0) NULL;
END
GO

IF COL_LENGTH('dbo.FF_DICHIARAZIONI_PRODUZIONE', 'OraFineProduzione') IS NULL
BEGIN
    ALTER TABLE dbo.FF_DICHIARAZIONI_PRODUZIONE
        ADD OraFineProduzione datetime2(0) NULL;
END
GO

IF NOT EXISTS
(
    SELECT 1
    FROM sys.check_constraints
    WHERE name = 'CK_FF_DICHIARAZIONI_PRODUZIONE_Ore'
      AND parent_object_id = OBJECT_ID('dbo.FF_DICHIARAZIONI_PRODUZIONE')
)
BEGIN
    ALTER TABLE dbo.FF_DICHIARAZIONI_PRODUZIONE
        ADD CONSTRAINT CK_FF_DICHIARAZIONI_PRODUZIONE_Ore
        CHECK (OraInizioProduzione IS NULL OR OraFineProduzione IS NULL OR OraFineProduzione > OraInizioProduzione);
END
GO
