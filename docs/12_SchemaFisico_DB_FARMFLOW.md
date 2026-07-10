# FactoryFlow - Schema Fisico DB_FARMFLOW

## Scopo Del Documento

Questo documento trasforma il modello dati logico di `docs/11_ModelloDati_DB_FARMFLOW.md` in uno schema fisico pronto per SQL Server.

Non contiene script definitivi. Definisce tabelle, colonne, tipi dato, vincoli, indici consigliati e note di validazione.

## Regole Fisiche Generali

- Tutte le tabelle applicative usano prefisso `FF_`.
- Le chiavi primarie sono surrogate `INT IDENTITY`.
- Le foreign key fisiche sono ammesse solo tra tabelle `DB_FARMFLOW`.
- I riferimenti ad AdHoc sono codici esterni, non foreign key fisiche.
- Non devono essere duplicati articoli, distinte, lotti, documenti, giacenze, causali, tipi documento, clienti, fornitori o costi standard AdHoc.
- Ogni tabella gestionale FactoryFlow deve avere audit minimo: `DataCreazione`, `DataModifica`, `UtenteCreazione`, `UtenteModifica`.
- I campi descrittivi presenti in `DB_FARMFLOW` sono descrizioni operative FactoryFlow, non descrizioni ufficiali AdHoc.
- I campi monetari e quantitativi usano `DECIMAL(18, 6)` salvo diversa indicazione.
- Le date evento usano `DATETIME2(0)`.
- I flag usano `BIT`.

## Standard Audit

Colonne audit minime da applicare a tutte le tabelle principali:

| Colonna | Tipo SQL Server | Null | Default | Note |
|---|---:|---:|---|---|
| `DataCreazione` | `DATETIME2(0)` | No | data/ora corrente | valorizzata alla creazione |
| `DataModifica` | `DATETIME2(0)` | Si | nessuno | valorizzata all'ultimo aggiornamento |
| `UtenteCreazione` | `NVARCHAR(100)` | No | utente applicativo | operatore o servizio |
| `UtenteModifica` | `NVARCHAR(100)` | Si | nessuno | operatore o servizio |

## Area Configurazione

### FF_CONFIG

Scopo: configurazione minima di collegamento tra FactoryFlow e AdHoc.

| Colonna | Tipo SQL Server | Null | Default | Note |
|---|---:|---:|---|---|
| `IdConfig` | `INT IDENTITY` | No | identity | primary key |
| `CodAziAdhoc` | `NVARCHAR(10)` | No | nessuno | codice azienda AdHoc |
| `PrefissoAzienda` | `NVARCHAR(20)` | No | nessuno | prefisso tabelle AdHoc |
| `CausaleCarico` | `NVARCHAR(20)` | No | nessuno | causale documento carico da risolvere su AdHoc |
| `CausaleScarico` | `NVARCHAR(20)` | No | nessuno | causale documento scarico da risolvere su AdHoc |
| `MagazzinoPFDefault` | `NVARCHAR(10)` | No | nessuno | magazzino prodotto finito proposto |
| `MagazzinoComponentiDefault` | `NVARCHAR(10)` | No | nessuno | magazzino componenti proposto |
| `Attiva` | `BIT` | No | `1` | una sola configurazione attiva per azienda |
| audit minimo | standard | | | vedere sezione audit |

Primary key: `IdConfig`.

Foreign key: nessuna.

Unique constraint:

- `CodAziAdhoc`, `PrefissoAzienda`, `Attiva` da valutare filtrata su `Attiva = 1`.

Indici consigliati:

- indice su `CodAziAdhoc`, `Attiva`;
- indice su `PrefissoAzienda`.

Note di validazione:

- `PrefissoAzienda` deve essere valorizzato e trimmato.
- `CausaleCarico` e `CausaleScarico` non devono contenere tipo documento, alfanumerico o causale magazzino derivata.
- tipo documento, alfanumerico, causale magazzino e segno restano letti da AdHoc.

## Area Risorse Operative

### FF_LINEE

Scopo: linee operative FactoryFlow.

| Colonna | Tipo SQL Server | Null | Default | Note |
|---|---:|---:|---|---|
| `IdLinea` | `INT IDENTITY` | No | identity | primary key |
| `CodLinea` | `NVARCHAR(30)` | No | nessuno | codice operativo FactoryFlow |
| `DescrizioneOperativa` | `NVARCHAR(200)` | No | nessuno | descrizione interna FactoryFlow |
| `CodCentroAdHoc` | `NVARCHAR(30)` | Si | nessuno | riferimento esterno AdHoc eventuale |
| `Attiva` | `BIT` | No | `1` | linea utilizzabile |
| `Ordinamento` | `INT` | No | `0` | ordinamento UI |
| `NoteOperative` | `NVARCHAR(500)` | Si | nessuno | note interne |
| audit minimo | standard | | | vedere sezione audit |

Primary key: `IdLinea`.

Foreign key: nessuna.

Unique constraint:

- `CodLinea`.

Indici consigliati:

- indice su `Attiva`, `Ordinamento`;
- indice su `CodCentroAdHoc`.

Note di validazione:

- `CodCentroAdHoc` e solo riferimento esterno, non copia del centro o ciclo AdHoc.
- Non salvare tempi ciclo, descrizioni ufficiali o dati tecnici AdHoc.

