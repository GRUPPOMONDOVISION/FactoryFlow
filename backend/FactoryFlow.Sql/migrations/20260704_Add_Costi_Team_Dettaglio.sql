/* FactoryFlow - Dettaglio costi team operativo */

IF COL_LENGTH('dbo.FF_OPERATORI', 'CostoOrarioRiferimento') IS NULL
BEGIN
    ALTER TABLE dbo.FF_OPERATORI
        ADD CostoOrarioRiferimento decimal(18,4) NULL;
END;

IF COL_LENGTH('dbo.FF_DICHIARAZIONI_OPERATORI', 'CostoOrarioApplicato') IS NULL
BEGIN
    ALTER TABLE dbo.FF_DICHIARAZIONI_OPERATORI
        ADD CostoOrarioApplicato decimal(18,4) NULL;
END;

IF COL_LENGTH('dbo.FF_DICHIARAZIONI_OPERATORI', 'CostoTotale') IS NULL
BEGIN
    ALTER TABLE dbo.FF_DICHIARAZIONI_OPERATORI
        ADD CostoTotale decimal(18,4) NULL;
END;
