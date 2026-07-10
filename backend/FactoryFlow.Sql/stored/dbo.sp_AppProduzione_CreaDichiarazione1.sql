/*
    FactoryFlow - Motore dichiarazione produzione
    Server SQL: SVILUPPO01\SQL2017
    Database: MOROSITO

    Stored procedure:
        dbo.sp_FactoryFlow_CreaDichiarazioneProduzione

    Origine:
        Derivata da dbo.sp_AppProduzione_CreaDichiarazione e validata in chat.

    Regole principali:
        - Scrive direttamente su [AZIENDA]DOC_MAST e [AZIENDA]DOC_DETT.
        - Genera documento carico prodotto finito DPPRF / DP.
        - Genera documento scarico componenti SCOMP / alfanumerico vuoto.
        - Usa cpwarn con chiave completa aziendale per SEDOC e PRDOC.
        - Gestisce lotti solo se ART_ICOL.ARFLLOTT = 'S'.
        - MVFLCASC = '+' per carico, '-' per scarico.
        - MVFLLOTT = '+' per carico lotto, '-' per scarico lotto.
        - Non blocca per giacenza insufficiente: verifica solo esistenza lotto e scadenza.
        - Tutto in transazione unica con rollback completo in caso di errore.
*/

USE [MOROSITO];
GO

