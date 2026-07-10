# Collaudo Operativo MVP

Data collaudo: 30/06/2026

## Obiettivo

Verificare il ciclo operativo minimo di FactoryFlow:

- backend avviato;
- Flutter Web avviato;
- linea di produzione creata;
- articolo producibile associato alla linea;
- dichiarazione produzione confermata;
- documenti AdHoc creati;
- saldi lotto aggiornati;
- storico FactoryFlow popolato.

## Ambiente

- Backend: `http://localhost:5100`
- Flutter Web: `http://localhost:5200`
- Database AdHoc: `SVILUPPO01\SQL2017 / MOROSITO`
- Database FactoryFlow: `SVILUPPO01\SQL2017 / DB_FARMFLOW`
- Azienda AdHoc: `MOROS`

## Linea Creata

Linea creata per il collaudo:

- `IdLinea`: `1`
- `CodLinea`: `COLL-MVP-01`
- `NomeLinea`: `Linea Collaudo MVP`
- `DescrizioneFunzionale`: `Linea creata per collaudo operativo MVP`
- `Attiva`: `1`

## Articolo Associato

Articolo associato alla linea:

- `CodArticolo`: `TOST/1`
- Descrizione: `MISCELA CAFFE' TOSTATO N. 1`
- Quantita collaudo: `1`

Distinta caricata:

| Componente | UM | Quantita | Lotto | Magazzino |
| --- | --- | ---: | --- | --- |
| `CHERRYAA` | `GR` | `600.000` | `439/F` | `MP` |
| `COLOMBIASUPR` | `GR` | `83.333` | non lottizzato | `MP` |
| `NICARAGUA` | `GR` | `83.333` | non lottizzato | `MP` |
| `SANTOS MOGIANA` | `GR` | `233.333` | `429/B` | `MP` |

Lotto prodotto finito:

- Articolo: `TOST/1`
- Lotto: `FFMVP300626`
- Magazzino usato nel collaudo: `12`

## Esito Conferma Produzione

La conferma produzione e' riuscita.

Risposta API:

```json
{
  "ok": true,
  "messaggio": "Dichiarazione produzione confermata. Carico 0000170032/824, scarico 0000170033/1574.",
  "serialCarico": "0000170032",
  "numeroCarico": 824,
  "serialScarico": "0000170033",
  "numeroScarico": 1574
}
```

## Documenti AdHoc Creati

### Testate

| Seriale | Tipo documento | Alf. documento | Numero | Num. esterno | Alf. esterno | Causale magazzino |
| --- | --- | --- | ---: | ---: | --- | --- |
| `0000170032` | `DPPRF` | `DP` | `824` | `0` | `NULL` | `PRCAR` |
| `0000170033` | `SCOMP` | vuoto | `1574` | `824` | `DP` | `205` |

Il collegamento scarico -> carico e' corretto:

- `MVNUMEST = 824`
- `MVALFEST = DP`

### Righe

| Seriale | Articolo | Magazzino | Causale | Segno cascata | Segno | Lotto mag. | Lotto | Quantita | Lotto flag |
| --- | --- | --- | --- | --- | --- | --- | --- | ---: | --- |
| `0000170032` | `TOST/1` | `12` | `PRCAR` | `+` | `A` | `12` | `FFMVP300626` | `1.000` | `+` |
| `0000170033` | `CHERRYAA` | `MP` | `205` | `-` | `D` | `MP` | `439/F` | `600.000` | `-` |
| `0000170033` | `COLOMBIASUPR` | `MP` | `205` | `-` | `D` | `NULL` | `NULL` | `83.333` | vuoto |
| `0000170033` | `NICARAGUA` | `MP` | `205` | `-` | `D` | `NULL` | `NULL` | `83.333` | vuoto |
| `0000170033` | `SANTOS MOGIANA` | `MP` | `205` | `-` | `D` | `MP` | `429/B` | `233.333` | `-` |

La riga carico contiene il riferimento allo scarico:

- `MVRIFESC = 0000170033`

## Variazione SALDILOT

| Magazzino | Articolo | Lotto | Prima | Dopo | Variazione |
| --- | --- | --- | ---: | ---: | ---: |
| `12` | `TOST/1` | `FFMVP300626` | assente | `1.000` | `+1.000` |
| `MP` | `CHERRYAA` | `439/F` | `1145.000` | `545.000` | `-600.000` |
| `MP` | `SANTOS MOGIANA` | `429/B` | `291.000` | `57.667` | `-233.333` |