### FF_MACCHINE

Scopo: macchine operative FactoryFlow.

| Colonna | Tipo SQL Server | Null | Default | Note |
|---|---:|---:|---|---|
| `IdMacchina` | `INT IDENTITY` | No | identity | primary key |
| `IdLinea` | `INT` | Si | nessuno | linea operativa associata |
| `CodMacchina` | `NVARCHAR(30)` | No | nessuno | codice operativo FactoryFlow |
| `DescrizioneOperativa` | `NVARCHAR(200)` | No | nessuno | descrizione interna |
| `CodRisorsaAdHoc` | `NVARCHAR(30)` | Si | nessuno | riferimento esterno eventuale |
| `StatoOperativo` | `NVARCHAR(30)` | No | `ATTIVA` | stato applicativo |
| `Attiva` | `BIT` | No | `1` | macchina utilizzabile |
| `NoteOperative` | `NVARCHAR(500)` | Si | nessuno | note interne |
| audit minimo | standard | | | vedere sezione audit |

Primary key: `IdMacchina`.

Foreign key:

- `IdLinea` verso `FF_LINEE.IdLinea`, nullable.

Unique constraint:

- `CodMacchina`.

Indici consigliati:

- indice su `IdLinea`, `Attiva`;
- indice su `CodRisorsaAdHoc`;
- indice su `StatoOperativo`.

Note di validazione:

- `StatoOperativo` e uno stato FactoryFlow, non uno stato AdHoc.
- Non duplicare cespiti, centri ufficiali o dati contabili della macchina.

### FF_LINEE_ARTICOLI

Scopo: associazione operativa tra linee FactoryFlow e articoli AdHoc.

| Colonna | Tipo SQL Server | Null | Default | Note |
|---|---:|---:|---|---|
| `IdLineaArticolo` | `INT IDENTITY` | No | identity | primary key |
| `IdLinea` | `INT` | No | nessuno | linea FactoryFlow |
| `CodArticoloAdHoc` | `NVARCHAR(50)` | No | nessuno | codice articolo esterno |
| `PrioritaOperativa` | `INT` | No | `0` | priorita interna |
| `Abilitato` | `BIT` | No | `1` | associazione attiva |
| `NoteOperative` | `NVARCHAR(500)` | Si | nessuno | note interne |
| audit minimo | standard | | | vedere sezione audit |

Primary key: `IdLineaArticolo`.

Foreign key:

- `IdLinea` verso `FF_LINEE.IdLinea`.

Unique constraint:

- `IdLinea`, `CodArticoloAdHoc`.

Indici consigliati:

- indice su `CodArticoloAdHoc`;
- indice su `IdLinea`, `Abilitato`, `PrioritaOperativa`.

Note di validazione:

- `CodArticoloAdHoc` e riferimento esterno.
- Non salvare descrizione articolo, UM, distinta, ciclo, giacenze o lotti.

## Area Registrazioni FactoryFlow

### FF_PRODUZIONI

Scopo: storico applicativo delle dichiarazioni produzione eseguite da FactoryFlow.

| Colonna | Tipo SQL Server | Null | Default | Note |
|---|---:|---:|---|---|
| `IdProduzione` | `INT IDENTITY` | No | identity | primary key |
| `IdConfig` | `INT` | No | nessuno | configurazione usata |
| `DataProduzione` | `DATE` | No | nessuno | data dichiarata |
| `OraInizioProduzione` | `DATETIME2(0)` | Si | nessuno | inizio effettivo o previsto dell evento produttivo FactoryFlow |
| `OraFineProduzione` | `DATETIME2(0)` | Si | nessuno | fine effettiva o prevista dell evento produttivo FactoryFlow |
| `CodArticoloAdHoc` | `NVARCHAR(50)` | No | nessuno | articolo prodotto esterno |
| `QuantitaProdotta` | `DECIMAL(18, 6)` | No | nessuno | quantita dichiarata |
| `LottoProdottoInserito` | `NVARCHAR(50)` | Si | nessuno | lotto digitato/scelto |
| `MagazzinoProdotto` | `NVARCHAR(10)` | No | nessuno | codice magazzino AdHoc |
| `SerialeCaricoAdHoc` | `NVARCHAR(20)` | Si | nessuno | riferimento documento AdHoc |
| `NumeroCaricoAdHoc` | `INT` | Si | nessuno | numero documento AdHoc |
| `SerialeScaricoAdHoc` | `NVARCHAR(20)` | Si | nessuno | riferimento documento AdHoc |
| `NumeroScaricoAdHoc` | `INT` | Si | nessuno | numero documento AdHoc |
| `StatoFactoryFlow` | `NVARCHAR(30)` | No | `INSERITA` | stato applicativo |
| `EsitoMotore` | `NVARCHAR(30)` | Si | nessuno | esito conferma |
| `MessaggioErrore` | `NVARCHAR(MAX)` | Si | nessuno | errore applicativo |
| `UtenteOperativo` | `NVARCHAR(100)` | Si | nessuno | operatore reparto |
| `Dispositivo` | `NVARCHAR(100)` | Si | nessuno | device/sessione |
| `DataConferma` | `DATETIME2(0)` | Si | nessuno | istante conferma |
| audit minimo | standard | | | vedere sezione audit |

