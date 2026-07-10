SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE dbo.sp_FF_Config_GetAttiva
AS
BEGIN
    SET NOCOUNT ON;
    SELECT TOP (1) IdConfig, CodAziAdhoc, PrefissoAzienda, CausaleCarico, CausaleScarico, MagazzinoPFDefault, MagazzinoComponentiDefault, Attiva
    FROM dbo.FF_CONFIG
    WHERE Attiva = 1
    ORDER BY IdConfig DESC;
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_FF_Config_Save
    @IdConfig int = NULL,
    @CodAziAdhoc varchar(10),
    @PrefissoAzienda varchar(10),
    @CausaleCarico varchar(10),
    @CausaleScarico varchar(10),
    @MagazzinoPFDefault varchar(5),
    @MagazzinoComponentiDefault varchar(5),
    @Attiva bit = 1,
    @Utente varchar(50) = 'FactoryFlow'
AS
BEGIN
    SET NOCOUNT ON;

    IF @Attiva = 1
        UPDATE dbo.FF_CONFIG SET Attiva = 0, DataModifica = GETDATE(), UtenteModifica = @Utente WHERE (@IdConfig IS NULL OR IdConfig <> @IdConfig) AND Attiva = 1;

    IF @IdConfig IS NULL OR NOT EXISTS (SELECT 1 FROM dbo.FF_CONFIG WHERE IdConfig = @IdConfig)
    BEGIN
        INSERT INTO dbo.FF_CONFIG (CodAziAdhoc, PrefissoAzienda, CausaleCarico, CausaleScarico, MagazzinoPFDefault, MagazzinoComponentiDefault, Attiva, UtenteCreazione)
        OUTPUT INSERTED.IdConfig, INSERTED.CodAziAdhoc, INSERTED.PrefissoAzienda, INSERTED.CausaleCarico, INSERTED.CausaleScarico, INSERTED.MagazzinoPFDefault, INSERTED.MagazzinoComponentiDefault, INSERTED.Attiva
        VALUES (@CodAziAdhoc, @PrefissoAzienda, @CausaleCarico, @CausaleScarico, @MagazzinoPFDefault, @MagazzinoComponentiDefault, @Attiva, @Utente);
        RETURN;
    END

    UPDATE dbo.FF_CONFIG
    SET CodAziAdhoc = @CodAziAdhoc, PrefissoAzienda = @PrefissoAzienda, CausaleCarico = @CausaleCarico, CausaleScarico = @CausaleScarico,
        MagazzinoPFDefault = @MagazzinoPFDefault, MagazzinoComponentiDefault = @MagazzinoComponentiDefault, Attiva = @Attiva,
        DataModifica = GETDATE(), UtenteModifica = @Utente
    OUTPUT INSERTED.IdConfig, INSERTED.CodAziAdhoc, INSERTED.PrefissoAzienda, INSERTED.CausaleCarico, INSERTED.CausaleScarico, INSERTED.MagazzinoPFDefault, INSERTED.MagazzinoComponentiDefault, INSERTED.Attiva
    WHERE IdConfig = @IdConfig;
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_FF_Operatori_List
AS
BEGIN
    SET NOCOUNT ON;
    SELECT IdOperatore, CodOperatore, Nome, Cognome, FonteEsterna, CodiceEsterno, CostoOrarioRiferimento, Attivo
    FROM dbo.FF_OPERATORI
    ORDER BY Attivo DESC, Cognome, Nome, CodOperatore;
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_FF_Operatori_Save
    @IdOperatore int = NULL,
    @CodOperatore varchar(20),
    @Nome varchar(100),
    @Cognome varchar(100) = NULL,
    @FonteEsterna varchar(50) = NULL,
    @CodiceEsterno varchar(50) = NULL,
    @CostoOrarioRiferimento decimal(18,4) = NULL,
    @Attivo bit = 1,
    @Utente varchar(50) = 'FactoryFlow'
AS
BEGIN
    SET NOCOUNT ON;
    IF @IdOperatore IS NULL OR NOT EXISTS (SELECT 1 FROM dbo.FF_OPERATORI WHERE IdOperatore = @IdOperatore)
    BEGIN
        INSERT INTO dbo.FF_OPERATORI (CodOperatore, Nome, Cognome, FonteEsterna, CodiceEsterno, CostoOrarioRiferimento, Attivo, UtenteCreazione)
        OUTPUT INSERTED.IdOperatore, INSERTED.CodOperatore, INSERTED.Nome, INSERTED.Cognome, INSERTED.FonteEsterna, INSERTED.CodiceEsterno, INSERTED.CostoOrarioRiferimento, INSERTED.Attivo
        VALUES (@CodOperatore, @Nome, @Cognome, @FonteEsterna, @CodiceEsterno, @CostoOrarioRiferimento, @Attivo, @Utente);
        RETURN;
    END
    UPDATE dbo.FF_OPERATORI
    SET CodOperatore=@CodOperatore, Nome=@Nome, Cognome=@Cognome, FonteEsterna=@FonteEsterna, CodiceEsterno=@CodiceEsterno,
        CostoOrarioRiferimento=@CostoOrarioRiferimento, Attivo=@Attivo, DataModifica=SYSDATETIME(), UtenteModifica=@Utente
    OUTPUT INSERTED.IdOperatore, INSERTED.CodOperatore, INSERTED.Nome, INSERTED.Cognome, INSERTED.FonteEsterna, INSERTED.CodiceEsterno, INSERTED.CostoOrarioRiferimento, INSERTED.Attivo
    WHERE IdOperatore=@IdOperatore;
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_FF_RuoliOperativi_List
AS
BEGIN
    SET NOCOUNT ON;
    SELECT IdRuoloOperativo, CodRuolo, Descrizione, Attivo
    FROM dbo.FF_RUOLI_OPERATIVI
    ORDER BY Attivo DESC, Descrizione;
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_FF_RuoliOperativi_Save
    @IdRuoloOperativo int = NULL,
    @CodRuolo varchar(20),
    @Descrizione varchar(100),
    @Attivo bit = 1,
    @Utente varchar(50) = 'FactoryFlow'
AS
BEGIN
    SET NOCOUNT ON;
    IF @IdRuoloOperativo IS NULL OR NOT EXISTS (SELECT 1 FROM dbo.FF_RUOLI_OPERATIVI WHERE IdRuoloOperativo = @IdRuoloOperativo)
    BEGIN
        INSERT INTO dbo.FF_RUOLI_OPERATIVI (CodRuolo, Descrizione, Attivo, UtenteCreazione)
        OUTPUT INSERTED.IdRuoloOperativo, INSERTED.CodRuolo, INSERTED.Descrizione, INSERTED.Attivo
        VALUES (@CodRuolo, @Descrizione, @Attivo, @Utente);
        RETURN;
    END
    UPDATE dbo.FF_RUOLI_OPERATIVI
    SET CodRuolo=@CodRuolo, Descrizione=@Descrizione, Attivo=@Attivo, DataModifica=SYSDATETIME(), UtenteModifica=@Utente
    OUTPUT INSERTED.IdRuoloOperativo, INSERTED.CodRuolo, INSERTED.Descrizione, INSERTED.Attivo
    WHERE IdRuoloOperativo=@IdRuoloOperativo;
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_FF_Macchine_List
AS
BEGIN
    SET NOCOUNT ON;
    SELECT M.IdMacchina, M.IdLinea, L.CodLinea, L.NomeLinea, M.CodMacchina, M.NomeMacchina, M.Descrizione, M.Attiva
    FROM dbo.FF_MACCHINE M
    LEFT JOIN dbo.FF_LINEE_LAVORAZIONE L ON L.IdLinea = M.IdLinea
    ORDER BY M.Attiva DESC, M.CodMacchina;
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_FF_Macchine_Save
    @IdMacchina int = NULL,
    @IdLinea int = NULL,
    @CodMacchina varchar(30),
    @NomeMacchina varchar(100),
    @Descrizione varchar(255) = NULL,
    @Attiva bit = 1,
    @Utente varchar(50) = 'FactoryFlow'
