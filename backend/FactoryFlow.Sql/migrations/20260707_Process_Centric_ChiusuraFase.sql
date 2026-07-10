SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

/* FactoryFlow - process-centric alignment.
   Additive, idempotent, no DROP, no changes to AdHoc stored procedure. */

IF OBJECT_ID(N'dbo.FF_PROCESSI_FASI_REQUISITI', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.FF_PROCESSI_FASI_REQUISITI
    (
        IdFase int NOT NULL CONSTRAINT PK_FF_PROCESSI_FASI_REQUISITI PRIMARY KEY,
        RichiedeMacchina bit NOT NULL CONSTRAINT DF_FF_FASI_REQ_RichiedeMacchina DEFAULT (0),
        RichiedeTeam bit NOT NULL CONSTRAINT DF_FF_FASI_REQ_RichiedeTeam DEFAULT (0),
        RichiedeSetup bit NOT NULL CONSTRAINT DF_FF_FASI_REQ_RichiedeSetup DEFAULT (0),
        RichiedeOrari bit NOT NULL CONSTRAINT DF_FF_FASI_REQ_RichiedeOrari DEFAULT (1),
        RichiedeArticolo bit NOT NULL CONSTRAINT DF_FF_FASI_REQ_RichiedeArticolo DEFAULT (0),
        RichiedeLotto bit NOT NULL CONSTRAINT DF_FF_FASI_REQ_RichiedeLotto DEFAULT (0),
        RichiedeComponenti bit NOT NULL CONSTRAINT DF_FF_FASI_REQ_RichiedeComponenti DEFAULT (0),
        RichiedeControlloQualita bit NOT NULL CONSTRAINT DF_FF_FASI_REQ_RichiedeControlloQualita DEFAULT (0),
        RichiedeNote bit NOT NULL CONSTRAINT DF_FF_FASI_REQ_RichiedeNote DEFAULT (0),
        GeneraErp bit NOT NULL CONSTRAINT DF_FF_FASI_REQ_GeneraErp DEFAULT (0),
        GeneraCaricoPf bit NOT NULL CONSTRAINT DF_FF_FASI_REQ_GeneraCaricoPf DEFAULT (0),
        GeneraScaricoComponenti bit NOT NULL CONSTRAINT DF_FF_FASI_REQ_GeneraScaricoComponenti DEFAULT (0),
        DataCreazione datetime2(0) NOT NULL CONSTRAINT DF_FF_FASI_REQ_DataCreazione DEFAULT (SYSDATETIME()),
        DataModifica datetime2(0) NULL,
        UtenteCreazione varchar(50) NULL,
        UtenteModifica varchar(50) NULL,
        CONSTRAINT FK_FF_FASI_REQ_FASI FOREIGN KEY (IdFase) REFERENCES dbo.FF_PROCESSI_FASI(IdFase)
    );
END;
GO

IF COL_LENGTH('dbo.FF_ATTIVITA_PRODUTTIVE', 'IdFase') IS NULL
    ALTER TABLE dbo.FF_ATTIVITA_PRODUTTIVE ADD IdFase int NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_FF_ATTIVITA_PRODUTTIVE_FASI' AND parent_object_id = OBJECT_ID('dbo.FF_ATTIVITA_PRODUTTIVE'))
    ALTER TABLE dbo.FF_ATTIVITA_PRODUTTIVE ADD CONSTRAINT FK_FF_ATTIVITA_PRODUTTIVE_FASI FOREIGN KEY (IdFase) REFERENCES dbo.FF_PROCESSI_FASI(IdFase);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_FF_ATTIVITA_PRODUTTIVE_Fase' AND object_id = OBJECT_ID('dbo.FF_ATTIVITA_PRODUTTIVE'))
    CREATE INDEX IX_FF_ATTIVITA_PRODUTTIVE_Fase ON dbo.FF_ATTIVITA_PRODUTTIVE(IdFase, DataProduzione, Stato);
GO

IF OBJECT_ID(N'dbo.FF_CHIUSURE_FASE', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.FF_CHIUSURE_FASE
    (
        IdChiusuraFase bigint IDENTITY(1,1) NOT NULL CONSTRAINT PK_FF_CHIUSURE_FASE PRIMARY KEY,
        IdAttivita bigint NULL,
        IdFase int NOT NULL,
        IdDichiarazione bigint NULL,
        DataChiusura date NOT NULL,
        Stato varchar(20) NOT NULL CONSTRAINT DF_FF_CHIUSURE_FASE_Stato DEFAULT ('CONSUNTIVATA'),
        IdLinea int NULL,
        IdMacchina int NULL,
        IdTeam int NULL,
        OraInizio datetime2(0) NULL,
        OraFine datetime2(0) NULL,
        CodArticolo varchar(30) NULL,
        DescrizioneArticolo varchar(200) NULL,
        Lotto varchar(50) NULL,
        Magazzino varchar(10) NULL,
        Quantita decimal(18,6) NULL,
        EsitoQualita varchar(30) NULL,
        Note varchar(1000) NULL,
        GeneratoErp bit NOT NULL CONSTRAINT DF_FF_CHIUSURE_FASE_GeneratoErp DEFAULT (0),
        SerialCaricoAdhoc varchar(20) NULL,
        NumeroCaricoAdhoc int NULL,
        SerialScaricoAdhoc varchar(20) NULL,
        NumeroScaricoAdhoc int NULL,
        DataCreazione datetime2(0) NOT NULL CONSTRAINT DF_FF_CHIUSURE_FASE_DataCreazione DEFAULT (SYSDATETIME()),
        DataModifica datetime2(0) NULL,
        UtenteCreazione varchar(50) NULL,
        UtenteModifica varchar(50) NULL,
        CONSTRAINT FK_FF_CHIUSURE_FASE_ATTIVITA FOREIGN KEY (IdAttivita) REFERENCES dbo.FF_ATTIVITA_PRODUTTIVE(IdAttivita),
        CONSTRAINT FK_FF_CHIUSURE_FASE_FASI FOREIGN KEY (IdFase) REFERENCES dbo.FF_PROCESSI_FASI(IdFase),
        CONSTRAINT FK_FF_CHIUSURE_FASE_DICHIARAZIONI FOREIGN KEY (IdDichiarazione) REFERENCES dbo.FF_DICHIARAZIONI_PRODUZIONE(IdDichiarazione),
        CONSTRAINT FK_FF_CHIUSURE_FASE_LINEE FOREIGN KEY (IdLinea) REFERENCES dbo.FF_LINEE_LAVORAZIONE(IdLinea),
        CONSTRAINT FK_FF_CHIUSURE_FASE_MACCHINE FOREIGN KEY (IdMacchina) REFERENCES dbo.FF_MACCHINE(IdMacchina),
        CONSTRAINT FK_FF_CHIUSURE_FASE_TEAM FOREIGN KEY (IdTeam) REFERENCES dbo.FF_TEAM_OPERATIVI(IdTeam),
        CONSTRAINT CK_FF_CHIUSURE_FASE_Ore CHECK (OraInizio IS NULL OR OraFine IS NULL OR OraFine > OraInizio)
    );
    CREATE INDEX IX_FF_CHIUSURE_FASE_Data ON dbo.FF_CHIUSURE_FASE(DataChiusura, Stato);
    CREATE INDEX IX_FF_CHIUSURE_FASE_Fase ON dbo.FF_CHIUSURE_FASE(IdFase, DataChiusura);
END;
GO

IF OBJECT_ID(N'dbo.FF_CHIUSURE_FASE_COMPONENTI', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.FF_CHIUSURE_FASE_COMPONENTI
    (
        IdRiga bigint IDENTITY(1,1) NOT NULL CONSTRAINT PK_FF_CHIUSURE_FASE_COMPONENTI PRIMARY KEY,
        IdChiusuraFase bigint NOT NULL,
        CodComponente varchar(30) NOT NULL,
        DescrizioneComponente varchar(200) NULL,
        UnitaMisura varchar(10) NULL,
        Quantita decimal(18,6) NOT NULL,
        Lotto varchar(50) NULL,
        Magazzino varchar(10) NULL,
        DisponibilitaLotto decimal(18,6) NULL,
        DataScadenza date NULL,
        DataCreazione datetime2(0) NOT NULL CONSTRAINT DF_FF_CHIUSURE_FASE_COMP_DataCreazione DEFAULT (SYSDATETIME()),
        CONSTRAINT FK_FF_CHIUSURE_FASE_COMP_CHIUSURA FOREIGN KEY (IdChiusuraFase) REFERENCES dbo.FF_CHIUSURE_FASE(IdChiusuraFase)
    );
    CREATE INDEX IX_FF_CHIUSURE_FASE_COMP_Chiusura ON dbo.FF_CHIUSURE_FASE_COMPONENTI(IdChiusuraFase);
END;
GO

IF OBJECT_ID(N'dbo.FF_CHIUSURE_FASE_TEAM', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.FF_CHIUSURE_FASE_TEAM
    (
        IdRiga bigint IDENTITY(1,1) NOT NULL CONSTRAINT PK_FF_CHIUSURE_FASE_TEAM PRIMARY KEY,
        IdChiusuraFase bigint NOT NULL,
        IdOperatore int NULL,
        IdRuoloOperativo int NULL,
        NomeOperatoreSnapshot varchar(200) NULL,
        RuoloSnapshot varchar(100) NULL,
        CostoOrarioApplicato decimal(18,4) NULL,
        OraInizio datetime2(0) NULL,
        OraFine datetime2(0) NULL,
        Note varchar(500) NULL,
        DataCreazione datetime2(0) NOT NULL CONSTRAINT DF_FF_CHIUSURE_FASE_TEAM_DataCreazione DEFAULT (SYSDATETIME()),
        CONSTRAINT FK_FF_CHIUSURE_FASE_TEAM_CHIUSURA FOREIGN KEY (IdChiusuraFase) REFERENCES dbo.FF_CHIUSURE_FASE(IdChiusuraFase),
        CONSTRAINT FK_FF_CHIUSURE_FASE_TEAM_OPERATORI FOREIGN KEY (IdOperatore) REFERENCES dbo.FF_OPERATORI(IdOperatore),
        CONSTRAINT FK_FF_CHIUSURE_FASE_TEAM_RUOLI FOREIGN KEY (IdRuoloOperativo) REFERENCES dbo.FF_RUOLI_OPERATIVI(IdRuoloOperativo)
    );
    CREATE INDEX IX_FF_CHIUSURE_FASE_TEAM_Chiusura ON dbo.FF_CHIUSURE_FASE_TEAM(IdChiusuraFase);
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_FF_ProcessiFasiRequisiti_Get
    @IdFase int
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM dbo.FF_PROCESSI_FASI_REQUISITI WHERE IdFase = @IdFase)
    BEGIN
        INSERT INTO dbo.FF_PROCESSI_FASI_REQUISITI
            (IdFase, RichiedeMacchina, RichiedeTeam, RichiedeSetup, RichiedeOrari,
             RichiedeArticolo, RichiedeLotto, RichiedeComponenti, RichiedeControlloQualita,
             RichiedeNote, GeneraErp, GeneraCaricoPf, GeneraScaricoComponenti, UtenteCreazione)
        VALUES
            (@IdFase, 1, 1, 0, 1, 1, 1, 1, 0, 0, 1, 1, 1, 'FactoryFlow');
    END;

    SELECT IdFase, RichiedeMacchina, RichiedeTeam, RichiedeSetup, RichiedeOrari,
           RichiedeArticolo, RichiedeLotto, RichiedeComponenti, RichiedeControlloQualita,
           RichiedeNote, GeneraErp, GeneraCaricoPf, GeneraScaricoComponenti
    FROM dbo.FF_PROCESSI_FASI_REQUISITI
    WHERE IdFase = @IdFase;
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_FF_ProcessiFasiRequisiti_Save
    @IdFase int,
    @RichiedeMacchina bit = 0,
    @RichiedeTeam bit = 0,
    @RichiedeSetup bit = 0,
    @RichiedeOrari bit = 1,
    @RichiedeArticolo bit = 0,
    @RichiedeLotto bit = 0,
    @RichiedeComponenti bit = 0,
    @RichiedeControlloQualita bit = 0,
    @RichiedeNote bit = 0,
    @GeneraErp bit = 0,
    @GeneraCaricoPf bit = 0,
    @GeneraScaricoComponenti bit = 0,
    @Utente varchar(50) = 'FactoryFlow'
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM dbo.FF_PROCESSI_FASI WHERE IdFase = @IdFase)
        THROW 51000, 'Fase processo non trovata.', 1;

    IF @GeneraErp = 1
    BEGIN
        SET @RichiedeArticolo = 1;
        SET @RichiedeLotto = 1;
        SET @RichiedeComponenti = 1;
        SET @GeneraCaricoPf = 1;
        SET @GeneraScaricoComponenti = 1;
    END;

    MERGE dbo.FF_PROCESSI_FASI_REQUISITI AS T
    USING (SELECT @IdFase AS IdFase) AS S
       ON T.IdFase = S.IdFase
    WHEN MATCHED THEN
        UPDATE SET RichiedeMacchina=@RichiedeMacchina,
                   RichiedeTeam=@RichiedeTeam,
                   RichiedeSetup=@RichiedeSetup,
                   RichiedeOrari=@RichiedeOrari,
                   RichiedeArticolo=@RichiedeArticolo,
                   RichiedeLotto=@RichiedeLotto,
                   RichiedeComponenti=@RichiedeComponenti,
                   RichiedeControlloQualita=@RichiedeControlloQualita,
                   RichiedeNote=@RichiedeNote,
                   GeneraErp=@GeneraErp,
                   GeneraCaricoPf=@GeneraCaricoPf,
                   GeneraScaricoComponenti=@GeneraScaricoComponenti,
                   DataModifica=SYSDATETIME(),
                   UtenteModifica=@Utente
    WHEN NOT MATCHED THEN
        INSERT (IdFase, RichiedeMacchina, RichiedeTeam, RichiedeSetup, RichiedeOrari, RichiedeArticolo,
                RichiedeLotto, RichiedeComponenti, RichiedeControlloQualita, RichiedeNote, GeneraErp,
                GeneraCaricoPf, GeneraScaricoComponenti, UtenteCreazione)
        VALUES (@IdFase, @RichiedeMacchina, @RichiedeTeam, @RichiedeSetup, @RichiedeOrari, @RichiedeArticolo,
                @RichiedeLotto, @RichiedeComponenti, @RichiedeControlloQualita, @RichiedeNote, @GeneraErp,
                @GeneraCaricoPf, @GeneraScaricoComponenti, @Utente);

    -- Nessun resultset: questa SP viene chiamata dentro il salvataggio fase.
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_FF_ChiusureFase_Save
    @IdChiusuraFase bigint = NULL,
    @IdAttivita bigint = NULL,
    @IdFase int,
    @IdDichiarazione bigint = NULL,
    @DataChiusura date,
    @Stato varchar(20) = 'CONSUNTIVATA',
    @IdLinea int = NULL,
    @IdMacchina int = NULL,
    @IdTeam int = NULL,
    @OraInizio datetime2(0) = NULL,
    @OraFine datetime2(0) = NULL,
    @CodArticolo varchar(30) = NULL,
    @DescrizioneArticolo varchar(200) = NULL,
    @Lotto varchar(50) = NULL,
    @Magazzino varchar(10) = NULL,
    @Quantita decimal(18,6) = NULL,
    @EsitoQualita varchar(30) = NULL,
    @Note varchar(1000) = NULL,
    @GeneratoErp bit = 0,
    @SerialCaricoAdhoc varchar(20) = NULL,
    @NumeroCaricoAdhoc int = NULL,
    @SerialScaricoAdhoc varchar(20) = NULL,
    @NumeroScaricoAdhoc int = NULL,
    @Utente varchar(50) = 'FactoryFlow'
AS
BEGIN
    SET NOCOUNT ON;

    IF @IdChiusuraFase IS NULL OR NOT EXISTS (SELECT 1 FROM dbo.FF_CHIUSURE_FASE WHERE IdChiusuraFase=@IdChiusuraFase)
    BEGIN
        INSERT INTO dbo.FF_CHIUSURE_FASE
            (IdAttivita, IdFase, IdDichiarazione, DataChiusura, Stato, IdLinea, IdMacchina, IdTeam,
             OraInizio, OraFine, CodArticolo, DescrizioneArticolo, Lotto, Magazzino, Quantita,
             EsitoQualita, Note, GeneratoErp, SerialCaricoAdhoc, NumeroCaricoAdhoc, SerialScaricoAdhoc, NumeroScaricoAdhoc, UtenteCreazione)
        VALUES
            (@IdAttivita, @IdFase, @IdDichiarazione, @DataChiusura, @Stato, @IdLinea, @IdMacchina, @IdTeam,
             @OraInizio, @OraFine, @CodArticolo, @DescrizioneArticolo, @Lotto, @Magazzino, @Quantita,
             @EsitoQualita, @Note, @GeneratoErp, @SerialCaricoAdhoc, @NumeroCaricoAdhoc, @SerialScaricoAdhoc, @NumeroScaricoAdhoc, @Utente);
        SET @IdChiusuraFase = CONVERT(bigint, SCOPE_IDENTITY());
    END
    ELSE
    BEGIN
        UPDATE dbo.FF_CHIUSURE_FASE
        SET IdAttivita=@IdAttivita,
            IdFase=@IdFase,
            IdDichiarazione=@IdDichiarazione,
            DataChiusura=@DataChiusura,
            Stato=@Stato,
            IdLinea=@IdLinea,
            IdMacchina=@IdMacchina,
            IdTeam=@IdTeam,
            OraInizio=@OraInizio,
            OraFine=@OraFine,
            CodArticolo=@CodArticolo,
            DescrizioneArticolo=@DescrizioneArticolo,
            Lotto=@Lotto,
            Magazzino=@Magazzino,
            Quantita=@Quantita,
            EsitoQualita=@EsitoQualita,
            Note=@Note,
            GeneratoErp=@GeneratoErp,
            SerialCaricoAdhoc=@SerialCaricoAdhoc,
            NumeroCaricoAdhoc=@NumeroCaricoAdhoc,
            SerialScaricoAdhoc=@SerialScaricoAdhoc,
            NumeroScaricoAdhoc=@NumeroScaricoAdhoc,
            DataModifica=SYSDATETIME(),
            UtenteModifica=@Utente
        WHERE IdChiusuraFase=@IdChiusuraFase;
    END;

    SELECT * FROM dbo.FF_CHIUSURE_FASE WHERE IdChiusuraFase=@IdChiusuraFase;
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_FF_ProcessiFasi_List @IdVersione int
AS
BEGIN
    SET NOCOUNT ON;
    SELECT F.IdFase, F.IdVersione, F.Sequenza, F.CodFase, F.Descrizione,
           F.IdLineaDefault, L.CodLinea, L.NomeLinea, F.IdMacchinaDefault, M.CodMacchina, M.NomeMacchina,
           F.TempoStandardMinuti, F.SetupStandardMinuti, F.ProduttivitaAttesa, F.CostoStandard, F.EnergiaAttesa, F.QualitaAttesa, F.ScartoAtteso, F.Note,
           COALESCE(R.RichiedeMacchina, CONVERT(bit, 1)) AS RichiedeMacchina,
           COALESCE(R.RichiedeTeam, CONVERT(bit, 1)) AS RichiedeTeam,
           COALESCE(R.RichiedeSetup, CONVERT(bit, 0)) AS RichiedeSetup,
           COALESCE(R.RichiedeOrari, CONVERT(bit, 1)) AS RichiedeOrari,
           COALESCE(R.RichiedeArticolo, CONVERT(bit, 1)) AS RichiedeArticolo,
           COALESCE(R.RichiedeLotto, CONVERT(bit, 1)) AS RichiedeLotto,
           COALESCE(R.RichiedeComponenti, CONVERT(bit, 1)) AS RichiedeComponenti,
           COALESCE(R.RichiedeControlloQualita, CONVERT(bit, 0)) AS RichiedeControlloQualita,
           COALESCE(R.RichiedeNote, CONVERT(bit, 0)) AS RichiedeNote,
           COALESCE(R.GeneraErp, CONVERT(bit, 1)) AS GeneraErp,
           COALESCE(R.GeneraCaricoPf, CONVERT(bit, 1)) AS GeneraCaricoPf,
           COALESCE(R.GeneraScaricoComponenti, CONVERT(bit, 1)) AS GeneraScaricoComponenti
    FROM dbo.FF_PROCESSI_FASI F
    LEFT JOIN dbo.FF_LINEE_LAVORAZIONE L ON L.IdLinea = F.IdLineaDefault
    LEFT JOIN dbo.FF_MACCHINE M ON M.IdMacchina = F.IdMacchinaDefault
    LEFT JOIN dbo.FF_PROCESSI_FASI_REQUISITI R ON R.IdFase = F.IdFase
    WHERE F.IdVersione = @IdVersione
    ORDER BY F.Sequenza;
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_FF_ProcessiFasi_Save
    @IdFase int = NULL,
    @IdVersione int,
    @Sequenza int,
    @CodFase varchar(40),
    @Descrizione varchar(200),
    @IdLineaDefault int = NULL,
    @IdMacchinaDefault int = NULL,
    @TempoStandardMinuti decimal(18,3) = NULL,
    @SetupStandardMinuti decimal(18,3) = NULL,
    @ProduttivitaAttesa decimal(18,6) = NULL,
    @CostoStandard decimal(18,4) = NULL,
    @EnergiaAttesa decimal(18,6) = NULL,
    @QualitaAttesa decimal(9,4) = NULL,
    @ScartoAtteso decimal(9,4) = NULL,
    @Note varchar(500) = NULL,
    @RichiedeMacchina bit = 1,
    @RichiedeTeam bit = 1,
    @RichiedeSetup bit = 0,
    @RichiedeOrari bit = 1,
    @RichiedeArticolo bit = 1,
    @RichiedeLotto bit = 1,
    @RichiedeComponenti bit = 1,
    @RichiedeControlloQualita bit = 0,
    @RichiedeNote bit = 0,
    @GeneraErp bit = 1,
    @GeneraCaricoPf bit = 1,
    @GeneraScaricoComponenti bit = 1,
    @Utente varchar(50) = 'FactoryFlow'
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM dbo.FF_ATTIVITA_PRODUTTIVE WHERE IdVersione = @IdVersione)
    BEGIN
        RAISERROR('Versione processo gia utilizzata: creare una nuova versione per modificare le fasi operative.', 16, 1);
        RETURN;
    END;

    IF @IdFase IS NOT NULL AND EXISTS (SELECT 1 FROM dbo.FF_PROCESSI_FASI WHERE IdFase=@IdFase AND IdVersione<>@IdVersione)
    BEGIN
        RAISERROR('La fase non appartiene alla versione indicata.', 16, 1);
        RETURN;
    END;

    IF @GeneraErp = 1
    BEGIN
        SET @RichiedeArticolo = 1;
        SET @RichiedeLotto = 1;
        SET @RichiedeComponenti = 1;
        SET @GeneraCaricoPf = 1;
        SET @GeneraScaricoComponenti = 1;
    END;

    IF @IdFase IS NULL OR NOT EXISTS (SELECT 1 FROM dbo.FF_PROCESSI_FASI WHERE IdFase=@IdFase)
    BEGIN
        INSERT INTO dbo.FF_PROCESSI_FASI (IdVersione, Sequenza, CodFase, Descrizione, IdLineaDefault, IdMacchinaDefault, TempoStandardMinuti, SetupStandardMinuti, ProduttivitaAttesa, CostoStandard, EnergiaAttesa, QualitaAttesa, ScartoAtteso, Note, UtenteCreazione)
        VALUES (@IdVersione, @Sequenza, @CodFase, @Descrizione, @IdLineaDefault, @IdMacchinaDefault, @TempoStandardMinuti, @SetupStandardMinuti, @ProduttivitaAttesa, @CostoStandard, @EnergiaAttesa, @QualitaAttesa, @ScartoAtteso, @Note, @Utente);
        SET @IdFase = CONVERT(int, SCOPE_IDENTITY());
    END
    ELSE
    BEGIN
        UPDATE dbo.FF_PROCESSI_FASI
        SET Sequenza=@Sequenza, CodFase=@CodFase, Descrizione=@Descrizione, IdLineaDefault=@IdLineaDefault, IdMacchinaDefault=@IdMacchinaDefault,
            TempoStandardMinuti=@TempoStandardMinuti, SetupStandardMinuti=@SetupStandardMinuti, ProduttivitaAttesa=@ProduttivitaAttesa, CostoStandard=@CostoStandard,
            EnergiaAttesa=@EnergiaAttesa, QualitaAttesa=@QualitaAttesa, ScartoAtteso=@ScartoAtteso, Note=@Note, DataModifica=SYSDATETIME(), UtenteModifica=@Utente
        WHERE IdFase=@IdFase;
    END;

    EXEC dbo.sp_FF_ProcessiFasiRequisiti_Save
        @IdFase=@IdFase,
        @RichiedeMacchina=@RichiedeMacchina,
        @RichiedeTeam=@RichiedeTeam,
        @RichiedeSetup=@RichiedeSetup,
        @RichiedeOrari=@RichiedeOrari,
        @RichiedeArticolo=@RichiedeArticolo,
        @RichiedeLotto=@RichiedeLotto,
        @RichiedeComponenti=@RichiedeComponenti,
        @RichiedeControlloQualita=@RichiedeControlloQualita,
        @RichiedeNote=@RichiedeNote,
        @GeneraErp=@GeneraErp,
        @GeneraCaricoPf=@GeneraCaricoPf,
        @GeneraScaricoComponenti=@GeneraScaricoComponenti,
        @Utente=@Utente;

    EXEC dbo.sp_FF_ProcessiFasi_List @IdVersione=@IdVersione;
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_FF_AttivitaProduttive_List
    @Dal date = NULL,
    @Al date = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET @Dal = COALESCE(@Dal, DATEADD(day, -30, CAST(GETDATE() AS date)));
    SET @Al = COALESCE(@Al, DATEADD(day, 30, CAST(GETDATE() AS date)));

    SELECT A.IdAttivita, A.IdVersione, A.IdFase, F.CodFase, F.Descrizione AS FaseDescrizione,
           V.IdProcesso, P.CodProcesso, P.Descrizione AS ProcessoDescrizione,
           A.IdDichiarazione, A.DataProduzione, A.Stato, A.CodArticolo, A.QuantitaPrevista, A.QuantitaConsuntivata,
           A.IdLinea, L.CodLinea, L.NomeLinea, A.IdMacchina, M.CodMacchina, M.NomeMacchina, A.IdTeam, T.CodTeam,
           A.OraInizio, A.OraFine, A.Note
    FROM dbo.FF_ATTIVITA_PRODUTTIVE A
    INNER JOIN dbo.FF_PROCESSI_VERSIONI V ON V.IdVersione = A.IdVersione
    INNER JOIN dbo.FF_PROCESSI_PRODUTTIVI P ON P.IdProcesso = V.IdProcesso
    LEFT JOIN dbo.FF_PROCESSI_FASI F ON F.IdFase = A.IdFase
    LEFT JOIN dbo.FF_LINEE_LAVORAZIONE L ON L.IdLinea = A.IdLinea
    LEFT JOIN dbo.FF_MACCHINE M ON M.IdMacchina = A.IdMacchina
    LEFT JOIN dbo.FF_TEAM_OPERATIVI T ON T.IdTeam = A.IdTeam
    WHERE A.DataProduzione BETWEEN @Dal AND @Al
    ORDER BY A.DataProduzione DESC, A.IdAttivita DESC;
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_FF_AttivitaProduttive_Save
    @IdAttivita bigint = NULL,
    @IdVersione int,
    @IdFase int = NULL,
    @IdDichiarazione bigint = NULL,
    @DataProduzione date,
    @Stato varchar(20) = 'PREVISTA',
    @CodArticolo varchar(30) = NULL,
    @QuantitaPrevista decimal(18,6) = NULL,
    @QuantitaConsuntivata decimal(18,6) = NULL,
    @IdLinea int = NULL,
    @IdMacchina int = NULL,
    @IdTeam int = NULL,
    @OraInizio datetime2(0) = NULL,
    @OraFine datetime2(0) = NULL,
    @Note varchar(500) = NULL,
    @Utente varchar(50) = 'FactoryFlow'
AS
BEGIN
    SET NOCOUNT ON;

    IF @IdFase IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.FF_PROCESSI_FASI WHERE IdFase=@IdFase AND IdVersione=@IdVersione)
        THROW 51000, 'La fase non appartiene alla versione processo indicata.', 1;

    IF @IdAttivita IS NULL OR NOT EXISTS (SELECT 1 FROM dbo.FF_ATTIVITA_PRODUTTIVE WHERE IdAttivita=@IdAttivita)
    BEGIN
        INSERT INTO dbo.FF_ATTIVITA_PRODUTTIVE
            (IdVersione, IdFase, IdDichiarazione, DataProduzione, Stato, CodArticolo, QuantitaPrevista, QuantitaConsuntivata,
             IdLinea, IdMacchina, IdTeam, OraInizio, OraFine, Note, UtenteCreazione)
        VALUES
            (@IdVersione, @IdFase, @IdDichiarazione, @DataProduzione, @Stato, COALESCE(@CodArticolo, ''), @QuantitaPrevista, @QuantitaConsuntivata,
             @IdLinea, @IdMacchina, @IdTeam, @OraInizio, @OraFine, @Note, @Utente);
        SET @IdAttivita = CONVERT(bigint, SCOPE_IDENTITY());
    END
    ELSE
    BEGIN
        UPDATE dbo.FF_ATTIVITA_PRODUTTIVE
        SET IdVersione=@IdVersione, IdFase=@IdFase, IdDichiarazione=@IdDichiarazione, DataProduzione=@DataProduzione, Stato=@Stato, CodArticolo=COALESCE(@CodArticolo, ''),
            QuantitaPrevista=@QuantitaPrevista, QuantitaConsuntivata=@QuantitaConsuntivata, IdLinea=@IdLinea, IdMacchina=@IdMacchina,
            IdTeam=@IdTeam, OraInizio=@OraInizio, OraFine=@OraFine, Note=@Note, DataModifica=SYSDATETIME(), UtenteModifica=@Utente
        WHERE IdAttivita=@IdAttivita;
    END;

    SELECT A.IdAttivita, A.IdVersione, A.IdFase, A.IdDichiarazione, A.DataProduzione, A.Stato, A.CodArticolo,
           A.QuantitaPrevista, A.QuantitaConsuntivata, A.IdLinea, A.IdMacchina, A.IdTeam, A.OraInizio, A.OraFine, A.Note
    FROM dbo.FF_ATTIVITA_PRODUTTIVE A
    WHERE A.IdAttivita=@IdAttivita;
END;
GO