Primary key: `IdProduzione`.

Foreign key:

- `IdConfig` verso `FF_CONFIG.IdConfig`.

Unique constraint:

- da valutare su `SerialeCaricoAdHoc`;
- da valutare su `SerialeScaricoAdHoc`.

Indici consigliati:

- indice su `DataProduzione`, `CodArticoloAdHoc`;
- indice su `DataConferma`;
- indice su `SerialeCaricoAdHoc`;
- indice su `SerialeScaricoAdHoc`;
- indice su `StatoFactoryFlow`.

Note di validazione:

- `QuantitaProdotta` deve essere maggiore di zero.
- `OraFineProduzione` deve essere successiva a `OraInizioProduzione` quando entrambe sono valorizzate.
- Gli orari produzione sono dati operativi FactoryFlow: non esistono in AdHoc e non devono essere scritti nei documenti ERP.
- I seriali AdHoc sono riferimenti esterni, non foreign key.
- Non salvare testata completa `DOC_MAST`.
- Non salvare tipo documento, alfanumerico, causale o segno documento.

### FF_PRODUZIONE_COMPONENTI

Scopo: snapshot operativo dei componenti inviati da FactoryFlow.

| Colonna | Tipo SQL Server | Null | Default | Note |
|---|---:|---:|---|---|
| `IdProduzioneComponente` | `INT IDENTITY` | No | identity | primary key |
| `IdProduzione` | `INT` | No | nessuno | produzione FactoryFlow |
| `CodComponenteAdHoc` | `NVARCHAR(50)` | No | nessuno | componente esterno |
| `QuantitaDistintaLetta` | `DECIMAL(18, 6)` | Si | nessuno | snapshot operativo |
| `QuantitaProposta` | `DECIMAL(18, 6)` | Si | nessuno | snapshot operativo |
| `QuantitaEffettiva` | `DECIMAL(18, 6)` | No | nessuno | quantita inviata |
| `LottoSelezionato` | `NVARCHAR(50)` | Si | nessuno | lotto scelto se lottizzato |
| `MagazzinoComponente` | `NVARCHAR(10)` | No | nessuno | codice magazzino AdHoc |
| `DisponibilitaVisualizzata` | `DECIMAL(18, 6)` | Si | nessuno | snapshot non ufficiale |
| `ScadenzaVisualizzata` | `DATE` | Si | nessuno | snapshot non master |
| `GestioneLottiVisualizzata` | `BIT` | No | `0` | snapshot |
| `RigaDocumentoAdHoc` | `INT` | Si | nessuno | riferimento riga esterna se nota |
| audit minimo | standard | | | vedere sezione audit |

Primary key: `IdProduzioneComponente`.

Foreign key:

- `IdProduzione` verso `FF_PRODUZIONI.IdProduzione`.

Unique constraint:

- nessuna obbligatoria; valutare `IdProduzione`, `CodComponenteAdHoc`, `LottoSelezionato`, `MagazzinoComponente` solo se il business vieta righe duplicate.

Indici consigliati:

- indice su `IdProduzione`;
- indice su `CodComponenteAdHoc`;
- indice su `LottoSelezionato`.

Note di validazione:

- `QuantitaEffettiva` deve essere maggiore o uguale a zero.
- Se `GestioneLottiVisualizzata = 1`, il lotto dovrebbe essere valorizzato salvo scelta operativa esplicita.
- Disponibilita e scadenza sono snapshot di cio che e stato mostrato, non saldi ufficiali.
- Non salvare descrizione componente, UM o riga completa `DOC_DETT`.

## Area Costi Industriali

### FF_COSTI_PRODUZIONE

Scopo: fotografia dei costi industriali calcolati per una produzione.

| Colonna | Tipo SQL Server | Null | Default | Note |
|---|---:|---:|---|---|
| `IdCostoProduzione` | `INT IDENTITY` | No | identity | primary key |
| `IdProduzione` | `INT` | No | nessuno | produzione collegata |
| `TipoCalcolo` | `NVARCHAR(30)` | No | `CONSUNTIVO` | stima, consuntivo, ricalcolo |
| `VersioneParametri` | `NVARCHAR(50)` | Si | nessuno | versione logica |
| `CostoMaterialiCalcolato` | `DECIMAL(18, 6)` | No | `0` | valore calcolato |
| `CostoEnergiaCalcolato` | `DECIMAL(18, 6)` | No | `0` | valore calcolato |
| `CostoManodoperaCalcolato` | `DECIMAL(18, 6)` | No | `0` | valore calcolato |
| `CostoSetupCalcolato` | `DECIMAL(18, 6)` | No | `0` | valore calcolato |
| `CostoTotaleCalcolato` | `DECIMAL(18, 6)` | No | `0` | somma calcolata |
| `FonteCalcolo` | `NVARCHAR(100)` | Si | nessuno | fonte/regola applicativa |
| `DataCalcolo` | `DATETIME2(0)` | No | data/ora corrente | istante calcolo |
| `NoteCalcolo` | `NVARCHAR(1000)` | Si | nessuno | note |
| audit minimo | standard | | | vedere sezione audit |

Primary key: `IdCostoProduzione`.

Foreign key:

- `IdProduzione` verso `FF_PRODUZIONI.IdProduzione`.

Unique constraint:

- nessuna obbligatoria; valutare `IdProduzione`, `TipoCalcolo`, `VersioneParametri` se si vuole impedire doppio calcolo della stessa versione.

Indici consigliati:

- indice su `IdProduzione`;
- indice su `DataCalcolo`;
- indice su `TipoCalcolo`.

Note di validazione:

- I costi sono analitici FactoryFlow, non contabilita ufficiale.
- Non copiare costi standard AdHoc come master; eventualmente salvarli solo come fonte/versione del calcolo.

### FF_COSTI_PRODUZIONE_DETTAGLIO

Scopo: dettaglio delle componenti di costo.

| Colonna | Tipo SQL Server | Null | Default | Note |
|---|---:|---:|---|---|
| `IdCostoDettaglio` | `INT IDENTITY` | No | identity | primary key |
| `IdCostoProduzione` | `INT` | No | nessuno | costo testata |
| `CategoriaCosto` | `NVARCHAR(30)` | No | nessuno | materiali, energia, manodopera, setup |
| `DescrizioneOperativa` | `NVARCHAR(200)` | No | nessuno | descrizione del calcolo |
| `QuantitaBase` | `DECIMAL(18, 6)` | Si | nessuno | base calcolo |
| `CostoUnitarioApplicato` | `DECIMAL(18, 6)` | Si | nessuno | valore applicato |
| `CostoTotale` | `DECIMAL(18, 6)` | No | `0` | totale riga |
| `FonteDato` | `NVARCHAR(100)` | Si | nessuno | origine |
| `RiferimentoEsterno` | `NVARCHAR(100)` | Si | nessuno | codice esterno eventuale |
| `Note` | `NVARCHAR(1000)` | Si | nessuno | note |
| audit minimo | standard | | | vedere sezione audit |

Primary key: `IdCostoDettaglio`.

Foreign key:

- `IdCostoProduzione` verso `FF_COSTI_PRODUZIONE.IdCostoProduzione`.

Unique constraint: nessuna obbligatoria.

Indici consigliati:

- indice su `IdCostoProduzione`;
- indice su `CategoriaCosto`.

Note di validazione:

- `CategoriaCosto` deve appartenere a un set applicativo controllato.
- Non duplicare movimenti contabili, fornitori o anagrafiche ufficiali.

### FF_RILEVAZIONI_OPERATIVE

Scopo: rilevazioni operative future per tempi, energia, setup e fermi.

| Colonna | Tipo SQL Server | Null | Default | Note |
|---|---:|---:|---|---|
| `IdRilevazione` | `INT IDENTITY` | No | identity | primary key |
| `IdProduzione` | `INT` | Si | nessuno | produzione collegata |
| `IdLinea` | `INT` | Si | nessuno | linea collegata |
| `IdMacchina` | `INT` | Si | nessuno | macchina collegata |
| `TipoRilevazione` | `NVARCHAR(30)` | No | nessuno | tempo, energia, setup, fermo |
| `ValoreRilevato` | `DECIMAL(18, 6)` | No | nessuno | valore rilevato |
| `UnitaOperativa` | `NVARCHAR(20)` | No | nessuno | minuti, kWh, ore |
| `DataInizio` | `DATETIME2(0)` | Si | nessuno | inizio evento |
| `DataFine` | `DATETIME2(0)` | Si | nessuno | fine evento |
| `FonteRilevazione` | `NVARCHAR(100)` | Si | nessuno | manuale, sensore, import |
| `UtenteOperativo` | `NVARCHAR(100)` | Si | nessuno | operatore |
| `Note` | `NVARCHAR(1000)` | Si | nessuno | note |
| audit minimo | standard | | | vedere sezione audit |

Primary key: `IdRilevazione`.

Foreign key:

- `IdProduzione` verso `FF_PRODUZIONI.IdProduzione`, nullable;
- `IdLinea` verso `FF_LINEE.IdLinea`, nullable;
- `IdMacchina` verso `FF_MACCHINE.IdMacchina`, nullable.

Unique constraint: nessuna obbligatoria.

Indici consigliati:

- indice su `IdProduzione`;
- indice su `IdLinea`, `DataInizio`;
- indice su `IdMacchina`, `DataInizio`;
- indice su `TipoRilevazione`, `DataInizio`.

Note di validazione:

- Almeno uno tra produzione, linea o macchina dovrebbe essere valorizzato.
- `DataFine` non deve essere precedente a `DataInizio`.
- Non duplicare presenze ufficiali, paghe o contabilita energia.

## Area Calendario E Capacita

### FF_CALENDARI_PRODUZIONE

Scopo: calendari operativi FactoryFlow.

| Colonna | Tipo SQL Server | Null | Default | Note |
|---|---:|---:|---|---|
| `IdCalendario` | `INT IDENTITY` | No | identity | primary key |
| `CodCalendario` | `NVARCHAR(30)` | No | nessuno | codice operativo |
| `DescrizioneOperativa` | `NVARCHAR(200)` | No | nessuno | descrizione interna |
| `Ambito` | `NVARCHAR(30)` | No | `GENERALE` | generale, linea, macchina |
| `Attivo` | `BIT` | No | `1` | calendario utilizzabile |
| audit minimo | standard | | | vedere sezione audit |

