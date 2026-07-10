/*
    FactoryFlow - Estensione costi produttivi e team operativo
    Regole architetturali:
    - nessuna FK verso AdHoc;
    - riferimenti AdHoc solo come codici esterni;
    - fotografia del contesto operativo salvata in DB_FARMFLOW;
    - costi calcolabili solo quando i dati sono sufficienti.
*/

IF OBJECT_ID(N'dbo.FF_OPERATORI', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.FF_OPERATORI
    (
        IdOperatore int IDENTITY(1,1) NOT NULL CONSTRAINT PK_FF_OPERATORI PRIMARY KEY,
        CodOperatore varchar(20) NOT NULL,
        Nome varchar(100) NOT NULL,
        Cognome varchar(100) NULL,
        FonteEsterna varchar(50) NULL,
        CodiceEsterno varchar(50) NULL,
        Attivo bit NOT NULL CONSTRAINT DF_FF_OPERATORI_Attivo DEFAULT (1),
        DataCreazione datetime2(0) NOT NULL CONSTRAINT DF_FF_OPERATORI_DataCreazione DEFAULT (SYSDATETIME()),
        DataModifica datetime2(0) NULL,
        UtenteCreazione varchar(50) NULL,
        UtenteModifica varchar(50) NULL
    );

    CREATE UNIQUE INDEX UX_FF_OPERATORI_CodOperatore ON dbo.FF_OPERATORI(CodOperatore);
    CREATE INDEX IX_FF_OPERATORI_Attivo ON dbo.FF_OPERATORI(Attivo, Cognome, Nome);
END;

IF OBJECT_ID(N'dbo.FF_RUOLI_OPERATIVI', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.FF_RUOLI_OPERATIVI
    (
        IdRuoloOperativo int IDENTITY(1,1) NOT NULL CONSTRAINT PK_FF_RUOLI_OPERATIVI PRIMARY KEY,
        CodRuolo varchar(20) NOT NULL,
        Descrizione varchar(100) NOT NULL,
        Attivo bit NOT NULL CONSTRAINT DF_FF_RUOLI_OPERATIVI_Attivo DEFAULT (1),
        DataCreazione datetime2(0) NOT NULL CONSTRAINT DF_FF_RUOLI_OPERATIVI_DataCreazione DEFAULT (SYSDATETIME()),
        DataModifica datetime2(0) NULL,
        UtenteCreazione varchar(50) NULL,
        UtenteModifica varchar(50) NULL
    );

    CREATE UNIQUE INDEX UX_FF_RUOLI_OPERATIVI_CodRuolo ON dbo.FF_RUOLI_OPERATIVI(CodRuolo);
END;

IF OBJECT_ID(N'dbo.FF_DICHIARAZIONI_OPERATORI', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.FF_DICHIARAZIONI_OPERATORI
    (
        IdDichiarazioneOperatore bigint IDENTITY(1,1) NOT NULL CONSTRAINT PK_FF_DICHIARAZIONI_OPERATORI PRIMARY KEY,
        IdDichiarazione bigint NOT NULL,
        IdOperatore int NULL,
        IdRuoloOperativo int NULL,
        CodOperatoreSnapshot varchar(20) NULL,
        NomeOperatoreSnapshot varchar(150) NULL,
        RuoloSnapshot varchar(100) NULL,
        OraInizio datetime2(0) NULL,
        OraFine datetime2(0) NULL,
        Note varchar(max) NULL,
        DataCreazione datetime2(0) NOT NULL CONSTRAINT DF_FF_DICHIARAZIONI_OPERATORI_DataCreazione DEFAULT (SYSDATETIME()),
        DataModifica datetime2(0) NULL,
        UtenteCreazione varchar(50) NULL,
        UtenteModifica varchar(50) NULL,
        CONSTRAINT FK_FF_DICHIARAZIONI_OPERATORI_DICHIARAZIONI FOREIGN KEY (IdDichiarazione) REFERENCES dbo.FF_DICHIARAZIONI_PRODUZIONE(IdDichiarazione),
        CONSTRAINT FK_FF_DICHIARAZIONI_OPERATORI_OPERATORI FOREIGN KEY (IdOperatore) REFERENCES dbo.FF_OPERATORI(IdOperatore),
        CONSTRAINT FK_FF_DICHIARAZIONI_OPERATORI_RUOLI FOREIGN KEY (IdRuoloOperativo) REFERENCES dbo.FF_RUOLI_OPERATIVI(IdRuoloOperativo),
        CONSTRAINT CK_FF_DICHIARAZIONI_OPERATORI_Ore CHECK (OraInizio IS NULL OR OraFine IS NULL OR OraFine > OraInizio)
    );

    CREATE INDEX IX_FF_DICHIARAZIONI_OPERATORI_Dichiarazione ON dbo.FF_DICHIARAZIONI_OPERATORI(IdDichiarazione);
    CREATE INDEX IX_FF_DICHIARAZIONI_OPERATORI_Operatore ON dbo.FF_DICHIARAZIONI_OPERATORI(IdOperatore, OraInizio, OraFine);
END;

IF OBJECT_ID(N'dbo.FF_MACCHINE', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.FF_MACCHINE
    (
        IdMacchina int IDENTITY(1,1) NOT NULL CONSTRAINT PK_FF_MACCHINE PRIMARY KEY,
        IdLinea int NULL,
        CodMacchina varchar(30) NOT NULL,
        NomeMacchina varchar(100) NOT NULL,
        Descrizione varchar(255) NULL,
        Attiva bit NOT NULL CONSTRAINT DF_FF_MACCHINE_Attiva DEFAULT (1),
        DataCreazione datetime2(0) NOT NULL CONSTRAINT DF_FF_MACCHINE_DataCreazione DEFAULT (SYSDATETIME()),
        DataModifica datetime2(0) NULL,
        UtenteCreazione varchar(50) NULL,
        UtenteModifica varchar(50) NULL,
        CONSTRAINT FK_FF_MACCHINE_LINEE FOREIGN KEY (IdLinea) REFERENCES dbo.FF_LINEE_LAVORAZIONE(IdLinea)
    );

    CREATE UNIQUE INDEX UX_FF_MACCHINE_CodMacchina ON dbo.FF_MACCHINE(CodMacchina);
    CREATE INDEX IX_FF_MACCHINE_Linea ON dbo.FF_MACCHINE(IdLinea, Attiva);
END;

IF OBJECT_ID(N'dbo.FF_SETUP_TIPI', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.FF_SETUP_TIPI
    (
        IdSetupTipo int IDENTITY(1,1) NOT NULL CONSTRAINT PK_FF_SETUP_TIPI PRIMARY KEY,
        CodSetupTipo varchar(30) NOT NULL,
        Descrizione varchar(150) NOT NULL,
        Attivo bit NOT NULL CONSTRAINT DF_FF_SETUP_TIPI_Attivo DEFAULT (1),
        DataCreazione datetime2(0) NOT NULL CONSTRAINT DF_FF_SETUP_TIPI_DataCreazione DEFAULT (SYSDATETIME()),
        DataModifica datetime2(0) NULL,
        UtenteCreazione varchar(50) NULL,
        UtenteModifica varchar(50) NULL
    );

    CREATE UNIQUE INDEX UX_FF_SETUP_TIPI_CodSetupTipo ON dbo.FF_SETUP_TIPI(CodSetupTipo);
END;

IF OBJECT_ID(N'dbo.FF_SETUP_REGOLE', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.FF_SETUP_REGOLE
    (
        IdSetupRegola int IDENTITY(1,1) NOT NULL CONSTRAINT PK_FF_SETUP_REGOLE PRIMARY KEY,
        IdSetupTipo int NOT NULL,
        IdLinea int NULL,
        IdMacchina int NULL,
        CodArticolo varchar(20) NULL,
        TempoStandardMinuti decimal(18,3) NULL,
        CostoStandard decimal(18,4) NULL,
        Priorita int NOT NULL CONSTRAINT DF_FF_SETUP_REGOLE_Priorita DEFAULT (100),
        Attiva bit NOT NULL CONSTRAINT DF_FF_SETUP_REGOLE_Attiva DEFAULT (1),
        DataCreazione datetime2(0) NOT NULL CONSTRAINT DF_FF_SETUP_REGOLE_DataCreazione DEFAULT (SYSDATETIME()),
        DataModifica datetime2(0) NULL,
        UtenteCreazione varchar(50) NULL,
        UtenteModifica varchar(50) NULL,
        CONSTRAINT FK_FF_SETUP_REGOLE_TIPI FOREIGN KEY (IdSetupTipo) REFERENCES dbo.FF_SETUP_TIPI(IdSetupTipo),
        CONSTRAINT FK_FF_SETUP_REGOLE_LINEE FOREIGN KEY (IdLinea) REFERENCES dbo.FF_LINEE_LAVORAZIONE(IdLinea),
        CONSTRAINT FK_FF_SETUP_REGOLE_MACCHINE FOREIGN KEY (IdMacchina) REFERENCES dbo.FF_MACCHINE(IdMacchina)
    );

    CREATE INDEX IX_FF_SETUP_REGOLE_Ricerca ON dbo.FF_SETUP_REGOLE(Attiva, IdLinea, IdMacchina, CodArticolo, Priorita);
END;

IF OBJECT_ID(N'dbo.FF_COSTI_LINEA', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.FF_COSTI_LINEA
    (
        IdCostoLinea int IDENTITY(1,1) NOT NULL CONSTRAINT PK_FF_COSTI_LINEA PRIMARY KEY,
        IdLinea int NOT NULL,
        IdMacchina int NULL,
        ValidoDal date NOT NULL,
        ValidoAl date NULL,
        CostoFissoOra decimal(18,4) NULL,
        CostoMacchinaOra decimal(18,4) NULL,
        CostoManodoperaOra decimal(18,4) NULL,
        CostoEnergiaOra decimal(18,4) NULL,
        CostoEnergiaUnita decimal(18,6) NULL,
        Note varchar(255) NULL,
        Attivo bit NOT NULL CONSTRAINT DF_FF_COSTI_LINEA_Attivo DEFAULT (1),
        DataCreazione datetime2(0) NOT NULL CONSTRAINT DF_FF_COSTI_LINEA_DataCreazione DEFAULT (SYSDATETIME()),
        DataModifica datetime2(0) NULL,
        UtenteCreazione varchar(50) NULL,
        UtenteModifica varchar(50) NULL,
        CONSTRAINT FK_FF_COSTI_LINEA_LINEE FOREIGN KEY (IdLinea) REFERENCES dbo.FF_LINEE_LAVORAZIONE(IdLinea),
        CONSTRAINT FK_FF_COSTI_LINEA_MACCHINE FOREIGN KEY (IdMacchina) REFERENCES dbo.FF_MACCHINE(IdMacchina),
        CONSTRAINT CK_FF_COSTI_LINEA_Periodo CHECK (ValidoAl IS NULL OR ValidoAl >= ValidoDal)
    );

    CREATE INDEX IX_FF_COSTI_LINEA_Ricerca ON dbo.FF_COSTI_LINEA(IdLinea, IdMacchina, Attivo, ValidoDal, ValidoAl);
END;

IF OBJECT_ID(N'dbo.FF_COSTI_ARTICOLO_LINEA', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.FF_COSTI_ARTICOLO_LINEA
    (
        IdCostoArticoloLinea int IDENTITY(1,1) NOT NULL CONSTRAINT PK_FF_COSTI_ARTICOLO_LINEA PRIMARY KEY,
        IdLinea int NOT NULL,
        IdMacchina int NULL,
        CodArticolo varchar(20) NOT NULL,
        ValidoDal date NOT NULL,
        ValidoAl date NULL,
        CostoVariabileUnita decimal(18,6) NULL,
        CostoVariabileOra decimal(18,4) NULL,
        TempoStandardMinutiUnita decimal(18,6) NULL,
        Note varchar(255) NULL,
        Attivo bit NOT NULL CONSTRAINT DF_FF_COSTI_ARTICOLO_LINEA_Attivo DEFAULT (1),
        DataCreazione datetime2(0) NOT NULL CONSTRAINT DF_FF_COSTI_ARTICOLO_LINEA_DataCreazione DEFAULT (SYSDATETIME()),
        DataModifica datetime2(0) NULL,
        UtenteCreazione varchar(50) NULL,
        UtenteModifica varchar(50) NULL,
        CONSTRAINT FK_FF_COSTI_ARTICOLO_LINEA_LINEE FOREIGN KEY (IdLinea) REFERENCES dbo.FF_LINEE_LAVORAZIONE(IdLinea),
        CONSTRAINT FK_FF_COSTI_ARTICOLO_LINEA_MACCHINE FOREIGN KEY (IdMacchina) REFERENCES dbo.FF_MACCHINE(IdMacchina),
        CONSTRAINT CK_FF_COSTI_ARTICOLO_LINEA_Periodo CHECK (ValidoAl IS NULL OR ValidoAl >= ValidoDal)
    );

    CREATE INDEX IX_FF_COSTI_ARTICOLO_LINEA_Ricerca ON dbo.FF_COSTI_ARTICOLO_LINEA(CodArticolo, IdLinea, IdMacchina, Attivo, ValidoDal, ValidoAl);
END;

IF OBJECT_ID(N'dbo.FF_METRICHE_PRODUZIONE', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.FF_METRICHE_PRODUZIONE
    (
        IdMetricaProduzione bigint IDENTITY(1,1) NOT NULL CONSTRAINT PK_FF_METRICHE_PRODUZIONE PRIMARY KEY,
        IdDichiarazione bigint NOT NULL,
        MinutiProduzione decimal(18,3) NULL,
        QuantitaMinuto decimal(18,6) NULL,
        NumeroOperatori int NULL,
        MinutiSetup decimal(18,3) NULL,
        EnergiaStimata decimal(18,6) NULL,
        DataCreazione datetime2(0) NOT NULL CONSTRAINT DF_FF_METRICHE_PRODUZIONE_DataCreazione DEFAULT (SYSDATETIME()),
        DataModifica datetime2(0) NULL,
        UtenteCreazione varchar(50) NULL,
        UtenteModifica varchar(50) NULL,
        CONSTRAINT FK_FF_METRICHE_PRODUZIONE_DICHIARAZIONI FOREIGN KEY (IdDichiarazione) REFERENCES dbo.FF_DICHIARAZIONI_PRODUZIONE(IdDichiarazione)
    );

    CREATE UNIQUE INDEX UX_FF_METRICHE_PRODUZIONE_Dichiarazione ON dbo.FF_METRICHE_PRODUZIONE(IdDichiarazione);
END;

IF OBJECT_ID(N'dbo.FF_COSTI_PRODUZIONE', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.FF_COSTI_PRODUZIONE
    (
        IdCostoProduzione bigint IDENTITY(1,1) NOT NULL CONSTRAINT PK_FF_COSTI_PRODUZIONE PRIMARY KEY,
        IdDichiarazione bigint NOT NULL,
        CostoFissoLinea decimal(18,4) NULL,
        CostoSetup decimal(18,4) NULL,
        CostoVariabileQuantita decimal(18,4) NULL,
        CostoVariabileTempo decimal(18,4) NULL,
        CostoEnergia decimal(18,4) NULL,
        CostoManodopera decimal(18,4) NULL,
        CostoMacchina decimal(18,4) NULL,
        CostoComponenti decimal(18,4) NULL,
        CostoIndustrialeTotale decimal(18,4) NULL,
        CostoIndustrialeUnitario decimal(18,6) NULL,
        CalcoloCompleto bit NOT NULL CONSTRAINT DF_FF_COSTI_PRODUZIONE_CalcoloCompleto DEFAULT (0),
        MotivoCalcoloIncompleto varchar(500) NULL,
        DataCalcolo datetime2(0) NOT NULL CONSTRAINT DF_FF_COSTI_PRODUZIONE_DataCalcolo DEFAULT (SYSDATETIME()),
        DataCreazione datetime2(0) NOT NULL CONSTRAINT DF_FF_COSTI_PRODUZIONE_DataCreazione DEFAULT (SYSDATETIME()),
        DataModifica datetime2(0) NULL,
        UtenteCreazione varchar(50) NULL,
        UtenteModifica varchar(50) NULL,
        CONSTRAINT FK_FF_COSTI_PRODUZIONE_DICHIARAZIONI FOREIGN KEY (IdDichiarazione) REFERENCES dbo.FF_DICHIARAZIONI_PRODUZIONE(IdDichiarazione)
    );

    CREATE UNIQUE INDEX UX_FF_COSTI_PRODUZIONE_Dichiarazione ON dbo.FF_COSTI_PRODUZIONE(IdDichiarazione);
END;