AS
BEGIN
    SET NOCOUNT ON;
    IF @IdMacchina IS NULL OR NOT EXISTS (SELECT 1 FROM dbo.FF_MACCHINE WHERE IdMacchina = @IdMacchina)
    BEGIN
        INSERT INTO dbo.FF_MACCHINE (IdLinea, CodMacchina, NomeMacchina, Descrizione, Attiva, UtenteCreazione)
        VALUES (@IdLinea, @CodMacchina, @NomeMacchina, @Descrizione, @Attiva, @Utente);
    END
    ELSE
    BEGIN
        UPDATE dbo.FF_MACCHINE SET IdLinea=@IdLinea, CodMacchina=@CodMacchina, NomeMacchina=@NomeMacchina, Descrizione=@Descrizione, Attiva=@Attiva, DataModifica=SYSDATETIME(), UtenteModifica=@Utente WHERE IdMacchina=@IdMacchina;
    END
    EXEC dbo.sp_FF_Macchine_List;
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_FF_TeamOperativi_List
AS
BEGIN
    SET NOCOUNT ON;
    SELECT IdTeam, CodTeam, Descrizione, Note, Attivo
    FROM dbo.FF_TEAM_OPERATIVI
    ORDER BY Attivo DESC, CodTeam;
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_FF_TeamOperativi_Save
    @IdTeam int = NULL,
    @CodTeam varchar(30),
    @Descrizione varchar(150),
    @Note varchar(255) = NULL,
    @Attivo bit = 1,
    @Utente varchar(50) = 'FactoryFlow'
AS
BEGIN
    SET NOCOUNT ON;
    IF @IdTeam IS NULL OR NOT EXISTS (SELECT 1 FROM dbo.FF_TEAM_OPERATIVI WHERE IdTeam = @IdTeam)
        INSERT INTO dbo.FF_TEAM_OPERATIVI (CodTeam, Descrizione, Note, Attivo, UtenteCreazione) VALUES (@CodTeam, @Descrizione, @Note, @Attivo, @Utente);
    ELSE
        UPDATE dbo.FF_TEAM_OPERATIVI SET CodTeam=@CodTeam, Descrizione=@Descrizione, Note=@Note, Attivo=@Attivo, DataModifica=SYSDATETIME(), UtenteModifica=@Utente WHERE IdTeam=@IdTeam;
    EXEC dbo.sp_FF_TeamOperativi_List;
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_FF_TeamOperatori_List
    @IdTeam int
AS
BEGIN
    SET NOCOUNT ON;
    SELECT T.IdTeamOperatore, T.IdTeam, T.IdOperatore, O.CodOperatore, O.Nome, O.Cognome,
           T.IdRuoloOperativo, R.CodRuolo, R.Descrizione AS RuoloDescrizione,
           COALESCE(T.CostoOrarioApplicato, O.CostoOrarioRiferimento) AS CostoOrarioApplicato,
           T.Note, T.Attivo
    FROM dbo.FF_TEAM_OPERATORI T
    INNER JOIN dbo.FF_OPERATORI O ON O.IdOperatore = T.IdOperatore
    LEFT JOIN dbo.FF_RUOLI_OPERATIVI R ON R.IdRuoloOperativo = T.IdRuoloOperativo
    WHERE T.IdTeam = @IdTeam
    ORDER BY T.Attivo DESC, O.Cognome, O.Nome, O.CodOperatore;
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_FF_TeamOperatori_Save
    @IdTeamOperatore int = NULL,
    @IdTeam int,
    @IdOperatore int,
    @IdRuoloOperativo int = NULL,
    @CostoOrarioApplicato decimal(18,4) = NULL,
    @Note varchar(255) = NULL,
    @Attivo bit = 1,
    @Utente varchar(50) = 'FactoryFlow'
AS
BEGIN
    SET NOCOUNT ON;
    IF @IdTeamOperatore IS NULL OR NOT EXISTS (SELECT 1 FROM dbo.FF_TEAM_OPERATORI WHERE IdTeamOperatore=@IdTeamOperatore)
        INSERT INTO dbo.FF_TEAM_OPERATORI (IdTeam, IdOperatore, IdRuoloOperativo, CostoOrarioApplicato, Note, Attivo, UtenteCreazione) VALUES (@IdTeam, @IdOperatore, @IdRuoloOperativo, @CostoOrarioApplicato, @Note, @Attivo, @Utente);
    ELSE
        UPDATE dbo.FF_TEAM_OPERATORI SET IdTeam=@IdTeam, IdOperatore=@IdOperatore, IdRuoloOperativo=@IdRuoloOperativo, CostoOrarioApplicato=@CostoOrarioApplicato, Note=@Note, Attivo=@Attivo, DataModifica=SYSDATETIME(), UtenteModifica=@Utente WHERE IdTeamOperatore=@IdTeamOperatore;
    EXEC dbo.sp_FF_TeamOperatori_List @IdTeam=@IdTeam;
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_FF_CostiLinea_List
AS
BEGIN
    SET NOCOUNT ON;
    SELECT C.IdCostoLinea, C.IdLinea, L.CodLinea, L.NomeLinea, C.IdMacchina, M.CodMacchina, M.NomeMacchina,
           C.ValidoDal, C.ValidoAl, C.CostoFissoOra, C.CostoMacchinaOra, C.CostoManodoperaOra,
           C.CostoEnergiaOra, C.CostoEnergiaUnita, C.Note, C.Attivo
    FROM dbo.FF_COSTI_LINEA C
    INNER JOIN dbo.FF_LINEE_LAVORAZIONE L ON L.IdLinea = C.IdLinea
    LEFT JOIN dbo.FF_MACCHINE M ON M.IdMacchina = C.IdMacchina
    ORDER BY C.Attivo DESC, L.CodLinea, M.CodMacchina, C.ValidoDal DESC;
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_FF_CostiLinea_Save
    @IdCostoLinea int = NULL,
    @IdLinea int,
    @IdMacchina int = NULL,
    @ValidoDal date,
    @ValidoAl date = NULL,
    @CostoFissoOra decimal(18,4) = NULL,
    @CostoMacchinaOra decimal(18,4) = NULL,
    @CostoManodoperaOra decimal(18,4) = NULL,
    @CostoEnergiaOra decimal(18,4) = NULL,
    @CostoEnergiaUnita decimal(18,6) = NULL,
    @Note varchar(255) = NULL,
    @Attivo bit = 1,
    @Utente varchar(50) = 'FactoryFlow'
AS
BEGIN
    SET NOCOUNT ON;
    IF @IdCostoLinea IS NULL OR NOT EXISTS (SELECT 1 FROM dbo.FF_COSTI_LINEA WHERE IdCostoLinea=@IdCostoLinea)
        INSERT INTO dbo.FF_COSTI_LINEA (IdLinea, IdMacchina, ValidoDal, ValidoAl, CostoFissoOra, CostoMacchinaOra, CostoManodoperaOra, CostoEnergiaOra, CostoEnergiaUnita, Note, Attivo, UtenteCreazione)
        VALUES (@IdLinea, @IdMacchina, @ValidoDal, @ValidoAl, @CostoFissoOra, @CostoMacchinaOra, @CostoManodoperaOra, @CostoEnergiaOra, @CostoEnergiaUnita, @Note, @Attivo, @Utente);
    ELSE
        UPDATE dbo.FF_COSTI_LINEA SET IdLinea=@IdLinea, IdMacchina=@IdMacchina, ValidoDal=@ValidoDal, ValidoAl=@ValidoAl, CostoFissoOra=@CostoFissoOra, CostoMacchinaOra=@CostoMacchinaOra, CostoManodoperaOra=@CostoManodoperaOra, CostoEnergiaOra=@CostoEnergiaOra, CostoEnergiaUnita=@CostoEnergiaUnita, Note=@Note, Attivo=@Attivo, DataModifica=SYSDATETIME(), UtenteModifica=@Utente WHERE IdCostoLinea=@IdCostoLinea;
    EXEC dbo.sp_FF_CostiLinea_List;
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_FF_SetupTipi_List
AS
BEGIN
    SET NOCOUNT ON;
    SELECT IdSetupTipo, CodSetupTipo, Descrizione, Attivo
    FROM dbo.FF_SETUP_TIPI
    ORDER BY Attivo DESC, CodSetupTipo;
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_FF_SetupTipi_Save
    @IdSetupTipo int = NULL,
    @CodSetupTipo varchar(30),
    @Descrizione varchar(150),
    @Attivo bit = 1,
    @Utente varchar(50) = 'FactoryFlow'
