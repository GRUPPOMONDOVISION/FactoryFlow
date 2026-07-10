SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

/* FactoryFlow process-centric evolution.
   Additive and idempotent: no DROP, no FK to AdHoc. */

IF COL_LENGTH('dbo.FF_MACCHINE', 'Reparto') IS NULL ALTER TABLE dbo.FF_MACCHINE ADD Reparto varchar(100) NULL;
IF COL_LENGTH('dbo.FF_MACCHINE', 'Costruttore') IS NULL ALTER TABLE dbo.FF_MACCHINE ADD Costruttore varchar(100) NULL;
IF COL_LENGTH('dbo.FF_MACCHINE', 'Modello') IS NULL ALTER TABLE dbo.FF_MACCHINE ADD Modello varchar(100) NULL;
IF COL_LENGTH('dbo.FF_MACCHINE', 'Matricola') IS NULL ALTER TABLE dbo.FF_MACCHINE ADD Matricola varchar(100) NULL;
IF COL_LENGTH('dbo.FF_MACCHINE', 'AnnoInstallazione') IS NULL ALTER TABLE dbo.FF_MACCHINE ADD AnnoInstallazione int NULL;
IF COL_LENGTH('dbo.FF_MACCHINE', 'Stato') IS NULL ALTER TABLE dbo.FF_MACCHINE ADD Stato varchar(30) NULL;

IF COL_LENGTH('dbo.FF_MACCHINE', 'UnitaMisuraPrincipale') IS NULL ALTER TABLE dbo.FF_MACCHINE ADD UnitaMisuraPrincipale varchar(10) NULL;
IF COL_LENGTH('dbo.FF_MACCHINE', 'VelocitaNominale') IS NULL ALTER TABLE dbo.FF_MACCHINE ADD VelocitaNominale decimal(18,6) NULL;
IF COL_LENGTH('dbo.FF_MACCHINE', 'VelocitaOttimale') IS NULL ALTER TABLE dbo.FF_MACCHINE ADD VelocitaOttimale decimal(18,6) NULL;
IF COL_LENGTH('dbo.FF_MACCHINE', 'VelocitaMassima') IS NULL ALTER TABLE dbo.FF_MACCHINE ADD VelocitaMassima decimal(18,6) NULL;
IF COL_LENGTH('dbo.FF_MACCHINE', 'CapacitaMassimaTurno') IS NULL ALTER TABLE dbo.FF_MACCHINE ADD CapacitaMassimaTurno decimal(18,6) NULL;
IF COL_LENGTH('dbo.FF_MACCHINE', 'CapacitaMassimaGiornaliera') IS NULL ALTER TABLE dbo.FF_MACCHINE ADD CapacitaMassimaGiornaliera decimal(18,6) NULL;
IF COL_LENGTH('dbo.FF_MACCHINE', 'CapacitaMassimaSettimanale') IS NULL ALTER TABLE dbo.FF_MACCHINE ADD CapacitaMassimaSettimanale decimal(18,6) NULL;
IF COL_LENGTH('dbo.FF_MACCHINE', 'TempoMinimoLottoMinuti') IS NULL ALTER TABLE dbo.FF_MACCHINE ADD TempoMinimoLottoMinuti decimal(18,3) NULL;
IF COL_LENGTH('dbo.FF_MACCHINE', 'TempoMassimoLottoMinuti') IS NULL ALTER TABLE dbo.FF_MACCHINE ADD TempoMassimoLottoMinuti decimal(18,3) NULL;