Esito SALDILOT: positivo.

Il lotto prodotto finito e' stato creato con quantita positiva. I lotti componenti selezionati sono stati scaricati correttamente.

## Righe DB_FARMFLOW Create

Conteggi finali:

| Tabella | Righe |
| --- | ---: |
| `FF_LINEE_LAVORAZIONE` | `1` |
| `FF_LINEE_ARTICOLI` | `1` |
| `FF_DICHIARAZIONI_PRODUZIONE` | `1` |
| `FF_DICHIARAZIONI_COMPONENTI` | `4` |
| `FF_AUDIT_EVENTI` | `1` |

Dichiarazione FactoryFlow:

- `IdDichiarazione`: `1`
- `IdLinea`: `1`
- `CodAziAdhoc`: `MOROS`
- `DataProduzione`: `2026-06-30`
- `CodArticoloPF`: `TOST/1`
- `LottoPF`: `FFMVP300626`
- `MagazzinoPF`: `12`
- `QuantitaProdotta`: `1.000`
- `SerialeCaricoAdhoc`: `0000170032`
- `NumeroCaricoAdhoc`: `824`
- `SerialeScaricoAdhoc`: `0000170033`
- `NumeroScaricoAdhoc`: `1574`
- `Stato`: `CONFERMATA`

Audit creato:

- `Entita`: `FF_DICHIARAZIONI_PRODUZIONE`
- `IdEntita`: `1`
- `TipoEvento`: `CONFERMA_PRODUZIONE`
- `Descrizione`: `Dichiarazione produzione confermata. Carico 0000170032/824, scarico 0000170033/1574.`

## Anomalie UI/API Rilevate

### 1. Magazzino PF configurato non valido per MOROS

La configurazione iniziale in `FF_CONFIG` contiene:

- `MagazzinoPFDefault = PF`
- `MagazzinoComponentiDefault = MP`

Durante il primo tentativo di conferma, AdHoc ha rifiutato il documento per vincolo FK verso `MOROSMAGAZZIN`, perche' il magazzino `PF` non esiste in MOROS.

Il tentativo e' stato completamente rollbackato:

- nessun documento AdHoc creato;
- nessuna riga `DB_FARMFLOW` creata;
- nessuna variazione SALDILOT.

Il collaudo e' stato poi completato usando il magazzino AdHoc valido `12`, corrispondente a `Magazzino caffe' tostato`.

Decisione consigliata:

- correggere la configurazione attiva `FF_CONFIG.MagazzinoPFDefault` da `PF` a un magazzino AdHoc realmente esistente per il contesto produttivo;
- valutare una validazione backend che impedisca di confermare se i magazzini configurati non esistono in `[AZIENDA]MAGAZZIN`.

### 2. Disallineamento default frontend/configurazione

Il frontend contiene ancora:

- `AppConfig.magazzinoDefault = 01`

Il database `DB_FARMFLOW` contiene:

- `MagazzinoPFDefault = PF`

Nel collaudo operativo e' stato necessario usare `12`.

Decisione consigliata:

- la UI dovrebbe leggere i magazzini default dall'endpoint configurazione, non mantenere un default statico nel frontend.

### 3. Automazione UI parziale

Flutter Web e' stato avviato correttamente e risulta raggiungibile su `http://localhost:5200`.

La sessione di collaudo automatizzata da terminale non disponeva di controllo diretto affidabile del browser gia' aperto. Le operazioni di creazione linea, associazione articolo e conferma sono quindi state eseguite tramite gli stessi endpoint chiamati dalla UI Flutter.

Questa anomalia non riguarda il dominio applicativo, ma la modalita' di esecuzione del collaudo automatico. Per i prossimi collaudi end-to-end e' consigliato introdurre test Flutter integration dedicati anche a:

- creazione linea;
- associazione articolo;
- selezione linea;
- selezione articolo filtrato;
- scelta lotti;
- conferma produzione.

## Esito Finale

Il ciclo tecnico-operativo minimo e' validato:

- backend attivo;
- Flutter Web avviato;
- linea creata;
- articolo associato alla linea;
- distinta caricabile;
- lotti componenti disponibili;
- dichiarazione confermata;
- documenti AdHoc creati;
- SALDILOT aggiornato;
- storico FactoryFlow popolato;
- audit FactoryFlow popolato.

Il collaudo evidenzia una correzione necessaria di configurazione: `PF` non e' un magazzino valido in MOROS e non deve rimanere come default operativo.
