SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

IF OBJECT_ID(N'dbo.FF_TEAM_OPERATIVI', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.FF_TEAM_OPERATIVI
    (
        IdTeam int IDENTITY(1,1) NOT NULL CONSTRAINT PK_FF_TEAM_OPERATIVI PRIMARY KEY,
        CodTeam varchar(30) NOT NULL,
        Descrizione varchar(150) NOT NULL,
        Note varchar(255) NULL,
        Attivo bit NOT NULL CONSTRAINT DF_FF_TEAM_OPERATIVI_Attivo DEFAULT (1),
        DataCreazione datetime2(0) NOT NULL CONSTRAINT DF_FF_TEAM_OPERATIVI_DataCreazione DEFAULT (SYSDATETIME()),
        DataModifica datetime2(0) NULL,
        UtenteCreazione varchar(50) NULL,
        UtenteModifica varchar(50) NULL
    );

    CREATE UNIQUE INDEX UX_FF_TEAM_OPERATIVI_CodTeam ON dbo.FF_TEAM_OPERATIVI(CodTeam);
    CREATE INDEX IX_FF_TEAM_OPERATIVI_Attivo ON dbo.FF_TEAM_OPERATIVI(Attivo, CodTeam);
END;

IF OBJECT_ID(N'dbo.FF_TEAM_OPERATORI', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.FF_TEAM_OPERATORI
    (
        IdTeamOperatore int IDENTITY(1,1) NOT NULL CONSTRAINT PK_FF_TEAM_OPERATORI PRIMARY KEY,
        IdTeam int NOT NULL,
        IdOperatore int NOT NULL,
        IdRuoloOperativo int NULL,
        CostoOrarioApplicato decimal(18,4) NULL,
        Note varchar(255) NULL,
        Attivo bit NOT NULL CONSTRAINT DF_FF_TEAM_OPERATORI_Attivo DEFAULT (1),
        DataCreazione datetime2(0) NOT NULL CONSTRAINT DF_FF_TEAM_OPERATORI_DataCreazione DEFAULT (SYSDATETIME()),
        DataModifica datetime2(0) NULL,
        UtenteCreazione varchar(50) NULL,
        UtenteModifica varchar(50) NULL,
        CONSTRAINT FK_FF_TEAM_OPERATORI_TEAM FOREIGN KEY (IdTeam) REFERENCES dbo.FF_TEAM_OPERATIVI(IdTeam),
        CONSTRAINT FK_FF_TEAM_OPERATORI_OPERATORI FOREIGN KEY (IdOperatore) REFERENCES dbo.FF_OPERATORI(IdOperatore),
        CONSTRAINT FK_FF_TEAM_OPERATORI_RUOLI FOREIGN KEY (IdRuoloOperativo) REFERENCES dbo.FF_RUOLI_OPERATIVI(IdRuoloOperativo)
    );

    CREATE INDEX IX_FF_TEAM_OPERATORI_Team ON dbo.FF_TEAM_OPERATORI(IdTeam, Attivo);
    CREATE INDEX IX_FF_TEAM_OPERATORI_Operatore ON dbo.FF_TEAM_OPERATORI(IdOperatore, Attivo);
END;
