# Report differenze SQL - Produzione AdHoc vs FactoryFlow

Data analisi: 2026-06-30
Database: MOROSITO
Azienda: MOROS

## Documenti confrontati

Manuale AdHoc:
- Carico PF: MVSERIAL 0000170003, DPPRF / DP, numero 811
- Scarico componenti: MVSERIAL 0000170004, SCOMP / alfanumerico vuoto, numero 1563, collegato a DP 811

FactoryFlow:
- Carico PF: MVSERIAL 0000170010, DPPRF / DP, numero 812
- Scarico componenti: MVSERIAL 0000170011, SCOMP / DP, numero 813, collegato a DP 812

## Query: testate DOC_MAST

```sql
SELECT MVSERIAL, MVNUMREG, MVTIPDOC, MVALFDOC, MVNUMDOC,
       MVPRD, MVCODESE, MVPRP, MVANNDOC, MVNUMEST, MVALFEST,
       MVDATDOC, MVDATPLA, MVDATCIV, MVTCAMAG,
       MVCATOPE, MVTIPDIS, MVGENPOS, MVSTFILCB, MVFLGINC,
       MVEMERIC, MV__ANNO, MV__MESE
FROM MOROSDOC_MAST
WHERE MVSERIAL IN ('0000170003','0000170004','0000170010','0000170011')
ORDER BY MVSERIAL;
```

Differenze rilevanti:

| Campo | Manuale carico | Factory carico | Manuale scarico | Factory scarico |
|---|---:|---:|---:|---:|
| MVTIPDOC | DPPRF | DPPRF | SCOMP | SCOMP |
| MVALFDOC | DP | DP | vuoto | DP |
| MVNUMDOC | 811 | 812 | 1563 | 813 |
| MVNUMEST | 0 | 0 | 811 | 812 |
| MVALFEST | vuoto | NULL | DP | DP |
| MVTCAMAG | PRCAR | PRCAR | 205 | PRSCA |

Nota: la configurazione tipo documento AdHoc conferma che `SCOMP` ha alfanumerico vuoto e causale magazzino `205`.

## Query: dettagli DOC_DETT

```sql
SELECT MVSERIAL, CPROWNUM, CPROWORD, MVCODART, MVCODMAG, MVCODLOT,
       MVCAUMAG, MVQTAMOV, MVQTAUM1, MVQTASAL,
       MVFLCASC, MVFLLOTT, MVFLOMAG, MVFLELGM, MVFLELAN,
       MVTIPATT, MVTIPPRO, MVTIPPR2, MV_SEGNO, MVKEYSAL,
       MVRIFESC, MVDATOAI, MVCATCON, MVCODIVA
FROM MOROSDOC_DETT
WHERE MVSERIAL IN ('0000170003','0000170004','0000170010','0000170011')
ORDER BY MVSERIAL, CPROWNUM;
```

Differenze rilevanti:

| Area | Manuale | FactoryFlow |
|---|---|---|
| Righe scarico - MVCAUMAG | 205 | PRSCA |
| Righe scarico - MV_SEGNO | D | A |
| Testata scarico - MVTCAMAG | 205 | PRSCA |
| Testata scarico - MVALFDOC | vuoto | DP |
| PF lotto | manuale PF lottizzato con MVFLLOTT = + | test Factory PF non lottizzato, MVFLLOTT vuoto |
| MVRIFESC carico | punta allo scarico | punta allo scarico |
| MVFLCASC scarico | - | - |
| MVFLLOTT scarico | - sui componenti lottizzati | - sui componenti lottizzati |

Il lato scarico e' il piu rilevante per SALDILOT: FactoryFlow ha segni lotto corretti, ma usa causale `PRSCA` e `MV_SEGNO = A`; il manuale usa causale `205` e `MV_SEGNO = D`.

## Query: tipo documento AdHoc

```sql
SELECT TDTIPDOC, TDDESDOC, TDPRODOC, TDALFDOC, TDCAUMAG,
       TDCODMAG, TDCAUPFI, TD_SEGNO, TDFLELAN, TDLOTDIF
FROM MOROSTIP_DOCU
WHERE TDTIPDOC IN ('DPPRF','SCOMP');
```

Risultato chiave:

| TDTIPDOC | TDALFDOC | TDCAUMAG | TD_SEGNO | TDLOTDIF |
|---|---|---|---|---|
| DPPRF | DP | PRCAR | D | I |
| SCOMP | vuoto | 205 | D | I |

Questo indica che lo scarico componenti AdHoc non usa `PRSCA` e non usa alfanumerico `DP` come valore proprio del documento; il collegamento al carico e' invece tramite `MVNUMEST = numero carico` e `MVALFEST = DP`.

## Query: tabelle correlate con seriale documento

```sql
DECLARE @sql nvarchar(max) = N'';
SELECT @sql = @sql + N'SELECT ''' + TABLE_NAME + N''' AS TableName, ''' + COLUMN_NAME + N''' AS ColumnName, COUNT(*) AS Cnt FROM '
    + QUOTENAME(TABLE_NAME) + N' WHERE ' + QUOTENAME(COLUMN_NAME)
    + N' IN (''0000170003'',''0000170004'',''0000170010'',''0000170011'') HAVING COUNT(*) > 0 UNION ALL '
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME LIKE 'MOROS%'
  AND COLUMN_NAME IN ('MVSERIAL','MMSERIAL','TRSERIAL','MVSERRIF','MVRIFESC');
SET @sql = LEFT(@sql, LEN(@sql)-10);
EXEC sp_executesql @sql;
```