AS
BEGIN
    SET NOCOUNT ON;
    IF @IdSetupTipo IS NULL OR NOT EXISTS (SELECT 1 FROM dbo.FF_SETUP_TIPI WHERE IdSetupTipo=@IdSetupTipo)
        INSERT INTO dbo.FF_SETUP_TIPI (CodSetupTipo, Descrizione, Attivo, UtenteCreazione) VALUES (@CodSetupTipo, @Descrizione, @Attivo, @Utente);
    ELSE
        UPDATE dbo.FF_SETUP_TIPI SET CodSetupTipo=@CodSetupTipo, Descrizione=@Descrizione, Attivo=@Attivo, DataModifica=SYSDATETIME(), UtenteModifica=@Utente WHERE IdSetupTipo=@IdSetupTipo;
    EXEC dbo.sp_FF_SetupTipi_List;
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_FF_SetupRegole_List
AS
BEGIN
    SET NOCOUNT ON;
    SELECT R.IdSetupRegola, R.IdSetupTipo, T.CodSetupTipo, T.Descrizione AS SetupDescrizione,
           R.IdLinea, L.CodLinea, L.NomeLinea, R.IdMacchina, M.CodMacchina, M.NomeMacchina,
           R.CodArticolo, R.TempoStandardMinuti, R.CostoStandard, R.Priorita, R.Attiva
    FROM dbo.FF_SETUP_REGOLE R
    INNER JOIN dbo.FF_SETUP_TIPI T ON T.IdSetupTipo = R.IdSetupTipo
    LEFT JOIN dbo.FF_LINEE_LAVORAZIONE L ON L.IdLinea = R.IdLinea
    LEFT JOIN dbo.FF_MACCHINE M ON M.IdMacchina = R.IdMacchina
    ORDER BY R.Attiva DESC, R.Priorita, T.CodSetupTipo, R.CodArticolo;
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_FF_SetupRegole_Save
    @IdSetupRegola int = NULL,
    @IdSetupTipo int,
    @IdLinea int = NULL,
    @IdMacchina int = NULL,
    @CodArticolo varchar(20) = NULL,
    @TempoStandardMinuti decimal(18,3) = NULL,
    @CostoStandard decimal(18,4) = NULL,
    @Priorita int = 100,
    @Attiva bit = 1,
    @Utente varchar(50) = 'FactoryFlow'
AS
BEGIN
    SET NOCOUNT ON;
    IF @IdSetupRegola IS NULL OR NOT EXISTS (SELECT 1 FROM dbo.FF_SETUP_REGOLE WHERE IdSetupRegola=@IdSetupRegola)
        INSERT INTO dbo.FF_SETUP_REGOLE (IdSetupTipo, IdLinea, IdMacchina, CodArticolo, TempoStandardMinuti, CostoStandard, Priorita, Attiva, UtenteCreazione)
        VALUES (@IdSetupTipo, @IdLinea, @IdMacchina, @CodArticolo, @TempoStandardMinuti, @CostoStandard, @Priorita, @Attiva, @Utente);
    ELSE
        UPDATE dbo.FF_SETUP_REGOLE SET IdSetupTipo=@IdSetupTipo, IdLinea=@IdLinea, IdMacchina=@IdMacchina, CodArticolo=@CodArticolo, TempoStandardMinuti=@TempoStandardMinuti, CostoStandard=@CostoStandard, Priorita=@Priorita, Attiva=@Attiva, DataModifica=SYSDATETIME(), UtenteModifica=@Utente WHERE IdSetupRegola=@IdSetupRegola;
    EXEC dbo.sp_FF_SetupRegole_List;
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_FF_TeamOperatori_List
    @IdTeam int
AS
BEGIN
    SET NOCOUNT ON;

    SELECT T.IdTeamOperatore, T.IdTeam, T.IdOperatore, O.CodOperatore, O.Nome, O.Cognome,
           T.IdRuoloOperativo, R.CodRuolo, R.Descrizione AS RuoloDescrizione,
           T.CostoOrarioApplicato,
           T.Note,
           T.ValidoDal,
           T.ValidoAl,
           CAST(CASE WHEN T.ValidoAl IS NULL THEN 1 ELSE 0 END AS bit) AS Attivo
    FROM dbo.FF_TEAM_OPERATORI T
    INNER JOIN dbo.FF_OPERATORI O ON O.IdOperatore = T.IdOperatore
    LEFT JOIN dbo.FF_RUOLI_OPERATIVI R ON R.IdRuoloOperativo = T.IdRuoloOperativo
    WHERE T.IdTeam = @IdTeam
    ORDER BY CASE WHEN T.ValidoAl IS NULL THEN 0 ELSE 1 END, O.Cognome, O.Nome, O.CodOperatore;
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_FF_TeamOperatori_Save
    @IdTeamOperatore int = NULL,
    @IdTeam int,
    @IdOperatore int,
    @IdRuoloOperativo int = NULL,
    @CostoOrarioApplicato decimal(18,4) = NULL,
    @Note varchar(255) = NULL,
    @Attivo bit = 1,
    @ValidoDal date = NULL,
    @ValidoAl date = NULL,
    @Utente varchar(50) = 'FactoryFlow'