CREATE OR ALTER PROCEDURE dbo.sp_FactoryFlow_CreaDichiarazioneProduzione
(
    @CodAzi varchar(10),
    @Esercizio int,
    @DataRilevazione date,

    @ArticoloProdotto varchar(20),
    @LottoProdotto varchar(20),
    @MagazzinoProdotto varchar(5),
    @QuantitaProdotta decimal(18,3),

    @ComponentiJson nvarchar(max)
)
AS
BEGIN
    SET NOCOUNT ON;

    SET @CodAzi = LTRIM(RTRIM(@CodAzi));

    IF NULLIF(@CodAzi, '') IS NULL
        THROW 50000, 'Codice azienda mancante.', 1;

    DECLARE @T_DOC_MAST nvarchar(300) = QUOTENAME(@CodAzi + 'DOC_MAST');
    DECLARE @T_DOC_DETT nvarchar(300) = QUOTENAME(@CodAzi + 'DOC_DETT');
    DECLARE @T_ART      nvarchar(300) = QUOTENAME(@CodAzi + 'ART_ICOL');
    DECLARE @T_SALDILOT nvarchar(300) = QUOTENAME(@CodAzi + 'SALDILOT');
    DECLARE @T_LOTTIART nvarchar(300) = QUOTENAME(@CodAzi + 'LOTTIART');

    BEGIN TRY
        BEGIN TRAN;

        DECLARE @Sql nvarchar(max);

        ------------------------------------------------------------
        -- COMPONENTI JSON
        ------------------------------------------------------------
        DECLARE @Componenti TABLE
        (
            Riga int IDENTITY(1,1),
            CodArt varchar(20),
            Lotto varchar(20),
            Magazzino varchar(5),
            Quantita decimal(18,3)
        );

        INSERT INTO @Componenti (CodArt, Lotto, Magazzino, Quantita)
        SELECT codice, lotto, magazzino, quantita
        FROM OPENJSON(@ComponentiJson)
        WITH
        (
            codice varchar(20) '$.codice',
            lotto varchar(20) '$.lotto',
            magazzino varchar(5) '$.magazzino',
            quantita decimal(18,3) '$.quantita'
        );

        IF NOT EXISTS (SELECT 1 FROM @Componenti)
            THROW 50001, 'Nessun componente indicato.', 1;

        ------------------------------------------------------------
        -- ARTICOLO PRODOTTO
        ------------------------------------------------------------
        DECLARE
            @DescrProd varchar(100),
            @UmProd varchar(5),
            @CatConProd varchar(20),
            @IvaProd varchar(5),
            @GestLottiProd char(1);

        SET @Sql = '
            SELECT
                @Descr = ARDESART,
                @Um = ARUNMIS1,
                @CatCon = ARCATCON,
                @Iva = ARCODIVA,
                @GestLotti = ISNULL(ARFLLOTT, '''')
            FROM ' + @T_ART + '
            WHERE ARCODART = @CodArt;
        ';

        EXEC sp_executesql
            @Sql,
            N'@CodArt varchar(20),
              @Descr varchar(100) OUTPUT,
              @Um varchar(5) OUTPUT,
              @CatCon varchar(20) OUTPUT,
              @Iva varchar(5) OUTPUT,
              @GestLotti char(1) OUTPUT',
            @ArticoloProdotto,
            @DescrProd OUTPUT,
            @UmProd OUTPUT,
            @CatConProd OUTPUT,
            @IvaProd OUTPUT,
            @GestLottiProd OUTPUT;

        IF @DescrProd IS NULL
            THROW 50002, 'Articolo prodotto non trovato.', 1;

        IF @GestLottiProd = 'S'
        BEGIN
            IF NULLIF(LTRIM(RTRIM(@LottoProdotto)), '') IS NULL
                THROW 50003, 'Lotto prodotto obbligatorio.', 1;
        END;

        ------------------------------------------------------------
        -- VALIDAZIONE COMPONENTI
        ------------------------------------------------------------
        DECLARE @i int = 1;
        DECLARE @tot int = (SELECT COUNT(*) FROM @Componenti);

        WHILE @i <= @tot
        BEGIN
            DECLARE
                @CodComp varchar(20),
                @LotComp varchar(20),
                @MagComp varchar(5),
                @QtaComp decimal(18,3),
                @GestLottiComp char(1),
                @DescrComp varchar(100);

            SELECT
                @CodComp = CodArt,
                @LotComp = Lotto,
                @MagComp = Magazzino,
                @QtaComp = Quantita
            FROM @Componenti
            WHERE Riga = @i;

            SET @Sql = '
                SELECT
                    @Descr = ARDESART,
                    @GestLotti = ISNULL(ARFLLOTT, '''')
                FROM ' + @T_ART + '
                WHERE ARCODART = @CodArt;
            ';

            EXEC sp_executesql
                @Sql,
                N'@CodArt varchar(20),
                  @Descr varchar(100) OUTPUT,
                  @GestLotti char(1) OUTPUT',
                @CodComp,
                @DescrComp OUTPUT,
                @GestLottiComp OUTPUT;

            IF @DescrComp IS NULL
                THROW 50004, 'Componente non trovato in ART_ICOL.', 1;

            IF @QtaComp IS NULL OR @QtaComp <= 0
                THROW 50005, 'QuantitÃ  componente non valida.', 1;

            IF @GestLottiComp = 'S'
            BEGIN
                IF NULLIF(LTRIM(RTRIM(@LotComp)), '') IS NULL
                    THROW 50006, 'Lotto componente obbligatorio.', 1;

                SET @Sql = '
                    IF NOT EXISTS
                    (
                        SELECT 1
                        FROM ' + @T_SALDILOT + ' S
                        JOIN ' + @T_LOTTIART + ' L
                          ON L.LOCODART = S.SUCODART
                         AND L.LOCODICE = S.SUCODLOT
                        WHERE S.SUCODART = @CodArt
                          AND S.SUCODMAG = @Mag
                          AND S.SUCODLOT = @Lotto
                          AND (L.LODATSCA IS NULL OR L.LODATSCA > @DataRilevazione)
                    )
                    BEGIN
                        THROW 50007, ''Lotto componente non esistente o scaduto.'', 1;
                    END;
                ';

                EXEC sp_executesql
                    @Sql,
                    N'@CodArt varchar(20),
                      @Mag varchar(5),
                      @Lotto varchar(20),
                      @DataRilevazione date',
                    @CodComp,
                    @MagComp,
                    @LotComp,
                    @DataRilevazione;
            END;

            SET @i += 1;
        END;

        ------------------------------------------------------------
        -- CONTATORI CPWARN
        ------------------------------------------------------------
        DECLARE
            @BaseSerial int,
            @SerialCaricoNum int,
            @SerialScaricoNum int,
            @SerialCarico varchar(10),
            @SerialScarico varchar(10),
            @NumCarico int,
            @NumScarico int,
            @TableSeriale varchar(250),
            @TableCarico varchar(250),
            @TableScarico varchar(250);

        SET @TableSeriale =
            'prog\SEDOC\''' + @CodAzi + '''';

        SET @TableCarico =
            'prog\PRDOC\''' + @CodAzi + '''\''' +
            CAST(@Esercizio AS varchar(4)) + '''\''IV''\''DP        ''';

        SET @TableScarico =
            'prog\PRDOC\''' + @CodAzi + '''\''' +
            CAST(@Esercizio AS varchar(4)) + '''\''IV''\''          ''';

        SELECT @BaseSerial = autonum
        FROM cpwarn WITH (UPDLOCK, HOLDLOCK)
        WHERE tablecode = @TableSeriale
          AND warncode = @CodAzi;

        IF @BaseSerial IS NULL
            THROW 50008, 'Progressivo prog\SEDOC azienda non trovato in cpwarn.', 1;

        SET @SerialCaricoNum = @BaseSerial + 1;
        SET @SerialScaricoNum = @BaseSerial + 2;

        UPDATE cpwarn
        SET autonum = @SerialScaricoNum
        WHERE tablecode = @TableSeriale
          AND warncode = @CodAzi;

        SET @SerialCarico  = RIGHT('0000000000' + CAST(@SerialCaricoNum AS varchar(20)), 10);
        SET @SerialScarico = RIGHT('0000000000' + CAST(@SerialScaricoNum AS varchar(20)), 10);

        SELECT @NumCarico = autonum + 1
        FROM cpwarn WITH (UPDLOCK, HOLDLOCK)
        WHERE tablecode = @TableCarico
          AND warncode = @CodAzi;

        IF @NumCarico IS NULL
            THROW 50009, 'Progressivo documento DP non trovato in cpwarn.', 1;

        UPDATE cpwarn
        SET autonum = @NumCarico
        WHERE tablecode = @TableCarico
          AND warncode = @CodAzi;

        SELECT @NumScarico = autonum + 1
        FROM cpwarn WITH (UPDLOCK, HOLDLOCK)
        WHERE tablecode = @TableScarico
          AND warncode = @CodAzi;

        IF @NumScarico IS NULL
            THROW 50010, 'Progressivo documento SCOMP con alfanumerico vuoto non trovato in cpwarn.', 1;

        UPDATE cpwarn
        SET autonum = @NumScarico
        WHERE tablecode = @TableScarico
          AND warncode = @CodAzi;

        ------------------------------------------------------------
        -- DOC_MAST CARICO
        ------------------------------------------------------------
        SET @Sql = '
            INSERT INTO ' + @T_DOC_MAST + '
            (
                MVSERIAL, MVCODUTE, MVNUMREG, MVDATREG, MVDATPLA,
                MVTIPDOC, MVCLADOC, MVFLVEAC, MVFLINTE, MVFLPROV,
                MVPRD, MVCODESE, MVPRP, MVNUMDOC, MVALFDOC, MVDATDOC,
                MVANNDOC, MVDATCIV, MVTCAMAG, MVTFRAGG,
                MVVALNAZ, MVCODVAL, MVCAOVAL,
                MVCATOPE, MVIVAINC, MVIVATRA, MVIVAIMB, MVIVABOL,
                UTCC, UTCV, UTDC, UTDV,
                MVACIVA1, MVAIMPN1, MVAIMPS1, MVAFLOM1,
                MVTIPIMB, MVFLSEND, MV__ANNO, MV__MESE,
                MVTIPDIS, MVGENPOS, MVSTFILCB, MVFLGINC, MVEMERIC,
                cpccchk
            )
            VALUES
            (
                @SerialCarico, 0, @NumCarico, @Data, @Data,
                ''DPPRF'', ''DI'', ''V'', ''N'', ''N'',
                ''IV'', @Esercizio, ''NN'', @NumCarico, ''DP        '', @Data,
                @Esercizio, @Data, ''PRCAR'', 1,
                ''EUR'', ''EUR'', 1,
                ''OP'', ''22'', ''22'', ''22'', ''ESC2'',
                1, 1, GETDATE(), GETDATE(),
                ''22'', 0, 0, ''X'',
                ''N'', ''N'', @Esercizio, MONTH(@Data),
                ''N'', 0, 1, ''N'', ''V'',
                LOWER(LEFT(REPLACE(CONVERT(varchar(36), NEWID()), ''-'', ''''), 10))
            );
        ';

        EXEC sp_executesql
            @Sql,
            N'@SerialCarico varchar(10),
              @NumCarico int,
              @Data date,
              @Esercizio int',
            @SerialCarico,
            @NumCarico,
            @DataRilevazione,
            @Esercizio;

        ------------------------------------------------------------
        -- DOC_DETT CARICO
        ------------------------------------------------------------
        SET @Sql = '
            INSERT INTO ' + @T_DOC_DETT + '
            (
                MVSERIAL, CPROWNUM, CPROWORD, MVNUMRIF,
                MVCODICE, MVTIPRIG, MVDESART, MVCODART,
                MVUNIMIS, MVCATCON, MVCAUMAG, MVCODMAG,
                MVQTAMOV, MVQTAUM1, MVPREZZO,
                MVFLOMAG, MVCODIVA, MVVALRIG, MVVALMAG, MVIMPNAZ,
                MVFLCASC, MVKEYSAL, MVFLRAGG, MVQTASAL,
                MVDATEVA, MVFLELGM, MVTIPATT,
                MVFLELAN, MVRIFESC,
                MVFLLOTT, MVCODLOT, MVLOTMAG,
                MV_FLAGG, MVTIPPRO, MV_SEGNO, MVTIPPR2, MVFLNOAN,
                MVDATOAI,
                cpccchk
            )
            VALUES
            (
                @SerialCarico, 1, 10, -20,
                @Articolo, ''R'', @Descr, @Articolo,
                @Um, @CatCon, ''PRCAR'', @Magazzino,
                @Qta, @Qta, 0,
                ''X'', @Iva, 0, 0, 0,
                ''+'', @Articolo, 1, @Qta,
                @Data, ''S'', ''A'',
                ''S'', @SerialScarico,
                CASE WHEN @GestLotti = ''S'' THEN ''+'' ELSE '''' END,
                CASE WHEN @GestLotti = ''S'' THEN @Lotto ELSE NULL END,
                CASE WHEN @GestLotti = ''S'' THEN @Magazzino ELSE NULL END,
                ''N'', ''DC'', ''A'', ''DC'', ''N'',
                @Data,
                LOWER(LEFT(REPLACE(CONVERT(varchar(36), NEWID()), ''-'', ''''), 10))
            );
        ';

        EXEC sp_executesql
            @Sql,
            N'@SerialCarico varchar(10),
              @SerialScarico varchar(10),
              @Articolo varchar(20),
              @Descr varchar(100),
              @Um varchar(5),
              @CatCon varchar(20),
              @Magazzino varchar(5),
              @Qta decimal(18,3),
              @Iva varchar(5),
              @GestLotti char(1),
              @Lotto varchar(20),
              @Data date',
            @SerialCarico,
            @SerialScarico,
            @ArticoloProdotto,
            @DescrProd,
            @UmProd,
            @CatConProd,
            @MagazzinoProdotto,
            @QuantitaProdotta,
            @IvaProd,
            @GestLottiProd,
            @LottoProdotto,
            @DataRilevazione;

        ------------------------------------------------------------
        -- DOC_MAST SCARICO
        ------------------------------------------------------------
        SET @Sql = '
            INSERT INTO ' + @T_DOC_MAST + '
            (
                MVSERIAL, MVCODUTE, MVNUMREG, MVDATREG, MVDATPLA,
                MVTIPDOC, MVCLADOC, MVFLVEAC, MVFLINTE, MVFLPROV,
                MVPRD, MVCODESE, MVPRP, MVNUMDOC, MVALFDOC, MVDATDOC,
                MVANNDOC, MVNUMEST, MVALFEST, MVDATCIV,
                MVTCAMAG, MVTFRAGG,
                MVVALNAZ, MVCODVAL, MVCAOVAL,
                MVCATOPE, MVIVAINC, MVIVAIMB, MVIVABOL,
                UTCC, UTCV, UTDC, UTDV,
                MVACIVA1, MVAIMPN1, MVAIMPS1, MVAFLOM1,
                MVTIPIMB, MVFLSEND, MV__ANNO, MV__MESE,
                MVTIPDIS, MVGENPOS, MVSTFILCB, MVFLGINC, MVEMERIC,
                cpccchk
            )
            VALUES
            (
                @SerialScarico, 0, @NumScarico, @Data, NULL,
                ''SCOMP'', ''DI'', ''V'', ''N'', ''N'',
                ''IV'', @Esercizio, ''NN'', @NumScarico, ''          '', @Data,
                @Esercizio, @NumCarico, ''DP        '', @Data,
                ''205'', 1,
                ''EUR'', ''EUR'', 1,
                ''OP'', ''22'', ''22'', ''ESC2'',
                1, 1, GETDATE(), GETDATE(),
                ''22'', 0, 0, ''X'',
                ''N'', ''N'', 0, 0,
                ''N'', 0, 1, ''N'', ''V'',
                LOWER(LEFT(REPLACE(CONVERT(varchar(36), NEWID()), ''-'', ''''), 10))
            );
        ';

        EXEC sp_executesql
            @Sql,
            N'@SerialScarico varchar(10),
              @NumScarico int,
              @NumCarico int,
              @Data date,
              @Esercizio int',
            @SerialScarico,
            @NumScarico,
            @NumCarico,
            @DataRilevazione,
            @Esercizio;

        ------------------------------------------------------------
        -- DOC_DETT SCARICO COMPONENTI
        ------------------------------------------------------------
        SET @i = 1;

        WHILE @i <= @tot
        BEGIN
            DECLARE
                @Art varchar(20),
                @Lot varchar(20),
                @Mag varchar(5),
                @Qta decimal(18,3),
                @Descr varchar(100),
                @Um varchar(5),
                @CatCon varchar(20),
                @Iva varchar(5),
                @FlgLotti char(1);

            SELECT
                @Art = CodArt,
                @Lot = Lotto,
                @Mag = Magazzino,
                @Qta = Quantita
            FROM @Componenti
            WHERE Riga = @i;

            SET @Sql = '
                SELECT
                    @Descr = ARDESART,
                    @Um = ARUNMIS1,
                    @CatCon = ARCATCON,
                    @Iva = ARCODIVA,
                    @FlgLotti = ISNULL(ARFLLOTT, '''')
                FROM ' + @T_ART + '
                WHERE ARCODART = @Art;
            ';

            EXEC sp_executesql
                @Sql,
                N'@Art varchar(20),
                  @Descr varchar(100) OUTPUT,
                  @Um varchar(5) OUTPUT,
                  @CatCon varchar(20) OUTPUT,
                  @Iva varchar(5) OUTPUT,
                  @FlgLotti char(1) OUTPUT',
                @Art,
                @Descr OUTPUT,
                @Um OUTPUT,
                @CatCon OUTPUT,
                @Iva OUTPUT,
                @FlgLotti OUTPUT;

            SET @Sql = '
                INSERT INTO ' + @T_DOC_DETT + '
                (
                    MVSERIAL, CPROWNUM, CPROWORD, MVNUMRIF,
                    MVCODICE, MVTIPRIG, MVDESART, MVCODART,
                    MVUNIMIS, MVCATCON, MVCAUMAG, MVCODMAG,
                    MVQTAMOV, MVQTAUM1, MVPREZZO,
                    MVFLOMAG, MVCODIVA, MVVALRIG, MVVALMAG, MVIMPNAZ,
                    MVFLCASC, MVKEYSAL, MVFLRAGG, MVQTASAL,
                    MVDATEVA, MVFLELGM, MVTIPATT,
                    MVFLELAN,
                    MVFLLOTT, MVCODLOT, MVLOTMAG,
                    MV_FLAGG, MVTIPPRO, MV_SEGNO, MVTIPPR2, MVFLNOAN,
                    cpccchk
                )
                VALUES
                (
                    @SerialScarico, @Riga, @Riga * 10, -20,
                    @Art, ''R'', @Descr, @Art,
                    @Um, @CatCon, ''205'', @Mag,
                    @Qta, @Qta, 0,
                    ''X'', @Iva, 0, 0, 0,
                    ''-'', @Art, 1, @Qta,
                    @Data, ''S'', ''A'',
                    '''',
                    CASE WHEN @FlgLotti = ''S'' THEN ''-'' ELSE '''' END,
                    CASE WHEN @FlgLotti = ''S'' THEN @Lot ELSE NULL END,
                    CASE WHEN @FlgLotti = ''S'' THEN @Mag ELSE NULL END,
                    ''N'', ''DC'', ''D'', ''DC'', ''N'',
                    LOWER(LEFT(REPLACE(CONVERT(varchar(36), NEWID()), ''-'', ''''), 10))
                );
            ';

            EXEC sp_executesql
                @Sql,
                N'@SerialScarico varchar(10),
                  @Riga int,
                  @Art varchar(20),
                  @Descr varchar(100),
                  @Um varchar(5),
                  @CatCon varchar(20),
                  @Mag varchar(5),
                  @Qta decimal(18,3),
                  @Iva varchar(5),
                  @FlgLotti char(1),
                  @Lot varchar(20),
                  @Data date',
                @SerialScarico,
                @i,
                @Art,
                @Descr,
                @Um,
                @CatCon,
                @Mag,
                @Qta,
                @Iva,
                @FlgLotti,
                @Lot,
                @DataRilevazione;

            SET @i += 1;
        END;

        COMMIT;

        SELECT
            @SerialCarico AS SerialCarico,
            @NumCarico AS NumeroCarico,
            @SerialScarico AS SerialScarico,
            @NumScarico AS NumeroScarico;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        THROW;
    END CATCH;
END;
GO




