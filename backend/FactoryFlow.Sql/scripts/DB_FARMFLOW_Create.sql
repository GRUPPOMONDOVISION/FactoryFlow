/*
    FactoryFlow - DB_FARMFLOW MVP

    Obiettivo:
    creare il nucleo minimo applicativo FactoryFlow senza duplicare dati master AdHoc.

    Regola:
    i codici articolo, magazzino, lotti e documenti AdHoc sono riferimenti esterni.
    Le descrizioni salvate nelle dichiarazioni sono snapshot storici dell'operazione,
    non anagrafiche parallele.
*/

IF DB_ID(N'DB_FARMFLOW') IS NULL
BEGIN
    CREATE DATABASE DB_FARMFLOW;
END
GO

USE DB_FARMFLOW;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

IF OBJECT_ID(N'dbo.FF_AUDIT_EVENTI', N'U') IS NOT NULL DROP TABLE dbo.FF_AUDIT_EVENTI;
IF OBJECT_ID(N'dbo.FF_DICHIARAZIONI_COMPONENTI', N'U') IS NOT NULL DROP TABLE dbo.FF_DICHIARAZIONI_COMPONENTI;
IF OBJECT_ID(N'dbo.FF_DICHIARAZIONI_PRODUZIONE', N'U') IS NOT NULL DROP TABLE dbo.FF_DICHIARAZIONI_PRODUZIONE;
IF OBJECT_ID(N'dbo.FF_LINEE_ARTICOLI', N'U') IS NOT NULL DROP TABLE dbo.FF_LINEE_ARTICOLI;
IF OBJECT_ID(N'dbo.FF_LINEE_LAVORAZIONE', N'U') IS NOT NULL DROP TABLE dbo.FF_LINEE_LAVORAZIONE;
IF OBJECT_ID(N'dbo.FF_CONFIG', N'U') IS NOT NULL DROP TABLE dbo.FF_CONFIG;
GO

CREATE TABLE dbo.FF_CONFIG
(
    IdConfig int IDENTITY(1,1) NOT NULL CONSTRAINT PK_FF_CONFIG PRIMARY KEY,
    CodAziAdhoc varchar(10) NOT NULL,
    PrefissoAzienda varchar(10) NOT NULL,
    CausaleCarico varchar(20) NOT NULL,
    CausaleScarico varchar(20) NOT NULL,
    MagazzinoPFDefault varchar(5) NOT NULL,
    MagazzinoComponentiDefault varchar(5) NOT NULL,
    Attiva bit NOT NULL CONSTRAINT DF_FF_CONFIG_Attiva DEFAULT (1),
    DataCreazione datetime NOT NULL CONSTRAINT DF_FF_CONFIG_DataCreazione DEFAULT (GETDATE()),
    DataModifica datetime NULL,
    UtenteCreazione varchar(50) NULL,
    UtenteModifica varchar(50) NULL
);
GO

CREATE UNIQUE INDEX UX_FF_CONFIG_Attiva
ON dbo.FF_CONFIG(CodAziAdhoc, PrefissoAzienda)
WHERE Attiva = 1;
GO

CREATE TABLE dbo.FF_LINEE_LAVORAZIONE
(
    IdLinea int IDENTITY(1,1) NOT NULL CONSTRAINT PK_FF_LINEE_LAVORAZIONE PRIMARY KEY,
    CodLinea varchar(20) NOT NULL,
    NomeLinea varchar(100) NOT NULL,
    DescrizioneFunzionale varchar(max) NULL,
    Attiva bit NOT NULL CONSTRAINT DF_FF_LINEE_LAVORAZIONE_Attiva DEFAULT (1),
    DataCreazione datetime NOT NULL CONSTRAINT DF_FF_LINEE_LAVORAZIONE_DataCreazione DEFAULT (GETDATE()),
    DataModifica datetime NULL,
    UtenteCreazione varchar(50) NULL,
    UtenteModifica varchar(50) NULL
);
GO

CREATE UNIQUE INDEX UX_FF_LINEE_LAVORAZIONE_CodLinea
ON dbo.FF_LINEE_LAVORAZIONE(CodLinea);
GO

CREATE TABLE dbo.FF_LINEE_ARTICOLI
(
    IdLineaArticolo int IDENTITY(1,1) NOT NULL CONSTRAINT PK_FF_LINEE_ARTICOLI PRIMARY KEY,
    IdLinea int NOT NULL,
    CodArticolo varchar(20) NOT NULL,
    QuantitaMinuto decimal(18,6) NULL,
    Attivo bit NOT NULL CONSTRAINT DF_FF_LINEE_ARTICOLI_Attivo DEFAULT (1),
    DataCreazione datetime NOT NULL CONSTRAINT DF_FF_LINEE_ARTICOLI_DataCreazione DEFAULT (GETDATE()),
    DataModifica datetime NULL,
    UtenteCreazione varchar(50) NULL,
    UtenteModifica varchar(50) NULL,
    CONSTRAINT FK_FF_LINEE_ARTICOLI_LINEE
        FOREIGN KEY (IdLinea) REFERENCES dbo.FF_LINEE_LAVORAZIONE(IdLinea)
);
GO

CREATE UNIQUE INDEX UX_FF_LINEE_ARTICOLI_LineaArticolo
ON dbo.FF_LINEE_ARTICOLI(IdLinea, CodArticolo);
GO

CREATE INDEX IX_FF_LINEE_ARTICOLI_CodArticolo
ON dbo.FF_LINEE_ARTICOLI(CodArticolo);
GO