AS
BEGIN
    SET NOCOUNT ON;

    SET @ValidoDal = COALESCE(@ValidoDal, CAST(GETDATE() AS date));

    IF @Attivo = 0 AND @ValidoAl IS NULL
        SET @ValidoAl = CAST(GETDATE() AS date);

    IF @CostoOrarioApplicato IS NULL
    BEGIN
        SELECT @CostoOrarioApplicato = O.CostoOrarioRiferimento
        FROM dbo.FF_OPERATORI O
        WHERE O.IdOperatore = @IdOperatore;
    END;

    IF @ValidoAl IS NULL
       AND EXISTS
       (
           SELECT 1
           FROM dbo.FF_TEAM_OPERATORI
           WHERE IdTeam = @IdTeam
             AND IdOperatore = @IdOperatore
             AND ValidoAl IS NULL
             AND (@IdTeamOperatore IS NULL OR IdTeamOperatore <> @IdTeamOperatore)
       )
    BEGIN
        RAISERROR('Operatore gia presente nel team con validita aperta.', 16, 1);
        RETURN;
    END;

    IF @IdTeamOperatore IS NULL OR NOT EXISTS (SELECT 1 FROM dbo.FF_TEAM_OPERATORI WHERE IdTeamOperatore = @IdTeamOperatore)
    BEGIN
        INSERT INTO dbo.FF_TEAM_OPERATORI
            (IdTeam, IdOperatore, IdRuoloOperativo, CostoOrarioApplicato, Note, Attivo, ValidoDal, ValidoAl, UtenteCreazione)
        VALUES
            (@IdTeam, @IdOperatore, @IdRuoloOperativo, @CostoOrarioApplicato, @Note,
             CAST(CASE WHEN @ValidoAl IS NULL THEN 1 ELSE 0 END AS bit), @ValidoDal, @ValidoAl, @Utente);
    END
    ELSE
    BEGIN
        UPDATE dbo.FF_TEAM_OPERATORI
        SET IdTeam = @IdTeam,
            IdOperatore = @IdOperatore,
            IdRuoloOperativo = @IdRuoloOperativo,
            CostoOrarioApplicato = @CostoOrarioApplicato,
            Note = @Note,
            Attivo = CAST(CASE WHEN @ValidoAl IS NULL THEN 1 ELSE 0 END AS bit),
            ValidoDal = @ValidoDal,
            ValidoAl = @ValidoAl,
            DataModifica = SYSDATETIME(),
            UtenteModifica = @Utente
        WHERE IdTeamOperatore = @IdTeamOperatore;
    END;

    EXEC dbo.sp_FF_TeamOperatori_List @IdTeam = @IdTeam;
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_FF_SetupRegole_List
AS
BEGIN
    SET NOCOUNT ON;

    SELECT R.IdSetupRegola, R.IdSetupTipo, T.CodSetupTipo, T.Descrizione AS SetupDescrizione,
           R.IdLinea, L.CodLinea, L.NomeLinea, R.IdMacchina, M.CodMacchina, M.NomeMacchina,
           R.CodArticolo, R.TempoStandardMinuti, R.CostoStandard, R.Priorita,
           R.ValidoDal, R.ValidoAl,
           CAST(CASE WHEN R.ValidoAl IS NULL THEN 1 ELSE 0 END AS bit) AS Attiva
    FROM dbo.FF_SETUP_REGOLE R
    INNER JOIN dbo.FF_SETUP_TIPI T ON T.IdSetupTipo = R.IdSetupTipo
    LEFT JOIN dbo.FF_LINEE_LAVORAZIONE L ON L.IdLinea = R.IdLinea
    LEFT JOIN dbo.FF_MACCHINE M ON M.IdMacchina = R.IdMacchina
    ORDER BY CASE WHEN R.ValidoAl IS NULL THEN 0 ELSE 1 END, R.Priorita, T.CodSetupTipo, R.CodArticolo;
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_FF_SetupRegole_Save
    @IdSetupRegola int = NULL,
    @IdSetupTipo int,
    @IdLinea int = NULL,
    @IdMacchina int = NULL,
    @CodArticolo varchar(20) = NULL,
    @TempoStandardMinuti decimal(18,3) = NULL,
    @CostoStandard decimal(18,4) = NULL,
    @Priorita int = 100,
    @Attiva bit = 1,
    @ValidoDal date = NULL,
    @ValidoAl date = NULL,
    @Utente varchar(50) = 'FactoryFlow'
AS
BEGIN
    SET NOCOUNT ON;

    SET @ValidoDal = COALESCE(@ValidoDal, CAST(GETDATE() AS date));

    IF @Attiva = 0 AND @ValidoAl IS NULL
        SET @ValidoAl = CAST(GETDATE() AS date);

    IF @IdSetupRegola IS NULL OR NOT EXISTS (SELECT 1 FROM dbo.FF_SETUP_REGOLE WHERE IdSetupRegola = @IdSetupRegola)
    BEGIN
        INSERT INTO dbo.FF_SETUP_REGOLE
            (IdSetupTipo, IdLinea, IdMacchina, CodArticolo, TempoStandardMinuti, CostoStandard, Priorita, Attiva, ValidoDal, ValidoAl, UtenteCreazione)
        VALUES
            (@IdSetupTipo, @IdLinea, @IdMacchina, @CodArticolo, @TempoStandardMinuti, @CostoStandard,
             @Priorita, CAST(CASE WHEN @ValidoAl IS NULL THEN 1 ELSE 0 END AS bit), @ValidoDal, @ValidoAl, @Utente);
    END
    ELSE
    BEGIN
        UPDATE dbo.FF_SETUP_REGOLE
        SET IdSetupTipo = @IdSetupTipo,
            IdLinea = @IdLinea,
            IdMacchina = @IdMacchina,
            CodArticolo = @CodArticolo,
            TempoStandardMinuti = @TempoStandardMinuti,
            CostoStandard = @CostoStandard,
            Priorita = @Priorita,
            Attiva = CAST(CASE WHEN @ValidoAl IS NULL THEN 1 ELSE 0 END AS bit),
            ValidoDal = @ValidoDal,
            ValidoAl = @ValidoAl,
            DataModifica = SYSDATETIME(),
            UtenteModifica = @Utente
        WHERE IdSetupRegola = @IdSetupRegola;
    END;

    EXEC dbo.sp_FF_SetupRegole_List;
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_FF_Operatori_List
AS
BEGIN
    SET NOCOUNT ON;
    SELECT IdOperatore, CodOperatore, Nome, Cognome, FonteEsterna, CodiceEsterno, CostoOrarioRiferimento,
           DataObsolescenza, MotivoObsolescenza,
           CAST(CASE WHEN DataObsolescenza IS NULL AND Attivo = 1 THEN 1 ELSE 0 END AS bit) AS Attivo
    FROM dbo.FF_OPERATORI
    ORDER BY CASE WHEN DataObsolescenza IS NULL AND Attivo = 1 THEN 0 ELSE 1 END, Cognome, Nome, CodOperatore;
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_FF_Operatori_Save
    @IdOperatore int = NULL,
    @CodOperatore varchar(20),
    @Nome varchar(100),
    @Cognome varchar(100) = NULL,
    @FonteEsterna varchar(50) = NULL,
    @CodiceEsterno varchar(50) = NULL,
    @CostoOrarioRiferimento decimal(18,4) = NULL,
    @Attivo bit = 1,
    @DataObsolescenza date = NULL,
    @MotivoObsolescenza varchar(255) = NULL,
    @Utente varchar(50) = 'FactoryFlow'
AS
BEGIN
    SET NOCOUNT ON;

    IF @Attivo = 0 AND @DataObsolescenza IS NULL
        SET @DataObsolescenza = CAST(GETDATE() AS date);

    IF @Attivo = 1
    BEGIN
        SET @DataObsolescenza = NULL;
        SET @MotivoObsolescenza = NULL;
    END;

    IF @IdOperatore IS NULL OR NOT EXISTS (SELECT 1 FROM dbo.FF_OPERATORI WHERE IdOperatore = @IdOperatore)
    BEGIN
        INSERT INTO dbo.FF_OPERATORI (CodOperatore, Nome, Cognome, FonteEsterna, CodiceEsterno, CostoOrarioRiferimento, Attivo, DataObsolescenza, MotivoObsolescenza, UtenteCreazione)
        OUTPUT INSERTED.IdOperatore, INSERTED.CodOperatore, INSERTED.Nome, INSERTED.Cognome, INSERTED.FonteEsterna, INSERTED.CodiceEsterno, INSERTED.CostoOrarioRiferimento, INSERTED.DataObsolescenza, INSERTED.MotivoObsolescenza, CAST(CASE WHEN INSERTED.DataObsolescenza IS NULL AND INSERTED.Attivo = 1 THEN 1 ELSE 0 END AS bit) AS Attivo
        VALUES (@CodOperatore, @Nome, @Cognome, @FonteEsterna, @CodiceEsterno, @CostoOrarioRiferimento, @Attivo, @DataObsolescenza, @MotivoObsolescenza, @Utente);
        RETURN;
    END;

    UPDATE dbo.FF_OPERATORI
    SET CodOperatore=@CodOperatore,
        Nome=@Nome,
        Cognome=@Cognome,
        FonteEsterna=@FonteEsterna,
        CodiceEsterno=@CodiceEsterno,
        CostoOrarioRiferimento=@CostoOrarioRiferimento,
        Attivo=CAST(CASE WHEN @DataObsolescenza IS NULL AND @Attivo = 1 THEN 1 ELSE 0 END AS bit),
        DataObsolescenza=@DataObsolescenza,
        MotivoObsolescenza=@MotivoObsolescenza,
        DataModifica=SYSDATETIME(),
        UtenteModifica=@Utente
    OUTPUT INSERTED.IdOperatore, INSERTED.CodOperatore, INSERTED.Nome, INSERTED.Cognome, INSERTED.FonteEsterna, INSERTED.CodiceEsterno, INSERTED.CostoOrarioRiferimento, INSERTED.DataObsolescenza, INSERTED.MotivoObsolescenza, CAST(CASE WHEN INSERTED.DataObsolescenza IS NULL AND INSERTED.Attivo = 1 THEN 1 ELSE 0 END AS bit) AS Attivo
    WHERE IdOperatore=@IdOperatore;
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_FF_Macchine_List
AS
BEGIN
    SET NOCOUNT ON;
    SELECT M.IdMacchina, M.IdLinea, L.CodLinea, L.NomeLinea, M.CodMacchina, M.NomeMacchina, M.Descrizione,
           M.ConsumoKwSpunto, M.ConsumoKwFunzione, M.UnitaMinutoBenchmark, M.NoteTecniche, M.Attiva
    FROM dbo.FF_MACCHINE M
    LEFT JOIN dbo.FF_LINEE_LAVORAZIONE L ON L.IdLinea = M.IdLinea
    ORDER BY M.Attiva DESC, M.CodMacchina;
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_FF_Macchine_Save
    @IdMacchina int = NULL,
    @IdLinea int = NULL,
    @CodMacchina varchar(30),
    @NomeMacchina varchar(100),
    @Descrizione varchar(255) = NULL,
    @ConsumoKwSpunto decimal(18,4) = NULL,
    @ConsumoKwFunzione decimal(18,4) = NULL,
    @UnitaMinutoBenchmark decimal(18,6) = NULL,
    @NoteTecniche varchar(500) = NULL,
    @Attiva bit = 1,
    @Utente varchar(50) = 'FactoryFlow'
