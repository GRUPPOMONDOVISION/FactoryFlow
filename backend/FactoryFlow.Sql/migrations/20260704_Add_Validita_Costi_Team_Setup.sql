SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
SET XACT_ABORT ON;

IF COL_LENGTH('dbo.FF_TEAM_OPERATORI', 'ValidoDal') IS NULL
    ALTER TABLE dbo.FF_TEAM_OPERATORI ADD ValidoDal date NULL;

IF COL_LENGTH('dbo.FF_TEAM_OPERATORI', 'ValidoAl') IS NULL
    ALTER TABLE dbo.FF_TEAM_OPERATORI ADD ValidoAl date NULL;

EXEC(N'
UPDATE T
SET ValidoDal = CONVERT(date, T.DataCreazione)
FROM dbo.FF_TEAM_OPERATORI T
WHERE T.ValidoDal IS NULL;
');

EXEC(N'
UPDATE T
SET CostoOrarioApplicato = O.CostoOrarioRiferimento
FROM dbo.FF_TEAM_OPERATORI T
INNER JOIN dbo.FF_OPERATORI O ON O.IdOperatore = T.IdOperatore
WHERE T.CostoOrarioApplicato IS NULL
  AND O.CostoOrarioRiferimento IS NOT NULL;
');

EXEC(N'
;WITH DuplicatiAperti AS
(
    SELECT IdTeamOperatore,
           ROW_NUMBER() OVER
           (
               PARTITION BY IdTeam, IdOperatore
               ORDER BY IdTeamOperatore
           ) AS NumeroRiga
    FROM dbo.FF_TEAM_OPERATORI
    WHERE ValidoAl IS NULL
)
UPDATE T
SET ValidoAl = CAST(GETDATE() AS date),
    Attivo = 0,
    DataModifica = SYSDATETIME(),
    UtenteModifica = ''FactoryFlow''
FROM dbo.FF_TEAM_OPERATORI T
INNER JOIN DuplicatiAperti D ON D.IdTeamOperatore = T.IdTeamOperatore
WHERE D.NumeroRiga > 1;
');

IF NOT EXISTS
(
    SELECT 1
    FROM sys.check_constraints
    WHERE name = 'CK_FF_TEAM_OPERATORI_Periodo'
      AND parent_object_id = OBJECT_ID('dbo.FF_TEAM_OPERATORI')
)
    EXEC(N'ALTER TABLE dbo.FF_TEAM_OPERATORI ADD CONSTRAINT CK_FF_TEAM_OPERATORI_Periodo CHECK (ValidoAl IS NULL OR ValidoAl >= ValidoDal);');

IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE name = 'UX_FF_TEAM_OPERATORI_TeamOperatore_Aperto'
      AND object_id = OBJECT_ID('dbo.FF_TEAM_OPERATORI')
)
    EXEC(N'CREATE UNIQUE INDEX UX_FF_TEAM_OPERATORI_TeamOperatore_Aperto ON dbo.FF_TEAM_OPERATORI(IdTeam, IdOperatore) WHERE ValidoAl IS NULL;');

IF COL_LENGTH('dbo.FF_SETUP_REGOLE', 'ValidoDal') IS NULL
    ALTER TABLE dbo.FF_SETUP_REGOLE ADD ValidoDal date NULL;

IF COL_LENGTH('dbo.FF_SETUP_REGOLE', 'ValidoAl') IS NULL
    ALTER TABLE dbo.FF_SETUP_REGOLE ADD ValidoAl date NULL;

EXEC(N'
UPDATE R
SET ValidoDal = CONVERT(date, R.DataCreazione)
FROM dbo.FF_SETUP_REGOLE R
WHERE R.ValidoDal IS NULL;
');

IF NOT EXISTS
(
    SELECT 1
    FROM sys.check_constraints
    WHERE name = 'CK_FF_SETUP_REGOLE_Periodo'
      AND parent_object_id = OBJECT_ID('dbo.FF_SETUP_REGOLE')
)
    EXEC(N'ALTER TABLE dbo.FF_SETUP_REGOLE ADD CONSTRAINT CK_FF_SETUP_REGOLE_Periodo CHECK (ValidoAl IS NULL OR ValidoAl >= ValidoDal);');


