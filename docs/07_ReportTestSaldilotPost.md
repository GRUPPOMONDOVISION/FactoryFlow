# Report test aggiornamento SALDILOT

Data test: 2026-06-30

## Modifica applicata

La stored procedure `dbo.sp_FactoryFlow_CreaDichiarazioneProduzione` e stata integrata con l'aggiornamento di `[AZIENDA]SALDILOT` dentro la stessa transazione di creazione documenti.

La logica replica `mUpdateTrsDetail` individuata in `gsve_mdv.prg`:

- sorgente: righe `[AZIENDA]DOC_DETT` appena create;
- filtro: `MVSERIAL IN (@SerialCarico, @SerialScarico)`;
- solo righe con `MVLOTMAG` e `MVCODLOT` valorizzati;
- chiave saldo: `MVLOTMAG`, `MVKEYSAL`, `MVCODUBI`, `MVCODLOT`;
- `MVFLCASC = '+'`: incremento `SUQTAPER`;
- `MVFLCASC = '-'`: decremento `SUQTAPER`;
- `MVFLRISE = '+'`: incremento `SUQTRPER`;
- `MVFLRISE = '-'`: decremento `SUQTRPER`;
- `MVFLRISE` vuoto/null: `SUQTRPER` invariato;
- se il saldo non esiste, viene inserita una nuova riga `SALDILOT`;
- tabella dinamica: `QUOTENAME(@CodAzi + 'SALDILOT')`.

## Installazione stored

Installazione eseguita su:

- Server: `SVILUPPO01\SQL2017`
- Database: `MOROSITO`
- Stored: `dbo.sp_FactoryFlow_CreaDichiarazioneProduzione`

Esito installazione: completata senza errori.

## POST eseguito

Endpoint:

`POST http://localhost:5100/api/produzione/dichiarazione`

Caso minimo:

- azienda: `MOROS`
- esercizio: `2023`
- data produzione: `2023-11-03`
- articolo prodotto: `CAPSULABIALETTIDIST`
- quantita prodotta: `1`
- lotto prodotto: `FFTEST0001`
- magazzino prodotto: `01`

Componenti:

| Componente | Magazzino | Lotto | Quantita |
|---|---|---|---:|
| CAPSULABIALETTI | MP | 0090 | 1.000 |
| CARTAALLUMINIOMICROF | MP | JOB 20295 | 0.380 |
| CARTAFILTRO1 | MP | 47848787 | 0.110 |
| TOPBIALETTI | MP | 22-1335-002 | 0.220 |

Il POST reale e stato eseguito una sola volta.

## Risposta API

```json
{
  "ok": true,
  "messaggio": "Dichiarazione produzione confermata. Carico 0000170014/815, scarico 0000170015/1565.",
  "serialCarico": "0000170014",
  "numeroCarico": 815,
  "serialScarico": "0000170015",
  "numeroScarico": 1565
}
```

## Documenti creati

### MOROSDOC_MAST

| Seriale | Tipo | Numero | Alfanumerico | Num. esterno | Alf. esterno | Causale mag. |
|---|---|---:|---|---:|---|---|
| 0000170014 | DPPRF | 815 | DP | 0 | | PRCAR |
| 0000170015 | SCOMP | 1565 | | 815 | DP | 205 |

Il collegamento scarico -> carico risulta corretto:

- `MVNUMEST = 815`
- `MVALFEST = 'DP        '`

### MOROSDOC_DETT

| Seriale | Riga | Articolo | Mag. | Lotto mag. | Lotto | Qta | MVFLCASC | MVFLLOTT | MVCAUMAG | MV_SEGNO |
|---|---:|---|---|---|---|---:|---|---|---|---|
| 0000170014 | 1 | CAPSULABIALETTIDIST | 01 | | | 1.000 | + | | PRCAR | A |
| 0000170015 | 1 | CAPSULABIALETTI | MP | MP | 0090 | 1.000 | - | - | 205 | D |
| 0000170015 | 2 | CARTAALLUMINIOMICROF | MP | MP | JOB 20295 | 0.380 | - | - | 205 | D |
| 0000170015 | 3 | CARTAFILTRO1 | MP | MP | 47848787 | 0.110 | - | - | 205 | D |
| 0000170015 | 4 | TOPBIALETTI | MP | MP | 22-1335-002 | 0.220 | - | - | 205 | D |

## Progressivi cpwarn dopo POST

| Progressivo | Autonum |
|---|---:|
| `prog\SEDOC\'MOROS'` | 170015 |
| `prog\PRDOC\'MOROS'\'2023'\'IV'\'DP        '` | 815 |
| `prog\PRDOC\'MOROS'\'2023'\'IV'\'          '` | 1565 |

## SALDILOT prima/dopo

| Articolo | Mag. | Lotto | Prima SUQTAPER | Dopo SUQTAPER | Delta | SUQTRPER |
|---|---|---|---:|---:|---:|---:|
| CAPSULABIALETTI | MP | 0090 | 33400.000 | 33399.000 | -1.000 | 0.000 |
| CARTAALLUMINIOMICROF | MP | JOB 20295 | 127.072 | 126.692 | -0.380 | 0.000 |
| CARTAFILTRO1 | MP | 47848787 | 169.200 | 169.090 | -0.110 | 0.000 |
| TOPBIALETTI | MP | 22-1335-002 | 29.224 | 29.004 | -0.220 | 0.000 |

Esito: `SALDILOT` viene aggiornato correttamente dalla stored. Le righe di scarico con `MVFLCASC = '-'` decrementano `SUQTAPER` delle quantita indicate.

## Differenze rispetto al comportamento precedente

Prima dell'integrazione, FactoryFlow creava correttamente `DOC_MAST` e `DOC_DETT`, ma `SALDILOT` restava invariato perche l'aggiornamento dei saldi lotto in AdHoc e eseguito dal codice applicativo durante il salvataggio documento.

Dopo l'integrazione, la stored produce documenti e saldi lotto coerenti nella stessa transazione.