AS
BEGIN
    SET NOCOUNT ON;
    IF @IdMacchina IS NULL OR NOT EXISTS (SELECT 1 FROM dbo.FF_MACCHINE WHERE IdMacchina = @IdMacchina)
    BEGIN
        INSERT INTO dbo.FF_MACCHINE (IdLinea, CodMacchina, NomeMacchina, Descrizione, ConsumoKwSpunto, ConsumoKwFunzione, UnitaMinutoBenchmark, NoteTecniche, Attiva, UtenteCreazione)
        VALUES (@IdLinea, @CodMacchina, @NomeMacchina, @Descrizione, @ConsumoKwSpunto, @ConsumoKwFunzione, @UnitaMinutoBenchmark, @NoteTecniche, @Attiva, @Utente);
    END
    ELSE
    BEGIN
        UPDATE dbo.FF_MACCHINE
        SET IdLinea=@IdLinea,
            CodMacchina=@CodMacchina,
            NomeMacchina=@NomeMacchina,
            Descrizione=@Descrizione,
            ConsumoKwSpunto=@ConsumoKwSpunto,
            ConsumoKwFunzione=@ConsumoKwFunzione,
            UnitaMinutoBenchmark=@UnitaMinutoBenchmark,
            NoteTecniche=@NoteTecniche,
            Attiva=@Attiva,
            DataModifica=SYSDATETIME(),
            UtenteModifica=@Utente
        WHERE IdMacchina=@IdMacchina;
    END;
    EXEC dbo.sp_FF_Macchine_List;
END;
GO

/* =====================================================================
   Process-centric final CRUD definitions - 2026-07-05
   These CREATE OR ALTER blocks intentionally override previous procedure
   definitions in this file without dropping existing objects.
   ===================================================================== */

CREATE OR ALTER PROCEDURE dbo.sp_FF_Macchine_List
AS
BEGIN
    SET NOCOUNT ON;

    SELECT M.IdMacchina, M.IdLinea, L.CodLinea, L.NomeLinea,
           M.CodMacchina, M.NomeMacchina, M.Descrizione,
           M.Reparto, M.Costruttore, M.Modello, M.Matricola, M.AnnoInstallazione, M.Stato,
           M.UnitaMisuraPrincipale, M.VelocitaNominale, M.VelocitaOttimale, M.VelocitaMassima,
           M.CapacitaMassimaTurno, M.CapacitaMassimaGiornaliera, M.CapacitaMassimaSettimanale,
           M.TempoMinimoLottoMinuti, M.TempoMassimoLottoMinuti,
           M.CostoAmmortamentoOra, M.CostoManutenzioneOra, M.CostoEnergiaVuotoOra, M.CostoEnergiaProduzioneOra,
           M.CostoLubrificantiOra, M.CostoUtensiliOra, M.CostoPuliziaOra, M.CostoFermoMacchinaOra, M.CostoOccupazioneSpazioOra,
           M.TempoRiscaldamentoMinuti, M.TempoRaffreddamentoMinuti, M.TempoCambioFormatoStandardMinuti,
           M.TempoPuliziaStandardMinuti, M.TempoSanificazioneMinuti, M.TempoSetupBaseMinuti, M.TempoAvviamentoMinuti, M.TempoArrestoMinuti,
           M.ConsumoKwSpunto, M.ConsumoKwFunzione, M.UnitaMinutoBenchmark, M.NoteTecniche, M.Attiva
    FROM dbo.FF_MACCHINE M
    LEFT JOIN dbo.FF_LINEE_LAVORAZIONE L ON L.IdLinea = M.IdLinea
    ORDER BY M.Attiva DESC, M.CodMacchina;
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_FF_Macchine_Save
    @IdMacchina int = NULL,
    @IdLinea int = NULL,
    @CodMacchina varchar(30),
    @NomeMacchina varchar(100),
    @Descrizione varchar(255) = NULL,
    @Reparto varchar(100) = NULL,
    @Costruttore varchar(100) = NULL,
    @Modello varchar(100) = NULL,
    @Matricola varchar(100) = NULL,
    @AnnoInstallazione int = NULL,
    @Stato varchar(30) = NULL,
    @UnitaMisuraPrincipale varchar(10) = NULL,
    @VelocitaNominale decimal(18,6) = NULL,
    @VelocitaOttimale decimal(18,6) = NULL,
    @VelocitaMassima decimal(18,6) = NULL,
    @CapacitaMassimaTurno decimal(18,6) = NULL,
    @CapacitaMassimaGiornaliera decimal(18,6) = NULL,
    @CapacitaMassimaSettimanale decimal(18,6) = NULL,
    @TempoMinimoLottoMinuti decimal(18,3) = NULL,
    @TempoMassimoLottoMinuti decimal(18,3) = NULL,
    @CostoAmmortamentoOra decimal(18,4) = NULL,
    @CostoManutenzioneOra decimal(18,4) = NULL,
    @CostoEnergiaVuotoOra decimal(18,4) = NULL,
    @CostoEnergiaProduzioneOra decimal(18,4) = NULL,
    @CostoLubrificantiOra decimal(18,4) = NULL,
    @CostoUtensiliOra decimal(18,4) = NULL,
    @CostoPuliziaOra decimal(18,4) = NULL,
    @CostoFermoMacchinaOra decimal(18,4) = NULL,
    @CostoOccupazioneSpazioOra decimal(18,4) = NULL,
    @TempoRiscaldamentoMinuti decimal(18,3) = NULL,
    @TempoRaffreddamentoMinuti decimal(18,3) = NULL,
    @TempoCambioFormatoStandardMinuti decimal(18,3) = NULL,
    @TempoPuliziaStandardMinuti decimal(18,3) = NULL,
    @TempoSanificazioneMinuti decimal(18,3) = NULL,
    @TempoSetupBaseMinuti decimal(18,3) = NULL,
    @TempoAvviamentoMinuti decimal(18,3) = NULL,
    @TempoArrestoMinuti decimal(18,3) = NULL,
    @ConsumoKwSpunto decimal(18,4) = NULL,
    @ConsumoKwFunzione decimal(18,4) = NULL,
    @UnitaMinutoBenchmark decimal(18,6) = NULL,
    @NoteTecniche varchar(500) = NULL,
    @Attiva bit = 1,
    @Utente varchar(50) = 'FactoryFlow'
