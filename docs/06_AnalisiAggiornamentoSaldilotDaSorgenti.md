# Analisi aggiornamento SALDILOT da sorgenti AdHoc

Data analisi: 2026-06-30
Sorgente principale: `E:\work1\ahr80_morettino\vfcssrc\gsve_mdv.prg`

## Obiettivo

Capire come AdHoc aggiorna `SALDILOT` durante il salvataggio di un documento di magazzino/produzione e perche' i documenti creati via FactoryFlow non muovono automaticamente i saldi lotto.

## Punto di ingresso sorgente

Nel file `gsve_mdv.prg` il salvataggio righe passa da:

```text
gsve_mdv.prg:7580..7665
```

Flusso rilevante:

```foxpro
scan for (...) 
  this.WorkFromTrs()
  ...
  if I_SRV="A"
    this.mUpdateTrsDetail()
    =this.mInsertDetail(i_NR)
  else
    this.mRestoreTrsDetail(.t.)
    this.mUpdateTrsDetail(.t.)
    ... UPDATE DOC_DETT ...
  endif
endscan
```

Quindi AdHoc aggiorna i saldi prima/durante il salvataggio applicativo della riga, non tramite trigger SQL su `DOC_DETT`.

## Routine che aggiorna SALDILOT

La routine e':

```text
gsve_mdv.prg:8264  proc mUpdateTrsDetail(i_bCanSkip)
```

Il blocco specifico `SALDILOT` e':

```text
gsve_mdv.prg:8588..8655
```

Estratto logico:

```foxpro
i_nConn = i_TableProp[this.SALDILOT_IDX,3]
i_cTable = cp_SetAzi(i_TableProp[this.SALDILOT_IDX,2])

i_bSkip = i_bCanSkip ;
    and old.MVFLCASC == this.w_MVFLCASC ;
    and old.MVQTAUM1 == this.w_MVQTAUM1 ;
    and old.MVFLRISE == this.w_MVFLRISE ;
    and old.MVQTASAL == this.w_MVQTASAL ;
    and old.MVLOTMAG == this.w_MVLOTMAG ;
    and old.MVKEYSAL == this.w_MVKEYSAL ;
    and old.MVCODUBI == this.w_MVCODUBI ;
    and old.MVCODLOT == this.w_MVCODLOT

i_cOp1 = cp_SetTrsOp(this.w_MVFLCASC, 'SUQTAPER', 'this.w_MVQTAUM1', this.w_MVQTAUM1, 'update', i_nConn)
i_cOp2 = cp_SetTrsOp(this.w_MVFLRISE, 'SUQTRPER', 'this.w_MVQTASAL', this.w_MVQTASAL, 'update', i_nConn)

if !i_bSkip and !Empty(this.w_MVLOTMAG)
  UPDATE SALDILOT
     SET SUQTAPER = i_cOp1,
         SUQTRPER = i_cOp2,
         UTCV = i_codute,
         UTDV = SetInfoDate(...),
         CPCCCHK = cp_NewCCChk()
   WHERE SUCODMAG = this.w_MVLOTMAG
     AND SUCODART = this.w_MVKEYSAL
     AND SUCODUBI = this.w_MVCODUBI
     AND SUCODLOT = this.w_MVCODLOT

  if nessuna riga aggiornata and !Empty(this.w_MVLOTMAG)
    INSERT INTO SALDILOT
      (SUCODMAG, SUCODART, SUCODUBI, SUCODLOT,
       SUQTAPER, SUQTRPER, UTCV, UTDV, CPCCCHK)
  endif
endif
```

## Campi DOC_DETT usati per aggiornare SALDILOT

La routine non usa direttamente `MVFLLOTT` per il calcolo del saldo. Usa questi campi della riga:

| Campo DOC_DETT | Uso |
|---|---|
| `MVFLCASC` | segno carico/scarico per `SUQTAPER` |
| `MVQTAUM1` | quantita da applicare a `SUQTAPER` |
| `MVFLRISE` | segno riservato per `SUQTRPER` |
| `MVQTASAL` | quantita da applicare a `SUQTRPER` |
| `MVLOTMAG` | magazzino saldo lotto, chiave `SUCODMAG` |
| `MVKEYSAL` | articolo saldo, chiave `SUCODART` |
| `MVCODUBI` | ubicazione, chiave `SUCODUBI` |
| `MVCODLOT` | lotto, chiave `SUCODLOT` |

La condizione operativa fondamentale e':

```foxpro
!Empty(this.w_MVLOTMAG)
```

Se `MVLOTMAG` e' vuoto, AdHoc non aggiorna `SALDILOT`.

## Calcolo di MVFLLOTT e MVLOTMAG

Nel sorgente il calcolo e' in:

```text
gsve_mdv.prg:5200..5410
gsve_mdv.prg:9250..9505
```

Regole rilevanti:

```foxpro
w_MVFLLOTT = IIF(
  (g_PERLOT='S' AND w_FLLOTT $ 'SC') OR (g_PERUBI='S' AND w_FLUBIC='S'),
  LEFT(ALLTRIM(w_MVFLCASC) + IIF(w_MVFLRISE='+','-',IIF(w_MVFLRISE='-','+',' ')), 1),
  ' '
)

w_MVLOTMAG = IIF(
  Empty(w_MVCODLOT) And Empty(w_MVCODUBI),
  SPACE(5),
  w_MVCODMAG
)
```