IF COL_LENGTH('dbo.FF_MACCHINE', 'CostoAmmortamentoOra') IS NULL ALTER TABLE dbo.FF_MACCHINE ADD CostoAmmortamentoOra decimal(18,4) NULL;
IF COL_LENGTH('dbo.FF_MACCHINE', 'CostoManutenzioneOra') IS NULL ALTER TABLE dbo.FF_MACCHINE ADD CostoManutenzioneOra decimal(18,4) NULL;
IF COL_LENGTH('dbo.FF_MACCHINE', 'CostoEnergiaVuotoOra') IS NULL ALTER TABLE dbo.FF_MACCHINE ADD CostoEnergiaVuotoOra decimal(18,4) NULL;
IF COL_LENGTH('dbo.FF_MACCHINE', 'CostoEnergiaProduzioneOra') IS NULL ALTER TABLE dbo.FF_MACCHINE ADD CostoEnergiaProduzioneOra decimal(18,4) NULL;
IF COL_LENGTH('dbo.FF_MACCHINE', 'CostoLubrificantiOra') IS NULL ALTER TABLE dbo.FF_MACCHINE ADD CostoLubrificantiOra decimal(18,4) NULL;
IF COL_LENGTH('dbo.FF_MACCHINE', 'CostoUtensiliOra') IS NULL ALTER TABLE dbo.FF_MACCHINE ADD CostoUtensiliOra decimal(18,4) NULL;
IF COL_LENGTH('dbo.FF_MACCHINE', 'CostoPuliziaOra') IS NULL ALTER TABLE dbo.FF_MACCHINE ADD CostoPuliziaOra decimal(18,4) NULL;
IF COL_LENGTH('dbo.FF_MACCHINE', 'CostoFermoMacchinaOra') IS NULL ALTER TABLE dbo.FF_MACCHINE ADD CostoFermoMacchinaOra decimal(18,4) NULL;
IF COL_LENGTH('dbo.FF_MACCHINE', 'CostoOccupazioneSpazioOra') IS NULL ALTER TABLE dbo.FF_MACCHINE ADD CostoOccupazioneSpazioOra decimal(18,4) NULL;

IF COL_LENGTH('dbo.FF_MACCHINE', 'TempoRiscaldamentoMinuti') IS NULL ALTER TABLE dbo.FF_MACCHINE ADD TempoRiscaldamentoMinuti decimal(18,3) NULL;
IF COL_LENGTH('dbo.FF_MACCHINE', 'TempoRaffreddamentoMinuti') IS NULL ALTER TABLE dbo.FF_MACCHINE ADD TempoRaffreddamentoMinuti decimal(18,3) NULL;
IF COL_LENGTH('dbo.FF_MACCHINE', 'TempoCambioFormatoStandardMinuti') IS NULL ALTER TABLE dbo.FF_MACCHINE ADD TempoCambioFormatoStandardMinuti decimal(18,3) NULL;
IF COL_LENGTH('dbo.FF_MACCHINE', 'TempoPuliziaStandardMinuti') IS NULL ALTER TABLE dbo.FF_MACCHINE ADD TempoPuliziaStandardMinuti decimal(18,3) NULL;
IF COL_LENGTH('dbo.FF_MACCHINE', 'TempoSanificazioneMinuti') IS NULL ALTER TABLE dbo.FF_MACCHINE ADD TempoSanificazioneMinuti decimal(18,3) NULL;
IF COL_LENGTH('dbo.FF_MACCHINE', 'TempoSetupBaseMinuti') IS NULL ALTER TABLE dbo.FF_MACCHINE ADD TempoSetupBaseMinuti decimal(18,3) NULL;
IF COL_LENGTH('dbo.FF_MACCHINE', 'TempoAvviamentoMinuti') IS NULL ALTER TABLE dbo.FF_MACCHINE ADD TempoAvviamentoMinuti decimal(18,3) NULL;
IF COL_LENGTH('dbo.FF_MACCHINE', 'TempoArrestoMinuti') IS NULL ALTER TABLE dbo.FF_MACCHINE ADD TempoArrestoMinuti decimal(18,3) NULL;
GO

UPDATE dbo.FF_MACCHINE
SET Stato = COALESCE(Stato, CASE WHEN Attiva = 1 THEN 'ATTIVA' ELSE 'OBSOLETA' END);
GO