AS
BEGIN
    SET NOCOUNT ON;
    SET @Stato = COALESCE(NULLIF(LTRIM(RTRIM(@Stato)), ''), CASE WHEN @Attiva = 1 THEN 'ATTIVA' ELSE 'OBSOLETA' END);

    IF @IdMacchina IS NULL OR NOT EXISTS (SELECT 1 FROM dbo.FF_MACCHINE WHERE IdMacchina = @IdMacchina)
    BEGIN
        INSERT INTO dbo.FF_MACCHINE
            (IdLinea, CodMacchina, NomeMacchina, Descrizione, Reparto, Costruttore, Modello, Matricola, AnnoInstallazione, Stato,
             UnitaMisuraPrincipale, VelocitaNominale, VelocitaOttimale, VelocitaMassima, CapacitaMassimaTurno, CapacitaMassimaGiornaliera,
             CapacitaMassimaSettimanale, TempoMinimoLottoMinuti, TempoMassimoLottoMinuti, CostoAmmortamentoOra, CostoManutenzioneOra,
             CostoEnergiaVuotoOra, CostoEnergiaProduzioneOra, CostoLubrificantiOra, CostoUtensiliOra, CostoPuliziaOra,
             CostoFermoMacchinaOra, CostoOccupazioneSpazioOra, TempoRiscaldamentoMinuti, TempoRaffreddamentoMinuti,
             TempoCambioFormatoStandardMinuti, TempoPuliziaStandardMinuti, TempoSanificazioneMinuti, TempoSetupBaseMinuti,
             TempoAvviamentoMinuti, TempoArrestoMinuti, ConsumoKwSpunto, ConsumoKwFunzione, UnitaMinutoBenchmark, NoteTecniche, Attiva, UtenteCreazione)
        VALUES
            (@IdLinea, @CodMacchina, @NomeMacchina, @Descrizione, @Reparto, @Costruttore, @Modello, @Matricola, @AnnoInstallazione, @Stato,
             @UnitaMisuraPrincipale, @VelocitaNominale, @VelocitaOttimale, @VelocitaMassima, @CapacitaMassimaTurno, @CapacitaMassimaGiornaliera,
             @CapacitaMassimaSettimanale, @TempoMinimoLottoMinuti, @TempoMassimoLottoMinuti, @CostoAmmortamentoOra, @CostoManutenzioneOra,
             @CostoEnergiaVuotoOra, @CostoEnergiaProduzioneOra, @CostoLubrificantiOra, @CostoUtensiliOra, @CostoPuliziaOra,
             @CostoFermoMacchinaOra, @CostoOccupazioneSpazioOra, @TempoRiscaldamentoMinuti, @TempoRaffreddamentoMinuti,
             @TempoCambioFormatoStandardMinuti, @TempoPuliziaStandardMinuti, @TempoSanificazioneMinuti, @TempoSetupBaseMinuti,
             @TempoAvviamentoMinuti, @TempoArrestoMinuti, @ConsumoKwSpunto, @ConsumoKwFunzione, @UnitaMinutoBenchmark, @NoteTecniche, @Attiva, @Utente);
    END
    ELSE
    BEGIN
        UPDATE dbo.FF_MACCHINE
        SET IdLinea=@IdLinea, CodMacchina=@CodMacchina, NomeMacchina=@NomeMacchina, Descrizione=@Descrizione,
            Reparto=@Reparto, Costruttore=@Costruttore, Modello=@Modello, Matricola=@Matricola, AnnoInstallazione=@AnnoInstallazione, Stato=@Stato,
            UnitaMisuraPrincipale=@UnitaMisuraPrincipale, VelocitaNominale=@VelocitaNominale, VelocitaOttimale=@VelocitaOttimale, VelocitaMassima=@VelocitaMassima,
            CapacitaMassimaTurno=@CapacitaMassimaTurno, CapacitaMassimaGiornaliera=@CapacitaMassimaGiornaliera, CapacitaMassimaSettimanale=@CapacitaMassimaSettimanale,
            TempoMinimoLottoMinuti=@TempoMinimoLottoMinuti, TempoMassimoLottoMinuti=@TempoMassimoLottoMinuti,
            CostoAmmortamentoOra=@CostoAmmortamentoOra, CostoManutenzioneOra=@CostoManutenzioneOra, CostoEnergiaVuotoOra=@CostoEnergiaVuotoOra,
            CostoEnergiaProduzioneOra=@CostoEnergiaProduzioneOra, CostoLubrificantiOra=@CostoLubrificantiOra, CostoUtensiliOra=@CostoUtensiliOra,
            CostoPuliziaOra=@CostoPuliziaOra, CostoFermoMacchinaOra=@CostoFermoMacchinaOra, CostoOccupazioneSpazioOra=@CostoOccupazioneSpazioOra,
            TempoRiscaldamentoMinuti=@TempoRiscaldamentoMinuti, TempoRaffreddamentoMinuti=@TempoRaffreddamentoMinuti,
            TempoCambioFormatoStandardMinuti=@TempoCambioFormatoStandardMinuti, TempoPuliziaStandardMinuti=@TempoPuliziaStandardMinuti,
            TempoSanificazioneMinuti=@TempoSanificazioneMinuti, TempoSetupBaseMinuti=@TempoSetupBaseMinuti,
            TempoAvviamentoMinuti=@TempoAvviamentoMinuti, TempoArrestoMinuti=@TempoArrestoMinuti,
            ConsumoKwSpunto=@ConsumoKwSpunto, ConsumoKwFunzione=@ConsumoKwFunzione, UnitaMinutoBenchmark=@UnitaMinutoBenchmark,
            NoteTecniche=@NoteTecniche, Attiva=@Attiva, DataModifica=SYSDATETIME(), UtenteModifica=@Utente
        WHERE IdMacchina=@IdMacchina;
    END;

    EXEC dbo.sp_FF_Macchine_List;
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_FF_Processi_List
AS
BEGIN
    SET NOCOUNT ON;
    SELECT P.IdProcesso, P.CodProcesso, P.CodArticolo, P.Descrizione, P.Note, P.Stato,
           V.IdVersione AS IdVersioneCorrente, V.NumeroVersione AS NumeroVersioneCorrente, V.ValidoDal, V.ValidoAl
    FROM dbo.FF_PROCESSI_PRODUTTIVI P
    OUTER APPLY
    (
        SELECT TOP (1) V.IdVersione, V.NumeroVersione, V.ValidoDal, V.ValidoAl
        FROM dbo.FF_PROCESSI_VERSIONI V
        WHERE V.IdProcesso = P.IdProcesso AND V.ValidoAl IS NULL
        ORDER BY V.NumeroVersione DESC
    ) V
    ORDER BY P.Stato, P.CodProcesso;
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_FF_Processi_Save
    @IdProcesso int = NULL,
    @CodProcesso varchar(40),
    @CodArticolo varchar(30) = NULL,
    @Descrizione varchar(200),
    @Note varchar(500) = NULL,
    @Stato varchar(20) = 'BOZZA',
    @Utente varchar(50) = 'FactoryFlow'