Primary key: `IdCalendario`.

Foreign key: nessuna.

Unique constraint:

- `CodCalendario`.

Indici consigliati:

- indice su `Attivo`, `Ambito`.

Note di validazione:

- Usare solo se AdHoc non fornisce calendario operativo sufficiente.
- Non duplicare calendari ufficiali se disponibili in AdHoc.

### FF_CALENDARIO_GIORNI

Scopo: giorni, turni ed eccezioni operative.

| Colonna | Tipo SQL Server | Null | Default | Note |
|---|---:|---:|---|---|
| `IdCalendarioGiorno` | `INT IDENTITY` | No | identity | primary key |
| `IdCalendario` | `INT` | No | nessuno | calendario |
| `DataGiorno` | `DATE` | No | nessuno | giorno operativo |
| `TipoGiorno` | `NVARCHAR(30)` | No | nessuno | lavorativo, chiuso, eccezione |
| `OraInizio` | `TIME(0)` | Si | nessuno | inizio fascia |
| `OraFine` | `TIME(0)` | Si | nessuno | fine fascia |
| `CapacitaTeorica` | `DECIMAL(18, 6)` | Si | nessuno | capacita del giorno/fascia |
| `NoteOperative` | `NVARCHAR(500)` | Si | nessuno | note |
| audit minimo | standard | | | vedere sezione audit |

Primary key: `IdCalendarioGiorno`.

Foreign key:

- `IdCalendario` verso `FF_CALENDARI_PRODUZIONE.IdCalendario`.

Unique constraint:

- `IdCalendario`, `DataGiorno`, `OraInizio`.

Indici consigliati:

- indice su `IdCalendario`, `DataGiorno`;
- indice su `TipoGiorno`.

Note di validazione:

- `OraFine` deve essere maggiore di `OraInizio` quando entrambe valorizzate.
- `CapacitaTeorica` non deve essere negativa.

### FF_CAPACITA_PRODUTTIVA

Scopo: capacita effettive o override operativi.

| Colonna | Tipo SQL Server | Null | Default | Note |
|---|---:|---:|---|---|
| `IdCapacita` | `INT IDENTITY` | No | identity | primary key |
| `IdLinea` | `INT` | Si | nessuno | linea |
| `IdMacchina` | `INT` | Si | nessuno | macchina |
| `CodArticoloAdHoc` | `NVARCHAR(50)` | Si | nessuno | articolo esterno eventuale |
| `DataInizioValidita` | `DATE` | No | nessuno | inizio validita |
| `DataFineValidita` | `DATE` | Si | nessuno | fine validita |
| `CapacitaOraria` | `DECIMAL(18, 6)` | No | nessuno | capacita operativa |
| `UnitaCapacita` | `NVARCHAR(20)` | No | nessuno | pezzi/ora, kg/ora |
| `FattoreEfficienza` | `DECIMAL(9, 6)` | No | `1` | coefficiente |
| `OrigineDato` | `NVARCHAR(50)` | No | `MANUALE` | manuale, storico, import |
| `NoteOperative` | `NVARCHAR(500)` | Si | nessuno | note |
| audit minimo | standard | | | vedere sezione audit |

Primary key: `IdCapacita`.

Foreign key:

- `IdLinea` verso `FF_LINEE.IdLinea`, nullable;
- `IdMacchina` verso `FF_MACCHINE.IdMacchina`, nullable.

Unique constraint:

- da valutare su `IdLinea`, `IdMacchina`, `CodArticoloAdHoc`, `DataInizioValidita`.

Indici consigliati:

- indice su `IdLinea`, `DataInizioValidita`;
- indice su `IdMacchina`, `DataInizioValidita`;
- indice su `CodArticoloAdHoc`.

Note di validazione:

- Almeno uno tra linea, macchina o articolo dovrebbe essere valorizzato.
- `CapacitaOraria` deve essere maggiore di zero.
- Non duplicare tempi ciclo ufficiali AdHoc.

## Area Pianificazione

### FF_PIANI_PRODUZIONE

Scopo: testata di un piano operativo FactoryFlow.

| Colonna | Tipo SQL Server | Null | Default | Note |
|---|---:|---:|---|---|
| `IdPiano` | `INT IDENTITY` | No | identity | primary key |
| `CodPiano` | `NVARCHAR(30)` | No | nessuno | codice piano |
| `DescrizionePiano` | `NVARCHAR(200)` | No | nessuno | descrizione operativa |
| `StatoPiano` | `NVARCHAR(30)` | No | `BOZZA` | stato applicativo |
| `DataInizioPiano` | `DATE` | No | nessuno | inizio piano |
| `DataFinePiano` | `DATE` | No | nessuno | fine piano |
| `OriginePiano` | `NVARCHAR(50)` | Si | nessuno | manuale, simulazione, import |
| audit minimo | standard | | | vedere sezione audit |

Primary key: `IdPiano`.

Foreign key: nessuna.

Unique constraint:

- `CodPiano`.

Indici consigliati:

- indice su `StatoPiano`;
- indice su `DataInizioPiano`, `DataFinePiano`.

Note di validazione:

- `DataFinePiano` non deve essere precedente a `DataInizioPiano`.
- Il piano non e un ordine ufficiale AdHoc.