Risultato:

| Tabella | Colonna | Righe |
|---|---|---:|
| MOROSDOC_MAST | MVSERIAL | 4 |
| MOROSDOC_DETT | MVSERIAL | 11 |
| MOROSDOC_DETT | MVRIFESC | 2 |

Non sono state trovate righe correlate per seriale in tabelle movimenti/saldi diverse da DOC_MAST/DOC_DETT.

## Query: tabelle lotto/saldi candidate

```sql
SELECT * FROM MOROSAGG_LOTT
WHERE MVSERIAL IN ('0000170003','0000170004','0000170010','0000170011');

SELECT * FROM MOROSAGG_SALD
WHERE TRSERIAL IN ('0000170003','0000170004','0000170010','0000170011');

SELECT * FROM MOROSSDMOVMAG
WHERE MMSERIAL IN ('0000170003','0000170004','0000170010','0000170011');
```

Risultato: nessuna riga per manuale e nessuna riga per FactoryFlow.

## Query: saldi lotto interessati

```sql
SELECT LTRIM(RTRIM(S.SUCODART)) AS Articolo,
       LTRIM(RTRIM(S.SUCODMAG)) AS Mag,
       LTRIM(RTRIM(S.SUCODLOT)) AS Lotto,
       CAST(S.SUQTAPER AS decimal(18,6)) AS SUQTAPER,
       CAST(S.SUQTAPRO AS decimal(18,6)) AS SUQTAPRO,
       L.LODATSCA
FROM MOROSSALDILOT S
LEFT JOIN MOROSLOTTIART L
  ON LTRIM(RTRIM(L.LOCODART)) = LTRIM(RTRIM(S.SUCODART))
 AND LTRIM(RTRIM(L.LOCODICE)) = LTRIM(RTRIM(S.SUCODLOT))
WHERE LTRIM(RTRIM(S.SUCODLOT)) IN
('43KC','422231721032154','23-0897-001','0619092023','0417102023',
 'FFTEST0001','0090','JOB 20295','47848787','22-1335-002');
```

Osservazioni:
- i saldi lotto sono mantenuti direttamente in `MOROSSALDILOT`;
- non e' emersa una tabella movimento lotto collegata al seriale documento;
- il test FactoryFlow non ha creato/aggiornato un saldo lotto per `FFTEST0001` perche' il PF usato (`CAPSULABIALETTIDIST`) non e' gestito a lotti (`ARFLLOTT = N`);
- i saldi dei componenti FactoryFlow sono rimasti invariati dopo il POST.

## Query: articoli coinvolti

```sql
SELECT ARCODART, ARDESART, ARFLLOTT, ARCODDIS
FROM MOROSART_ICOL
WHERE ARCODART IN
('PMIO00M3BOBBLISFU','CAPSULABIALETTIDIST','CAPSULAAMODOMIO','CAPSULABIALETTI',
 'CARTAMICROFOR01','CARTAALLUMINIOMICROF','RIBBONIN','CARTAFILTRO1','TOST/3','TOPBIALETTI')
ORDER BY ARCODART;
```

Differenza di scenario:
- manuale: PF `PMIO00M3BOBBLISFU` con `ARFLLOTT = S`;
- FactoryFlow test: PF `CAPSULABIALETTIDIST` con `ARFLLOTT = N`.

## Conclusione tecnica

I documenti FactoryFlow sono creati in `DOC_MAST/DOC_DETT`, ma differiscono dal manuale AdHoc nei campi che sembrano governare la movimentazione reale:

1. `SCOMP` manuale usa `MVALFDOC` vuoto; FactoryFlow usa `DP`.
2. `SCOMP` manuale usa `MVTCAMAG = 205`; FactoryFlow usa `PRSCA`.
3. Righe scarico manuali usano `MVCAUMAG = 205`; FactoryFlow usa `PRSCA`.
4. Righe manuali hanno `MV_SEGNO = D`; FactoryFlow ha `A`.
5. Il tipo documento `MOROSTIP_DOCU` conferma `SCOMP -> TDCAUMAG = 205`, `TDALFDOC` vuoto, `TD_SEGNO = D`.
6. Non risultano tabelle movimento/saldo correlate per seriale oltre a `DOC_MAST/DOC_DETT`; quindi l'aggiornamento saldi lotto sembra derivare dai campi documento/causale oppure da logica applicativa AdHoc, non da trigger SQL su DOC.

Ipotesi SQL piu probabile da verificare nel prossimo intervento: per aggiornare `SALDILOT`, la SP deve riprodurre i valori di documento AdHoc manuale almeno per scarico `SCOMP`: `MVTCAMAG/MVCAUMAG = 205`, `MV_SEGNO = D`, `MVALFDOC` vuoto sulla testata scarico, mantenendo `MVNUMEST/MVALFEST` verso il carico `DP`.