AS
BEGIN
    SET NOCOUNT ON;
    IF @IdProcesso IS NULL OR NOT EXISTS (SELECT 1 FROM dbo.FF_PROCESSI_PRODUTTIVI WHERE IdProcesso = @IdProcesso)
    BEGIN
        INSERT INTO dbo.FF_PROCESSI_PRODUTTIVI (CodProcesso, CodArticolo, Descrizione, Note, Stato, UtenteCreazione)
        VALUES (@CodProcesso, @CodArticolo, @Descrizione, @Note, @Stato, @Utente);
        SET @IdProcesso = CONVERT(int, SCOPE_IDENTITY());
    END
    ELSE
    BEGIN
        UPDATE dbo.FF_PROCESSI_PRODUTTIVI
        SET CodProcesso=@CodProcesso, CodArticolo=@CodArticolo, Descrizione=@Descrizione, Note=@Note, Stato=@Stato,
            DataModifica=SYSDATETIME(), UtenteModifica=@Utente
        WHERE IdProcesso=@IdProcesso;
    END;
    SELECT * FROM dbo.FF_PROCESSI_PRODUTTIVI WHERE IdProcesso=@IdProcesso;
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_FF_ProcessiVersioni_List @IdProcesso int
AS
BEGIN
    SET NOCOUNT ON;
    SELECT IdVersione, IdProcesso, NumeroVersione, Descrizione, Motivazione, ValidoDal, ValidoAl, Stato,
           TempoAttesoMinuti, SetupAttesoMinuti, ProduttivitaAttesa, CostoAtteso, EnergiaAttesa
    FROM dbo.FF_PROCESSI_VERSIONI
    WHERE IdProcesso = @IdProcesso
    ORDER BY NumeroVersione DESC;
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_FF_ProcessiVersioni_Save
    @IdVersione int = NULL,
    @IdProcesso int,
    @NumeroVersione int = NULL,
    @Descrizione varchar(200) = NULL,
    @Motivazione varchar(500) = NULL,
    @ValidoDal date,
    @ValidoAl date = NULL,
    @Stato varchar(20) = 'BOZZA',
    @TempoAttesoMinuti decimal(18,3) = NULL,
    @SetupAttesoMinuti decimal(18,3) = NULL,
    @ProduttivitaAttesa decimal(18,6) = NULL,
    @CostoAtteso decimal(18,4) = NULL,
    @EnergiaAttesa decimal(18,6) = NULL,
    @Utente varchar(50) = 'FactoryFlow'
AS
BEGIN
    SET NOCOUNT ON;
    IF @NumeroVersione IS NULL SELECT @NumeroVersione = COALESCE(MAX(NumeroVersione), 0) + 1 FROM dbo.FF_PROCESSI_VERSIONI WHERE IdProcesso=@IdProcesso;
    IF @IdVersione IS NULL OR NOT EXISTS (SELECT 1 FROM dbo.FF_PROCESSI_VERSIONI WHERE IdVersione=@IdVersione)
    BEGIN
        INSERT INTO dbo.FF_PROCESSI_VERSIONI (IdProcesso, NumeroVersione, Descrizione, Motivazione, ValidoDal, ValidoAl, Stato, TempoAttesoMinuti, SetupAttesoMinuti, ProduttivitaAttesa, CostoAtteso, EnergiaAttesa, UtenteCreazione)
        VALUES (@IdProcesso, @NumeroVersione, @Descrizione, @Motivazione, @ValidoDal, @ValidoAl, @Stato, @TempoAttesoMinuti, @SetupAttesoMinuti, @ProduttivitaAttesa, @CostoAtteso, @EnergiaAttesa, @Utente);
    END
    ELSE
    BEGIN
        UPDATE dbo.FF_PROCESSI_VERSIONI
        SET Descrizione=@Descrizione, Motivazione=@Motivazione, ValidoDal=@ValidoDal, ValidoAl=@ValidoAl, Stato=@Stato,
            TempoAttesoMinuti=@TempoAttesoMinuti, SetupAttesoMinuti=@SetupAttesoMinuti, ProduttivitaAttesa=@ProduttivitaAttesa, CostoAtteso=@CostoAtteso, EnergiaAttesa=@EnergiaAttesa,
            DataModifica=SYSDATETIME(), UtenteModifica=@Utente
        WHERE IdVersione=@IdVersione;
    END;
    EXEC dbo.sp_FF_ProcessiVersioni_List @IdProcesso=@IdProcesso;
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_FF_ProcessiFasi_List @IdVersione int
AS
BEGIN
    SET NOCOUNT ON;
    SELECT F.IdFase, F.IdVersione, F.Sequenza, F.CodFase, F.Descrizione,
           F.IdLineaDefault, L.CodLinea, L.NomeLinea, F.IdMacchinaDefault, M.CodMacchina, M.NomeMacchina,
           F.TempoStandardMinuti, F.SetupStandardMinuti, F.ProduttivitaAttesa, F.CostoStandard, F.EnergiaAttesa, F.QualitaAttesa, F.ScartoAtteso, F.Note
    FROM dbo.FF_PROCESSI_FASI F
    LEFT JOIN dbo.FF_LINEE_LAVORAZIONE L ON L.IdLinea = F.IdLineaDefault
    LEFT JOIN dbo.FF_MACCHINE M ON M.IdMacchina = F.IdMacchinaDefault
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

    IF @IdFase IS NULL OR NOT EXISTS (SELECT 1 FROM dbo.FF_PROCESSI_FASI WHERE IdFase=@IdFase)
        INSERT INTO dbo.FF_PROCESSI_FASI (IdVersione, Sequenza, CodFase, Descrizione, IdLineaDefault, IdMacchinaDefault, TempoStandardMinuti, SetupStandardMinuti, ProduttivitaAttesa, CostoStandard, EnergiaAttesa, QualitaAttesa, ScartoAtteso, Note, UtenteCreazione)
        VALUES (@IdVersione, @Sequenza, @CodFase, @Descrizione, @IdLineaDefault, @IdMacchinaDefault, @TempoStandardMinuti, @SetupStandardMinuti, @ProduttivitaAttesa, @CostoStandard, @EnergiaAttesa, @QualitaAttesa, @ScartoAtteso, @Note, @Utente);
    ELSE
        UPDATE dbo.FF_PROCESSI_FASI
        SET Sequenza=@Sequenza, CodFase=@CodFase, Descrizione=@Descrizione, IdLineaDefault=@IdLineaDefault, IdMacchinaDefault=@IdMacchinaDefault,
            TempoStandardMinuti=@TempoStandardMinuti, SetupStandardMinuti=@SetupStandardMinuti, ProduttivitaAttesa=@ProduttivitaAttesa, CostoStandard=@CostoStandard,
            EnergiaAttesa=@EnergiaAttesa, QualitaAttesa=@QualitaAttesa, ScartoAtteso=@ScartoAtteso, Note=@Note, DataModifica=SYSDATETIME(), UtenteModifica=@Utente
        WHERE IdFase=@IdFase;
    EXEC dbo.sp_FF_ProcessiFasi_List @IdVersione=@IdVersione;
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_FF_ProcessiFasi_Delete
    @IdVersione int,
    @IdFase int
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM dbo.FF_PROCESSI_FASI WHERE IdFase=@IdFase AND IdVersione=@IdVersione)
    BEGIN
        RAISERROR('Fase non trovata nella versione indicata.', 16, 1);
        RETURN;
    END;

    IF EXISTS (SELECT 1 FROM dbo.FF_ATTIVITA_PRODUTTIVE WHERE IdVersione = @IdVersione)
    BEGIN
        RAISERROR('Versione processo gia utilizzata: la fase resta consultabile nello storico. Creare una nuova versione per non usarla in futuro.', 16, 1);
        RETURN;
    END;

    DELETE FROM dbo.FF_PROCESSI_FASI_RISORSE WHERE IdFase = @IdFase;
    DELETE FROM dbo.FF_PROCESSI_FASI WHERE IdFase = @IdFase;

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

    SELECT A.IdAttivita, A.IdVersione, V.IdProcesso, P.CodProcesso, P.Descrizione AS ProcessoDescrizione,
           A.IdDichiarazione, A.DataProduzione, A.Stato, A.CodArticolo, A.QuantitaPrevista, A.QuantitaConsuntivata,
           A.IdLinea, L.CodLinea, L.NomeLinea, A.IdMacchina, M.CodMacchina, M.NomeMacchina, A.IdTeam, T.CodTeam,
           A.OraInizio, A.OraFine, A.Note
    FROM dbo.FF_ATTIVITA_PRODUTTIVE A
    INNER JOIN dbo.FF_PROCESSI_VERSIONI V ON V.IdVersione = A.IdVersione
    INNER JOIN dbo.FF_PROCESSI_PRODUTTIVI P ON P.IdProcesso = V.IdProcesso
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
    @IdDichiarazione bigint = NULL,
    @DataProduzione date,
    @Stato varchar(20) = 'PREVISTA',
    @CodArticolo varchar(30),
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

    IF @IdAttivita IS NULL OR NOT EXISTS (SELECT 1 FROM dbo.FF_ATTIVITA_PRODUTTIVE WHERE IdAttivita=@IdAttivita)
    BEGIN
        INSERT INTO dbo.FF_ATTIVITA_PRODUTTIVE
            (IdVersione, IdDichiarazione, DataProduzione, Stato, CodArticolo, QuantitaPrevista, QuantitaConsuntivata,
             IdLinea, IdMacchina, IdTeam, OraInizio, OraFine, Note, UtenteCreazione)
        VALUES
            (@IdVersione, @IdDichiarazione, @DataProduzione, @Stato, @CodArticolo, @QuantitaPrevista, @QuantitaConsuntivata,
             @IdLinea, @IdMacchina, @IdTeam, @OraInizio, @OraFine, @Note, @Utente);
        SET @IdAttivita = CONVERT(bigint, SCOPE_IDENTITY());
    END
    ELSE
    BEGIN
        UPDATE dbo.FF_ATTIVITA_PRODUTTIVE
        SET IdVersione=@IdVersione, IdDichiarazione=@IdDichiarazione, DataProduzione=@DataProduzione, Stato=@Stato, CodArticolo=@CodArticolo,
            QuantitaPrevista=@QuantitaPrevista, QuantitaConsuntivata=@QuantitaConsuntivata, IdLinea=@IdLinea, IdMacchina=@IdMacchina,
            IdTeam=@IdTeam, OraInizio=@OraInizio, OraFine=@OraFine, Note=@Note, DataModifica=SYSDATETIME(), UtenteModifica=@Utente
        WHERE IdAttivita=@IdAttivita;
    END;

    SELECT * FROM dbo.FF_ATTIVITA_PRODUTTIVE WHERE IdAttivita=@IdAttivita;
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_FF_ProcessiFasiRisorse_List
    @IdFase int