### FF_PIANI_PRODUZIONE_RIGHE

Scopo: righe operative del piano.

| Colonna | Tipo SQL Server | Null | Default | Note |
|---|---:|---:|---|---|
| `IdPianoRiga` | `INT IDENTITY` | No | identity | primary key |
| `IdPiano` | `INT` | No | nessuno | piano |
| `CodArticoloAdHoc` | `NVARCHAR(50)` | No | nessuno | articolo esterno |
| `QuantitaPrevista` | `DECIMAL(18, 6)` | No | nessuno | quantita pianificata |
| `DataOraInizioPrevista` | `DATETIME2(0)` | Si | nessuno | inizio previsto |
| `DataOraFinePrevista` | `DATETIME2(0)` | Si | nessuno | fine previsto |
| `IdLinea` | `INT` | Si | nessuno | linea |
| `IdMacchina` | `INT` | Si | nessuno | macchina |
| `Priorita` | `INT` | No | `0` | priorita |
| `StatoRiga` | `NVARCHAR(30)` | No | `PIANIFICATA` | stato applicativo |
| `RiferimentoAdHoc` | `NVARCHAR(100)` | Si | nessuno | riferimento esterno |
| `NoteOperative` | `NVARCHAR(500)` | Si | nessuno | note |
| audit minimo | standard | | | vedere sezione audit |

Primary key: `IdPianoRiga`.

Foreign key:

- `IdPiano` verso `FF_PIANI_PRODUZIONE.IdPiano`;
- `IdLinea` verso `FF_LINEE.IdLinea`, nullable;
- `IdMacchina` verso `FF_MACCHINE.IdMacchina`, nullable.

Unique constraint: nessuna obbligatoria.

Indici consigliati:

- indice su `IdPiano`, `Priorita`;
- indice su `CodArticoloAdHoc`;
- indice su `IdLinea`, `DataOraInizioPrevista`;
- indice su `IdMacchina`, `DataOraInizioPrevista`;
- indice su `StatoRiga`.

Note di validazione:

- `QuantitaPrevista` deve essere maggiore di zero.
- Non salvare descrizione articolo, distinta o cliente.
- `RiferimentoAdHoc` resta riferimento testuale esterno.

## Area Simulazioni Future

### FF_SIMULAZIONI

Scopo: testata scenario simulativo.

| Colonna | Tipo SQL Server | Null | Default | Note |
|---|---:|---:|---|---|
| `IdSimulazione` | `INT IDENTITY` | No | identity | primary key |
| `CodSimulazione` | `NVARCHAR(30)` | No | nessuno | codice scenario |
| `TipoSimulazione` | `NVARCHAR(30)` | No | nessuno | MRP, capacita, costi |
| `DescrizioneSimulazione` | `NVARCHAR(200)` | Si | nessuno | descrizione |
| `StatoSimulazione` | `NVARCHAR(30)` | No | `BOZZA` | stato applicativo |
| `ParametriSintesi` | `NVARCHAR(MAX)` | Si | nessuno | parametri in forma testuale/strutturata |
| `DataEsecuzione` | `DATETIME2(0)` | Si | nessuno | esecuzione scenario |
| `UtenteEsecuzione` | `NVARCHAR(100)` | Si | nessuno | utente |
| `Note` | `NVARCHAR(1000)` | Si | nessuno | note |
| audit minimo | standard | | | vedere sezione audit |

Primary key: `IdSimulazione`.

Foreign key: nessuna.

Unique constraint:

- `CodSimulazione`.

Indici consigliati:

- indice su `TipoSimulazione`, `StatoSimulazione`;
- indice su `DataEsecuzione`.

Note di validazione:

- Le simulazioni non sono fabbisogni ufficiali AdHoc.
- `ParametriSintesi` deve contenere solo parametri dello scenario, non copie massive di anagrafiche.

### FF_SIMULAZIONE_RIGHE

Scopo: risultati e proposte dello scenario.

| Colonna | Tipo SQL Server | Null | Default | Note |
|---|---:|---:|---|---|
| `IdSimulazioneRiga` | `INT IDENTITY` | No | identity | primary key |
| `IdSimulazione` | `INT` | No | nessuno | scenario |
| `TipoRiga` | `NVARCHAR(30)` | No | nessuno | fabbisogno, criticita, proposta |
| `CodArticoloAdHoc` | `NVARCHAR(50)` | Si | nessuno | articolo esterno |
| `QuantitaCalcolata` | `DECIMAL(18, 6)` | Si | nessuno | risultato |
| `DataRichiesta` | `DATE` | Si | nessuno | data proposta/richiesta |
| `Priorita` | `INT` | No | `0` | priorita |
| `EsitoSimulazione` | `NVARCHAR(50)` | Si | nessuno | esito sintetico |
| `RiferimentoAdHoc` | `NVARCHAR(100)` | Si | nessuno | riferimento esterno |
| `Note` | `NVARCHAR(1000)` | Si | nessuno | note |
| audit minimo | standard | | | vedere sezione audit |

Primary key: `IdSimulazioneRiga`.

Foreign key:

- `IdSimulazione` verso `FF_SIMULAZIONI.IdSimulazione`.