Quindi:
- se la riga ha lotto (`MVCODLOT`) o ubicazione (`MVCODUBI`), `MVLOTMAG` deve essere il magazzino riga (`MVCODMAG`);
- se non ha lotto/ubicazione, `MVLOTMAG` resta vuoto e `SALDILOT` non viene toccato;
- `MVFLLOTT` e' coerente con `MVFLCASC`, ma il saldo viene mosso da `MVFLCASC/MVQTAUM1`.

## Verifica sui documenti FactoryFlow

Query eseguita:

```sql
SELECT MVSERIAL, CPROWNUM, MVCODART, MVKEYSAL, MVCODMAG, MVLOTMAG,
       MVCODUBI, MVCODLOT, MVQTAUM1, MVFLCASC, MVFLRISE,
       MVQTASAL, MVFLLOTT, MVCAUMAG
FROM MOROSDOC_DETT
WHERE MVSERIAL IN ('0000170012','0000170013')
ORDER BY MVSERIAL, CPROWNUM;
```

Risultato chiave:

| Serial | Riga | Articolo | MVLOTMAG | MVCODLOT | MVQTAUM1 | MVFLCASC | MVFLRISE | MVQTASAL |
|---|---:|---|---|---|---:|---|---|---:|
| 0000170012 | 1 | CAPSULABIALETTIDIST | NULL | NULL | 1.000 | + | NULL | 1.000 |
| 0000170013 | 1 | CAPSULABIALETTI | MP | 0090 | 1.000 | - | NULL | 1.000 |
| 0000170013 | 2 | CARTAALLUMINIOMICROF | MP | JOB 20295 | 0.380 | - | NULL | 0.380 |
| 0000170013 | 3 | CARTAFILTRO1 | MP | 47848787 | 0.110 | - | NULL | 0.110 |
| 0000170013 | 4 | TOPBIALETTI | MP | 22-1335-002 | 0.220 | - | NULL | 0.220 |

Le righe scarico FactoryFlow hanno tutti i campi necessari per muovere `SALDILOT`.

## Perche' SALDILOT non si aggiorna con il solo POST FactoryFlow

Dai sorgenti risulta che `SALDILOT` viene aggiornato da codice applicativo nel salvataggio riga (`mUpdateTrsDetail`), non da trigger o da una tabella intermedia.

Il POST FactoryFlow oggi:
- inserisce `DOC_MAST`;
- inserisce `DOC_DETT`;
- aggiorna `cpwarn`;
- non esegue la logica equivalente a `mUpdateTrsDetail` su `SALDILOT`.

Questo spiega perche':
- i documenti risultano corretti;
- `AGG_LOTT`, `AGG_SALD`, `SDMOVMAG` non vengono popolati;
- `SALDILOT` rimane invariato.

## Equivalente SQL da replicare nella stored

Per ogni riga con `MVLOTMAG` valorizzato:

```sql
UPDATE MOROSSALDILOT
SET
    SUQTAPER = CASE MVFLCASC
                   WHEN '+' THEN SUQTAPER + MVQTAUM1
                   WHEN '-' THEN SUQTAPER - MVQTAUM1
                   ELSE SUQTAPER
               END,
    SUQTRPER = CASE MVFLRISE
                   WHEN '+' THEN SUQTRPER + MVQTASAL
                   WHEN '-' THEN SUQTRPER - MVQTASAL
                   ELSE SUQTRPER
               END,
    UTCV = <utente>,
    UTDV = GETDATE(),
    CPCCCHK = <nuovo cpccchk>
WHERE SUCODMAG = MVLOTMAG
  AND SUCODART = MVKEYSAL
  AND ISNULL(SUCODUBI, '') = ISNULL(MVCODUBI, '')
  AND SUCODLOT = MVCODLOT;
```

Se l'update non trova righe e `MVLOTMAG` e' valorizzato, AdHoc fa insert:

```sql
INSERT INTO MOROSSALDILOT
    (SUCODMAG, SUCODART, SUCODUBI, SUCODLOT,
     SUQTAPER, SUQTRPER, UTCV, UTDV, CPCCCHK)
VALUES
    (MVLOTMAG, MVKEYSAL, MVCODUBI, MVCODLOT,
     <quantita firmata da MVFLCASC>,
     <quantita firmata da MVFLRISE>,
     <utente>, GETDATE(), <nuovo cpccchk>);
```

## Impatto sul caso FactoryFlow testato

Per lo scarico `0000170013` l'effetto atteso, se si replica `mUpdateTrsDetail`, e':

| Lotto | Campo | Variazione attesa |
|---|---|---:|
| CAPSULABIALETTI / MP / 0090 | SUQTAPER | -1.000 |
| CARTAALLUMINIOMICROF / MP / JOB 20295 | SUQTAPER | -0.380 |
| CARTAFILTRO1 / MP / 47848787 | SUQTAPER | -0.110 |
| TOPBIALETTI / MP / 22-1335-002 | SUQTAPER | -0.220 |

`SUQTRPER` resta invariato perche' `MVFLRISE` e' vuoto/null sulle righe.

Per il carico `0000170012` non c'e' movimento lotto perche' il prodotto finito del test (`CAPSULABIALETTIDIST`) non e' gestito a lotti e `MVLOTMAG/MVCODLOT` sono vuoti.

## Conclusione

Il problema residuo non sembra essere nei campi documentali principali: i dati `DOC_MAST/DOC_DETT` dello scarico sono ormai coerenti con AdHoc manuale.

La mancanza e' che la stored non replica la parte di salvataggio applicativo che aggiorna `SALDILOT`.

La prossima modifica alla SP dovrebbe aggiungere, dentro la stessa transazione, l'equivalente SQL del blocco `mUpdateTrsDetail` per `SALDILOT`, usando le righe appena create in `DOC_DETT` o i dati componenti gia' disponibili.