CREATE TABLE dbo.FF_DICHIARAZIONI_PRODUZIONE
(
    IdDichiarazione bigint IDENTITY(1,1) NOT NULL CONSTRAINT PK_FF_DICHIARAZIONI_PRODUZIONE PRIMARY KEY,
    IdLinea int NULL,
    CodAziAdhoc varchar(10) NOT NULL,
    DataProduzione date NOT NULL,
    CodArticoloPF varchar(20) NOT NULL,
    DescrizionePF varchar(100) NULL,
    LottoPF varchar(30) NULL,
    MagazzinoPF varchar(5) NOT NULL,
    QuantitaProdotta decimal(18,3) NOT NULL,
    SerialeCaricoAdhoc varchar(10) NULL,
    NumeroCaricoAdhoc int NULL,
    SerialeScaricoAdhoc varchar(10) NULL,
    NumeroScaricoAdhoc int NULL,
    Stato varchar(20) NOT NULL CONSTRAINT DF_FF_DICHIARAZIONI_PRODUZIONE_Stato DEFAULT ('CONFERMATA'),
    CostoComponentiTotale decimal(18,6) NULL,
    CostoTotaleProduzione decimal(18,6) NULL,
    CostoUnitarioPF decimal(18,6) NULL,
    DataCreazione datetime NOT NULL CONSTRAINT DF_FF_DICHIARAZIONI_PRODUZIONE_DataCreazione DEFAULT (GETDATE()),
    DataModifica datetime NULL,
    UtenteCreazione varchar(50) NULL,
    UtenteModifica varchar(50) NULL,
    CONSTRAINT FK_FF_DICHIARAZIONI_PRODUZIONE_LINEE
        FOREIGN KEY (IdLinea) REFERENCES dbo.FF_LINEE_LAVORAZIONE(IdLinea),
    CONSTRAINT CK_FF_DICHIARAZIONI_PRODUZIONE_Qta
        CHECK (QuantitaProdotta > 0)
);
GO

CREATE INDEX IX_FF_DICHIARAZIONI_PRODUZIONE_DataArticolo
ON dbo.FF_DICHIARAZIONI_PRODUZIONE(DataProduzione, CodArticoloPF);
GO

CREATE UNIQUE INDEX UX_FF_DICHIARAZIONI_PRODUZIONE_SerialeCarico
ON dbo.FF_DICHIARAZIONI_PRODUZIONE(SerialeCaricoAdhoc)
WHERE SerialeCaricoAdhoc IS NOT NULL;
GO

CREATE UNIQUE INDEX UX_FF_DICHIARAZIONI_PRODUZIONE_SerialeScarico
ON dbo.FF_DICHIARAZIONI_PRODUZIONE(SerialeScaricoAdhoc)
WHERE SerialeScaricoAdhoc IS NOT NULL;
GO

CREATE TABLE dbo.FF_DICHIARAZIONI_COMPONENTI
(
    IdRiga bigint IDENTITY(1,1) NOT NULL CONSTRAINT PK_FF_DICHIARAZIONI_COMPONENTI PRIMARY KEY,
    IdDichiarazione bigint NOT NULL,
    CodComponente varchar(20) NOT NULL,
    DescrizioneComponente varchar(100) NULL,
    UnitaMisura varchar(5) NULL,
    QuantitaDistinta decimal(18,6) NULL,
    QuantitaProposta decimal(18,6) NULL,
    QuantitaEffettiva decimal(18,6) NOT NULL,
    Lotto varchar(30) NULL,
    Magazzino varchar(5) NOT NULL,
    CostoMedioPonderato decimal(18,6) NULL,
    CostoTotaleRiga decimal(18,6) NULL,
    DataCreazione datetime NOT NULL CONSTRAINT DF_FF_DICHIARAZIONI_COMPONENTI_DataCreazione DEFAULT (GETDATE()),
    DataModifica datetime NULL,
    UtenteCreazione varchar(50) NULL,
    UtenteModifica varchar(50) NULL,
    CONSTRAINT FK_FF_DICHIARAZIONI_COMPONENTI_PRODUZIONE
        FOREIGN KEY (IdDichiarazione) REFERENCES dbo.FF_DICHIARAZIONI_PRODUZIONE(IdDichiarazione),
    CONSTRAINT CK_FF_DICHIARAZIONI_COMPONENTI_Qta
        CHECK (QuantitaEffettiva >= 0)
);
GO

CREATE INDEX IX_FF_DICHIARAZIONI_COMPONENTI_Dichiarazione
ON dbo.FF_DICHIARAZIONI_COMPONENTI(IdDichiarazione);
GO

CREATE INDEX IX_FF_DICHIARAZIONI_COMPONENTI_Componente
ON dbo.FF_DICHIARAZIONI_COMPONENTI(CodComponente);
GO

CREATE TABLE dbo.FF_AUDIT_EVENTI
(
    IdAudit bigint IDENTITY(1,1) NOT NULL CONSTRAINT PK_FF_AUDIT_EVENTI PRIMARY KEY,
    Entita varchar(50) NOT NULL,
    IdEntita varchar(50) NULL,
    TipoEvento varchar(50) NOT NULL,
    Descrizione varchar(max) NULL,
    DataEvento datetime NOT NULL CONSTRAINT DF_FF_AUDIT_EVENTI_DataEvento DEFAULT (GETDATE()),
    Utente varchar(50) NULL
);
GO

CREATE INDEX IX_FF_AUDIT_EVENTI_Entita
ON dbo.FF_AUDIT_EVENTI(Entita, IdEntita);
GO

CREATE INDEX IX_FF_AUDIT_EVENTI_DataEvento
ON dbo.FF_AUDIT_EVENTI(DataEvento);
GO