Unique constraint: nessuna obbligatoria.

Indici consigliati:

- indice su `IdSimulazione`, `TipoRiga`;
- indice su `CodArticoloAdHoc`;
- indice su `DataRichiesta`.

Note di validazione:

- Non duplicare distinta, giacenze o ordini ufficiali.
- Le quantita sono risultati simulati, non movimenti ufficiali.

## Area Audit

### FF_AUDIT_MODIFICHE

Scopo: storico modifiche sui dati FactoryFlow.

| Colonna | Tipo SQL Server | Null | Default | Note |
|---|---:|---:|---|---|
| `IdAuditModifica` | `INT IDENTITY` | No | identity | primary key |
| `NomeEntita` | `NVARCHAR(100)` | No | nessuno | tabella/entita FactoryFlow |
| `IdEntita` | `INT` | No | nessuno | chiave entita |
| `TipoOperazione` | `NVARCHAR(30)` | No | nessuno | insert, update, stato |
| `ValoriPrecedentiSintesi` | `NVARCHAR(MAX)` | Si | nessuno | sintesi precedente |
| `ValoriNuoviSintesi` | `NVARCHAR(MAX)` | Si | nessuno | sintesi nuova |
| `UtenteOperativo` | `NVARCHAR(100)` | No | nessuno | utente |
| `Dispositivo` | `NVARCHAR(100)` | Si | nessuno | device/sessione |
| `DataOperazione` | `DATETIME2(0)` | No | data/ora corrente | istante |
| `MotivoOperazione` | `NVARCHAR(500)` | Si | nessuno | motivo |

Primary key: `IdAuditModifica`.

Foreign key: nessuna fisica, perche l'audit e polimorfico.

Unique constraint: nessuna.

Indici consigliati:

- indice su `NomeEntita`, `IdEntita`;
- indice su `DataOperazione`;
- indice su `UtenteOperativo`.

Default:

- `DataOperazione`: data/ora corrente.

Note di validazione:

- Audit solo per dati FactoryFlow.
- Non copiare contenuti completi AdHoc.

### FF_AUDIT_CANCELLAZIONI

Scopo: storico cancellazioni logiche o fisiche di dati FactoryFlow.

| Colonna | Tipo SQL Server | Null | Default | Note |
|---|---:|---:|---|---|
| `IdAuditCancellazione` | `INT IDENTITY` | No | identity | primary key |
| `NomeEntita` | `NVARCHAR(100)` | No | nessuno | tabella/entita FactoryFlow |
| `IdEntita` | `INT` | No | nessuno | chiave entita |
| `TipoCancellazione` | `NVARCHAR(30)` | No | nessuno | logica, fisica |
| `ValoriCancellatiSintesi` | `NVARCHAR(MAX)` | Si | nessuno | sintesi record |
| `UtenteOperativo` | `NVARCHAR(100)` | No | nessuno | utente |
| `Dispositivo` | `NVARCHAR(100)` | Si | nessuno | device/sessione |
| `DataCancellazione` | `DATETIME2(0)` | No | data/ora corrente | istante |
| `MotivoCancellazione` | `NVARCHAR(500)` | Si | nessuno | motivo |
| `Recuperabile` | `BIT` | No | `0` | recupero logico possibile |

Primary key: `IdAuditCancellazione`.

Foreign key: nessuna fisica, perche l'audit e polimorfico.

Unique constraint: nessuna.

Indici consigliati:

- indice su `NomeEntita`, `IdEntita`;
- indice su `DataCancellazione`;
- indice su `UtenteOperativo`;
- indice su `Recuperabile`.

Note di validazione:

- Audit solo per dati FactoryFlow.
- Non tracciare come copia gli annullamenti ufficiali AdHoc.

## Riepilogo Foreign Key Interne

Foreign key fisiche previste solo dentro `DB_FARMFLOW`:

- `FF_MACCHINE.IdLinea` verso `FF_LINEE.IdLinea`;
- `FF_LINEE_ARTICOLI.IdLinea` verso `FF_LINEE.IdLinea`;
- `FF_PRODUZIONI.IdConfig` verso `FF_CONFIG.IdConfig`;
- `FF_PRODUZIONE_COMPONENTI.IdProduzione` verso `FF_PRODUZIONI.IdProduzione`;
- `FF_COSTI_PRODUZIONE.IdProduzione` verso `FF_PRODUZIONI.IdProduzione`;
- `FF_COSTI_PRODUZIONE_DETTAGLIO.IdCostoProduzione` verso `FF_COSTI_PRODUZIONE.IdCostoProduzione`;
- `FF_RILEVAZIONI_OPERATIVE.IdProduzione` verso `FF_PRODUZIONI.IdProduzione`;
- `FF_RILEVAZIONI_OPERATIVE.IdLinea` verso `FF_LINEE.IdLinea`;
- `FF_RILEVAZIONI_OPERATIVE.IdMacchina` verso `FF_MACCHINE.IdMacchina`;
- `FF_CALENDARIO_GIORNI.IdCalendario` verso `FF_CALENDARI_PRODUZIONE.IdCalendario`;
- `FF_CAPACITA_PRODUTTIVA.IdLinea` verso `FF_LINEE.IdLinea`;
- `FF_CAPACITA_PRODUTTIVA.IdMacchina` verso `FF_MACCHINE.IdMacchina`;
- `FF_PIANI_PRODUZIONE_RIGHE.IdPiano` verso `FF_PIANI_PRODUZIONE.IdPiano`;
- `FF_PIANI_PRODUZIONE_RIGHE.IdLinea` verso `FF_LINEE.IdLinea`;
- `FF_PIANI_PRODUZIONE_RIGHE.IdMacchina` verso `FF_MACCHINE.IdMacchina`;
- `FF_SIMULAZIONE_RIGHE.IdSimulazione` verso `FF_SIMULAZIONI.IdSimulazione`.