IF OBJECT_ID(N'dbo.FF_PROCESSI_PRODUTTIVI', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.FF_PROCESSI_PRODUTTIVI
    (
        IdProcesso int IDENTITY(1,1) NOT NULL CONSTRAINT PK_FF_PROCESSI_PRODUTTIVI PRIMARY KEY,
        CodProcesso varchar(40) NOT NULL,
        CodArticolo varchar(30) NULL,
        Descrizione varchar(200) NOT NULL,
        Note varchar(500) NULL,
        Stato varchar(20) NOT NULL CONSTRAINT DF_FF_PROCESSI_PRODUTTIVI_Stato DEFAULT ('BOZZA'),
        DataCreazione datetime2(0) NOT NULL CONSTRAINT DF_FF_PROCESSI_PRODUTTIVI_DataCreazione DEFAULT (SYSDATETIME()),
        DataModifica datetime2(0) NULL,
        UtenteCreazione varchar(50) NULL,
        UtenteModifica varchar(50) NULL
    );
    CREATE UNIQUE INDEX UX_FF_PROCESSI_PRODUTTIVI_CodProcesso ON dbo.FF_PROCESSI_PRODUTTIVI(CodProcesso);
    CREATE INDEX IX_FF_PROCESSI_PRODUTTIVI_Articolo ON dbo.FF_PROCESSI_PRODUTTIVI(CodArticolo, Stato);
END;
GO

IF OBJECT_ID(N'dbo.FF_PROCESSI_VERSIONI', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.FF_PROCESSI_VERSIONI
    (
        IdVersione int IDENTITY(1,1) NOT NULL CONSTRAINT PK_FF_PROCESSI_VERSIONI PRIMARY KEY,
        IdProcesso int NOT NULL,
        NumeroVersione int NOT NULL,
        Descrizione varchar(200) NULL,
        Motivazione varchar(500) NULL,
        ValidoDal date NOT NULL,
        ValidoAl date NULL,
        Stato varchar(20) NOT NULL CONSTRAINT DF_FF_PROCESSI_VERSIONI_Stato DEFAULT ('BOZZA'),
        TempoAttesoMinuti decimal(18,3) NULL,
        SetupAttesoMinuti decimal(18,3) NULL,
        ProduttivitaAttesa decimal(18,6) NULL,
        CostoAtteso decimal(18,4) NULL,
        EnergiaAttesa decimal(18,6) NULL,
        DataCreazione datetime2(0) NOT NULL CONSTRAINT DF_FF_PROCESSI_VERSIONI_DataCreazione DEFAULT (SYSDATETIME()),
        DataModifica datetime2(0) NULL,
        UtenteCreazione varchar(50) NULL,
        UtenteModifica varchar(50) NULL,
        CONSTRAINT FK_FF_PROCESSI_VERSIONI_PROCESSI FOREIGN KEY (IdProcesso) REFERENCES dbo.FF_PROCESSI_PRODUTTIVI(IdProcesso),
        CONSTRAINT CK_FF_PROCESSI_VERSIONI_Periodo CHECK (ValidoAl IS NULL OR ValidoAl >= ValidoDal)
    );
    CREATE UNIQUE INDEX UX_FF_PROCESSI_VERSIONI_Numero ON dbo.FF_PROCESSI_VERSIONI(IdProcesso, NumeroVersione);
    CREATE INDEX IX_FF_PROCESSI_VERSIONI_Valida ON dbo.FF_PROCESSI_VERSIONI(IdProcesso, ValidoDal, ValidoAl, Stato);
END;
GO

IF OBJECT_ID(N'dbo.FF_PROCESSI_FASI', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.FF_PROCESSI_FASI
    (
        IdFase int IDENTITY(1,1) NOT NULL CONSTRAINT PK_FF_PROCESSI_FASI PRIMARY KEY,
        IdVersione int NOT NULL,
        Sequenza int NOT NULL,
        CodFase varchar(40) NOT NULL,
        Descrizione varchar(200) NOT NULL,
        IdLineaDefault int NULL,
        IdMacchinaDefault int NULL,
        TempoStandardMinuti decimal(18,3) NULL,
        SetupStandardMinuti decimal(18,3) NULL,
        ProduttivitaAttesa decimal(18,6) NULL,
        CostoStandard decimal(18,4) NULL,
        EnergiaAttesa decimal(18,6) NULL,
        QualitaAttesa decimal(9,4) NULL,
        ScartoAtteso decimal(9,4) NULL,
        Note varchar(500) NULL,
        DataCreazione datetime2(0) NOT NULL CONSTRAINT DF_FF_PROCESSI_FASI_DataCreazione DEFAULT (SYSDATETIME()),
        DataModifica datetime2(0) NULL,
        UtenteCreazione varchar(50) NULL,
        UtenteModifica varchar(50) NULL,
        CONSTRAINT FK_FF_PROCESSI_FASI_VERSIONI FOREIGN KEY (IdVersione) REFERENCES dbo.FF_PROCESSI_VERSIONI(IdVersione),
        CONSTRAINT FK_FF_PROCESSI_FASI_LINEE FOREIGN KEY (IdLineaDefault) REFERENCES dbo.FF_LINEE_LAVORAZIONE(IdLinea),
        CONSTRAINT FK_FF_PROCESSI_FASI_MACCHINE FOREIGN KEY (IdMacchinaDefault) REFERENCES dbo.FF_MACCHINE(IdMacchina)
    );
    CREATE UNIQUE INDEX UX_FF_PROCESSI_FASI_Sequenza ON dbo.FF_PROCESSI_FASI(IdVersione, Sequenza);
END;
GO

IF OBJECT_ID(N'dbo.FF_PROCESSI_FASI_RISORSE', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.FF_PROCESSI_FASI_RISORSE
    (
        IdFaseRisorsa int IDENTITY(1,1) NOT NULL CONSTRAINT PK_FF_PROCESSI_FASI_RISORSE PRIMARY KEY,
        IdFase int NOT NULL,
        IdLinea int NULL,
        IdMacchina int NULL,
        IdTeam int NULL,
        ValidoDal date NOT NULL,
        ValidoAl date NULL,
        VelocitaReale decimal(18,6) NULL,
        TempoSetupAggiuntivoMinuti decimal(18,3) NULL,
        ScartoMedio decimal(9,4) NULL,
        EnergiaAggiuntiva decimal(18,6) NULL,
        OperatoriMinimi int NULL,
        OperatoriConsigliati int NULL,
        CompetenzeRichieste varchar(500) NULL,
        Note varchar(500) NULL,
        DataCreazione datetime2(0) NOT NULL CONSTRAINT DF_FF_PROCESSI_FASI_RISORSE_DataCreazione DEFAULT (SYSDATETIME()),
        DataModifica datetime2(0) NULL,
        UtenteCreazione varchar(50) NULL,
        UtenteModifica varchar(50) NULL,
        CONSTRAINT FK_FF_PROCESSI_FASI_RISORSE_FASI FOREIGN KEY (IdFase) REFERENCES dbo.FF_PROCESSI_FASI(IdFase),
        CONSTRAINT FK_FF_PROCESSI_FASI_RISORSE_LINEE FOREIGN KEY (IdLinea) REFERENCES dbo.FF_LINEE_LAVORAZIONE(IdLinea),
        CONSTRAINT FK_FF_PROCESSI_FASI_RISORSE_MACCHINE FOREIGN KEY (IdMacchina) REFERENCES dbo.FF_MACCHINE(IdMacchina),
        CONSTRAINT FK_FF_PROCESSI_FASI_RISORSE_TEAM FOREIGN KEY (IdTeam) REFERENCES dbo.FF_TEAM_OPERATIVI(IdTeam),
        CONSTRAINT CK_FF_PROCESSI_FASI_RISORSE_Periodo CHECK (ValidoAl IS NULL OR ValidoAl >= ValidoDal)
    );
    CREATE INDEX IX_FF_PROCESSI_FASI_RISORSE_Fase ON dbo.FF_PROCESSI_FASI_RISORSE(IdFase, ValidoDal, ValidoAl);
END;
GO

IF OBJECT_ID(N'dbo.FF_ATTIVITA_PRODUTTIVE', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.FF_ATTIVITA_PRODUTTIVE
    (
        IdAttivita bigint IDENTITY(1,1) NOT NULL CONSTRAINT PK_FF_ATTIVITA_PRODUTTIVE PRIMARY KEY,
        IdVersione int NOT NULL,
        IdDichiarazione bigint NULL,
        DataProduzione date NOT NULL,
        Stato varchar(20) NOT NULL CONSTRAINT DF_FF_ATTIVITA_PRODUTTIVE_Stato DEFAULT ('PREVISTA'),
        CodArticolo varchar(30) NOT NULL,
        QuantitaPrevista decimal(18,6) NULL,
        QuantitaConsuntivata decimal(18,6) NULL,
        IdLinea int NULL,
        IdMacchina int NULL,
        IdTeam int NULL,
        OraInizio datetime2(0) NULL,
        OraFine datetime2(0) NULL,
        Note varchar(500) NULL,
        DataCreazione datetime2(0) NOT NULL CONSTRAINT DF_FF_ATTIVITA_PRODUTTIVE_DataCreazione DEFAULT (SYSDATETIME()),
        DataModifica datetime2(0) NULL,
        UtenteCreazione varchar(50) NULL,
        UtenteModifica varchar(50) NULL,
        CONSTRAINT FK_FF_ATTIVITA_PRODUTTIVE_VERSIONI FOREIGN KEY (IdVersione) REFERENCES dbo.FF_PROCESSI_VERSIONI(IdVersione),
        CONSTRAINT FK_FF_ATTIVITA_PRODUTTIVE_DICHIARAZIONI FOREIGN KEY (IdDichiarazione) REFERENCES dbo.FF_DICHIARAZIONI_PRODUZIONE(IdDichiarazione),
        CONSTRAINT FK_FF_ATTIVITA_PRODUTTIVE_LINEE FOREIGN KEY (IdLinea) REFERENCES dbo.FF_LINEE_LAVORAZIONE(IdLinea),
        CONSTRAINT FK_FF_ATTIVITA_PRODUTTIVE_MACCHINE FOREIGN KEY (IdMacchina) REFERENCES dbo.FF_MACCHINE(IdMacchina),
        CONSTRAINT FK_FF_ATTIVITA_PRODUTTIVE_TEAM FOREIGN KEY (IdTeam) REFERENCES dbo.FF_TEAM_OPERATIVI(IdTeam),
        CONSTRAINT CK_FF_ATTIVITA_PRODUTTIVE_Ore CHECK (OraInizio IS NULL OR OraFine IS NULL OR OraFine > OraInizio)
    );
    CREATE INDEX IX_FF_ATTIVITA_PRODUTTIVE_Data ON dbo.FF_ATTIVITA_PRODUTTIVE(DataProduzione, Stato);
    CREATE INDEX IX_FF_ATTIVITA_PRODUTTIVE_Versione ON dbo.FF_ATTIVITA_PRODUTTIVE(IdVersione, DataProduzione);
END;
GO

IF OBJECT_ID(N'dbo.FF_ATTIVITA_METRICHE', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.FF_ATTIVITA_METRICHE
    (
        IdMetrica bigint IDENTITY(1,1) NOT NULL CONSTRAINT PK_FF_ATTIVITA_METRICHE PRIMARY KEY,
        IdAttivita bigint NOT NULL,
        TempoRealeMinuti decimal(18,3) NULL,
        SetupRealeMinuti decimal(18,3) NULL,
        ProduttivitaReale decimal(18,6) NULL,
        CostoReale decimal(18,4) NULL,
        EnergiaReale decimal(18,6) NULL,
        ScartoReale decimal(9,4) NULL,
        QualitaReale decimal(9,4) NULL,
        CalcoloCompleto bit NOT NULL CONSTRAINT DF_FF_ATTIVITA_METRICHE_CalcoloCompleto DEFAULT (0),
        MotivoCalcoloIncompleto varchar(500) NULL,
        DataCalcolo datetime2(0) NOT NULL CONSTRAINT DF_FF_ATTIVITA_METRICHE_DataCalcolo DEFAULT (SYSDATETIME()),
        CONSTRAINT FK_FF_ATTIVITA_METRICHE_ATTIVITA FOREIGN KEY (IdAttivita) REFERENCES dbo.FF_ATTIVITA_PRODUTTIVE(IdAttivita)
    );
    CREATE UNIQUE INDEX UX_FF_ATTIVITA_METRICHE_Attivita ON dbo.FF_ATTIVITA_METRICHE(IdAttivita);
END;
GO

IF OBJECT_ID(N'dbo.FF_ATTIVITA_SCOSTAMENTI', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.FF_ATTIVITA_SCOSTAMENTI
    (
        IdScostamento bigint IDENTITY(1,1) NOT NULL CONSTRAINT PK_FF_ATTIVITA_SCOSTAMENTI PRIMARY KEY,
        IdAttivita bigint NOT NULL,
        ScostamentoProduttivita decimal(18,6) NULL,
        ScostamentoProduttivitaPercentuale decimal(9,4) NULL,
        ScostamentoCosto decimal(18,4) NULL,
        ScostamentoCostoPercentuale decimal(9,4) NULL,
        ScostamentoTempoMinuti decimal(18,3) NULL,
        ScostamentoSetupMinuti decimal(18,3) NULL,
        ScostamentoEnergia decimal(18,6) NULL,
        ScostamentoScarto decimal(9,4) NULL,
        MotivoCalcoloIncompleto varchar(500) NULL,
        DataCalcolo datetime2(0) NOT NULL CONSTRAINT DF_FF_ATTIVITA_SCOSTAMENTI_DataCalcolo DEFAULT (SYSDATETIME()),
        CONSTRAINT FK_FF_ATTIVITA_SCOSTAMENTI_ATTIVITA FOREIGN KEY (IdAttivita) REFERENCES dbo.FF_ATTIVITA_PRODUTTIVE(IdAttivita)
    );
    CREATE UNIQUE INDEX UX_FF_ATTIVITA_SCOSTAMENTI_Attivita ON dbo.FF_ATTIVITA_SCOSTAMENTI(IdAttivita);
END;
GO

IF OBJECT_ID(N'dbo.FF_PROCESSI_MODIFICHE', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.FF_PROCESSI_MODIFICHE
    (
        IdModifica bigint IDENTITY(1,1) NOT NULL CONSTRAINT PK_FF_PROCESSI_MODIFICHE PRIMARY KEY,
        IdProcesso int NOT NULL,
        IdVersioneDa int NULL,
        IdVersioneA int NULL,
        TipoModifica varchar(50) NOT NULL,
        Descrizione varchar(1000) NOT NULL,
        Motivazione varchar(1000) NOT NULL,
        DataModifica datetime2(0) NOT NULL CONSTRAINT DF_FF_PROCESSI_MODIFICHE_DataModifica DEFAULT (SYSDATETIME()),
        Utente varchar(50) NULL,
        CONSTRAINT FK_FF_PROCESSI_MODIFICHE_PROCESSI FOREIGN KEY (IdProcesso) REFERENCES dbo.FF_PROCESSI_PRODUTTIVI(IdProcesso),
        CONSTRAINT FK_FF_PROCESSI_MODIFICHE_VERSIONE_DA FOREIGN KEY (IdVersioneDa) REFERENCES dbo.FF_PROCESSI_VERSIONI(IdVersione),
        CONSTRAINT FK_FF_PROCESSI_MODIFICHE_VERSIONE_A FOREIGN KEY (IdVersioneA) REFERENCES dbo.FF_PROCESSI_VERSIONI(IdVersione)
    );
    CREATE INDEX IX_FF_PROCESSI_MODIFICHE_Processo ON dbo.FF_PROCESSI_MODIFICHE(IdProcesso, DataModifica DESC);
END;
GO