AS
BEGIN
    SET NOCOUNT ON;
    SELECT R.IdFaseRisorsa, R.IdFase, R.IdLinea, L.CodLinea, L.NomeLinea,
           R.IdMacchina, M.CodMacchina, M.NomeMacchina,
           R.IdTeam, T.CodTeam, T.Descrizione AS TeamDescrizione,
           R.ValidoDal, R.ValidoAl, R.VelocitaReale, R.TempoSetupAggiuntivoMinuti,
           R.ScartoMedio, R.EnergiaAggiuntiva, R.OperatoriMinimi, R.OperatoriConsigliati,
           R.CompetenzeRichieste, R.Note
    FROM dbo.FF_PROCESSI_FASI_RISORSE R
    LEFT JOIN dbo.FF_LINEE_LAVORAZIONE L ON L.IdLinea = R.IdLinea
    LEFT JOIN dbo.FF_MACCHINE M ON M.IdMacchina = R.IdMacchina
    LEFT JOIN dbo.FF_TEAM_OPERATIVI T ON T.IdTeam = R.IdTeam
    WHERE R.IdFase = @IdFase
    ORDER BY CASE WHEN R.ValidoAl IS NULL THEN 0 ELSE 1 END, R.ValidoDal DESC, R.IdFaseRisorsa DESC;
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_FF_ProcessiFasiRisorse_Save
    @IdFaseRisorsa int = NULL,
    @IdFase int,
    @IdLinea int = NULL,
    @IdMacchina int = NULL,
    @IdTeam int = NULL,
    @ValidoDal date,
    @ValidoAl date = NULL,
    @VelocitaReale decimal(18,6) = NULL,
    @TempoSetupAggiuntivoMinuti decimal(18,3) = NULL,
    @ScartoMedio decimal(9,4) = NULL,
    @EnergiaAggiuntiva decimal(18,6) = NULL,
    @OperatoriMinimi int = NULL,
    @OperatoriConsigliati int = NULL,
    @CompetenzeRichieste varchar(500) = NULL,
    @Note varchar(500) = NULL,
    @Utente varchar(50) = 'FactoryFlow'
AS
BEGIN
    SET NOCOUNT ON;

    IF @IdLinea IS NULL AND @IdMacchina IS NULL AND @IdTeam IS NULL
        THROW 51000, 'Associare almeno una linea, una macchina o un team alla fase.', 1;

    IF @ValidoAl IS NOT NULL AND @ValidoAl < @ValidoDal
        THROW 51001, 'Periodo validita risorsa non coerente.', 1;

    IF EXISTS (
        SELECT 1
        FROM dbo.FF_PROCESSI_FASI_RISORSE
        WHERE IdFase = @IdFase
          AND ValidoAl IS NULL
          AND ISNULL(IdLinea, -1) = ISNULL(@IdLinea, -1)
          AND ISNULL(IdMacchina, -1) = ISNULL(@IdMacchina, -1)
          AND ISNULL(IdTeam, -1) = ISNULL(@IdTeam, -1)
          AND (@IdFaseRisorsa IS NULL OR IdFaseRisorsa <> @IdFaseRisorsa)
    )
        THROW 51002, 'Esiste gia una risorsa aperta uguale per questa fase.', 1;

    IF @IdFaseRisorsa IS NULL OR NOT EXISTS (SELECT 1 FROM dbo.FF_PROCESSI_FASI_RISORSE WHERE IdFaseRisorsa = @IdFaseRisorsa)
    BEGIN
        INSERT INTO dbo.FF_PROCESSI_FASI_RISORSE
            (IdFase, IdLinea, IdMacchina, IdTeam, ValidoDal, ValidoAl, VelocitaReale, TempoSetupAggiuntivoMinuti,
             ScartoMedio, EnergiaAggiuntiva, OperatoriMinimi, OperatoriConsigliati, CompetenzeRichieste, Note, UtenteCreazione)
        VALUES
            (@IdFase, @IdLinea, @IdMacchina, @IdTeam, @ValidoDal, @ValidoAl, @VelocitaReale, @TempoSetupAggiuntivoMinuti,
             @ScartoMedio, @EnergiaAggiuntiva, @OperatoriMinimi, @OperatoriConsigliati, @CompetenzeRichieste, @Note, @Utente);
    END
    ELSE
    BEGIN
        UPDATE dbo.FF_PROCESSI_FASI_RISORSE
        SET IdLinea = @IdLinea,
            IdMacchina = @IdMacchina,
            IdTeam = @IdTeam,
            ValidoDal = @ValidoDal,
            ValidoAl = @ValidoAl,
            VelocitaReale = @VelocitaReale,
            TempoSetupAggiuntivoMinuti = @TempoSetupAggiuntivoMinuti,
            ScartoMedio = @ScartoMedio,
            EnergiaAggiuntiva = @EnergiaAggiuntiva,
            OperatoriMinimi = @OperatoriMinimi,
            OperatoriConsigliati = @OperatoriConsigliati,
            CompetenzeRichieste = @CompetenzeRichieste,
            Note = @Note,
            DataModifica = SYSDATETIME(),
            UtenteModifica = @Utente
        WHERE IdFaseRisorsa = @IdFaseRisorsa;
    END;

    EXEC dbo.sp_FF_ProcessiFasiRisorse_List @IdFase = @IdFase;
END;
GO