Nessuna foreign key fisica deve puntare a tabelle AdHoc.

## Dati AdHoc Da Non Duplicare

Lo schema fisico non deve introdurre tabelle o colonne master per:

- articoli;
- descrizioni articolo;
- unita di misura;
- distinte;
- lotti;
- giacenze;
- documenti ufficiali;
- righe documento ufficiali;
- causali magazzino;
- tipi documento;
- alfanumerici documento;
- segni documento;
- clienti;
- fornitori;
- costi standard;
- cicli ufficiali.

Sono ammessi solo codici esterni, riferimenti e snapshot applicativi necessari a spiegare cosa FactoryFlow ha fatto o mostrato.

## Questioni Aperte Prima Dello Script SQL

1. Decidere se `FF_CONFIG` deve permettere piu configurazioni storiche per la stessa azienda o imporre una sola configurazione attiva tramite indice filtrato.
2. Stabilire l'elenco controllato degli stati applicativi: produzioni, linee, macchine, piani, simulazioni.
3. Decidere se gli audit `Valori...Sintesi` devono essere testo libero o formato strutturato.
4. Chiarire se `FF_PRODUZIONE_COMPONENTI` deve consentire righe duplicate per stesso componente/lotto/magazzino nella stessa produzione.
5. Definire se i seriali AdHoc in `FF_PRODUZIONI` devono essere univoci obbligatori quando valorizzati.
6. Decidere quando introdurre fisicamente le tabelle future: linee, macchine, pianificazione, simulazioni, costi e rilevazioni potrebbero restare fuori dal primo script.
7. Chiarire se `FF_MACCHINE` e obbligatoriamente figlia di una linea o se deve restare autonoma.
8. Definire la scala definitiva dei campi quantitativi e monetari se AdHoc usa precisioni diverse in installazioni future.
9. Stabilire una policy di cancellazione: cancellazione logica sui dati configurativi e fisica solo su dati temporanei.
10. Definire il formato dei riferimenti esterni AdHoc quando non basta un solo codice testuale.


## Schema Fisico MVP Giovedi

Lo script fisico MVP e disponibile in:

`backend/FactoryFlow.Sql/scripts/DB_FARMFLOW_Create.sql`

Lo script crea `DB_FARMFLOW` e solo le tabelle minime:

- `FF_CONFIG`;
- `FF_LINEE_LAVORAZIONE`;
- `FF_LINEE_ARTICOLI`;
- `FF_DICHIARAZIONI_PRODUZIONE`;
- `FF_DICHIARAZIONI_COMPONENTI`;
- `FF_AUDIT_EVENTI`.

Sono state escluse dal primo script le tabelle future di pianificazione, simulazione, costi industriali completi, rilevazioni energia/manodopera/setup e dashboard.

Nota architetturale: `FF_LINEE_ARTICOLI.CodArticolo` e riferimento esterno ad AdHoc, senza foreign key fisica. I dati descrittivi articolo restano in AdHoc.


### Indicatori Calcolati Su FF_DICHIARAZIONI_PRODUZIONE

La produttivita al minuto e calcolata a runtime come:

`QuantitaProdotta / durata in minuti`

Dove la durata deriva da `OraInizioProduzione` e `OraFineProduzione`.

Indicatori esposti dalle API ma non persistiti come colonne autonome:

| Indicatore | Formula | Persistito | Motivo |
| --- | --- | --- | --- |
| `ProduttivitaMinuto` | `QuantitaProdotta / minuti produzione` | No | dato derivato dalla dichiarazione |
| `MediaProduttivitaMinuto` | media delle produttivita confermate per articolo/linea | No | statistica ricalcolabile |
| `ScostamentoProduttivitaPercentuale` | differenza percentuale tra produttivita dichiarazione e media | No | indicatore di analisi UI |

Regola: gli indicatori di produttivita devono essere calcolati da FactoryFlow, non salvati in AdHoc e non duplicati come valori statici se ricavabili dai dati operativi di base.

## Estensione Fisica: Costi Produttivi E Team Operativo

La migrazione `backend/FactoryFlow.Sql/migrations/20260704_Add_Costi_TeamOperativo.sql` introduce lo schema fisico additivo per operatori, ruoli, team dichiarazione, macchine, setup, costi linea, costi articolo-linea, metriche produzione e costi produzione.

Regole fisiche confermate:

- chiavi surrogate identity;
- foreign key solo interne a DB_FARMFLOW;
- riferimenti AdHoc come codici esterni;
- audit minimo su tutte le nuove tabelle;
- indici su chiavi operative e periodi di validita;
- costo produzione salvato come snapshot e marcato incompleto se mancano dati.
