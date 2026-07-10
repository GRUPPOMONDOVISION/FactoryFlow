# FactoryFlow - Modello Dati Logico DB_FARMFLOW

## Scopo Del Documento

Questo documento traduce l'architettura definita in `docs/10_ArchitetturaFactoryFlow.md` in un modello dati logico per `DB_FARMFLOW`.

Non contiene istruzioni tecniche, script o dettagli implementativi. Descrive solo le entita logiche che FactoryFlow puo mantenere nel proprio database senza duplicare AdHoc Revolution.

## Principio Guida

FactoryFlow estende AdHoc, non lo sostituisce.

AdHoc resta il sistema ufficiale per articoli, distinte, documenti, magazzino, lotti, contabilita, costi standard, cicli, clienti e fornitori.

`DB_FARMFLOW` contiene solo:

- configurazioni proprie;
- linee operative;
- macchine operative se non gia gestite in AdHoc;
- associazioni operative;
- registrazioni FactoryFlow;
- storico modifiche e cancellazioni;
- fotografia dei costi calcolati al momento della produzione;
- pianificazione e simulazioni future.

Ogni tabella proposta deve contenere almeno una informazione che AdHoc non possiede gia come fonte ufficiale.

## Convenzioni Logiche

I campi che iniziano con `Cod...AdHoc`, `Seriale...AdHoc`, `Numero...AdHoc` o `Riferimento...AdHoc` sono riferimenti verso AdHoc, non copie dei dati AdHoc.

Le descrizioni ufficiali, le unita di misura, le giacenze, i lotti, le distinte e i documenti ufficiali devono essere letti da AdHoc al momento dell'utilizzo.

Gli stati FactoryFlow sono stati applicativi: non sostituiscono gli stati documentali o contabili di AdHoc.

## Area Configurazione

### FF_CONFIG

Nome tabella: `FF_CONFIG`

Scopo: contiene la configurazione applicativa minima per collegare FactoryFlow all'azienda AdHoc e stabilire le causali operative da usare nella dichiarazione produzione.

Campi principali:

- `IdConfig`;
- `CodAziAdhoc`;
- `PrefissoAzienda`;
- `CausaleCarico`;
- `CausaleScarico`;
- `MagazzinoPFDefault`;
- `MagazzinoComponentiDefault`;
- `Attiva`;
- `DataCreazione`;
- `DataModifica`.

Chiave primaria: `IdConfig`.

Relazioni:

- riferimento logico ad AdHoc tramite `CodAziAdhoc` e `PrefissoAzienda`;
- riferimento logico alle causali/documenti AdHoc tramite `CausaleCarico` e `CausaleScarico`.

Dati che NON devono essere duplicati da AdHoc:

- tipo documento effettivo;
- alfanumerico documento;
- causale magazzino;
- segno documento;
- descrizioni delle causali;
- regole documentali.

Motivo per cui deve stare in `DB_FARMFLOW`: e configurazione propria dell'applicazione. Stabilisce come FactoryFlow lavora con AdHoc, ma non e una regola gestionale ufficiale di AdHoc.

## Area Risorse Operative

### FF_LINEE

Nome tabella: `FF_LINEE`

Scopo: rappresenta le linee operative usate da FactoryFlow per filtrare, assegnare e pianificare produzioni.

Campi principali:

- `IdLinea`;
- `CodLinea`;
- `DescrizioneOperativa`;
- `CodCentroAdHoc`;
- `Attiva`;
- `Ordinamento`;
- `NoteOperative`;
- `DataCreazione`;
- `DataModifica`.

Chiave primaria: `IdLinea`.

Relazioni:

- puo essere collegata a `FF_MACCHINE`;
- puo essere collegata a `FF_LINEE_ARTICOLI`;
- puo essere usata da pianificazione, capacita e calendario;
- `CodCentroAdHoc` e solo un riferimento eventuale a una risorsa/ciclo/centro gestito da AdHoc.

Dati che NON devono essere duplicati da AdHoc:

- ciclo ufficiale;
- centro di lavoro ufficiale;
- dati tecnici del ciclo;
- descrizioni gestionali ufficiali se esistono in AdHoc.

Motivo per cui deve stare in `DB_FARMFLOW`: la linea e una risorsa operativa dell'interfaccia e della pianificazione FactoryFlow. Serve a una gestione moderna del reparto e non sostituisce eventuali cicli AdHoc.

### FF_MACCHINE

Nome tabella: `FF_MACCHINE`

Scopo: rappresenta le macchine operative usate da FactoryFlow per stati, capacita, pianificazione e raccolta dati industriali.

Campi principali:

- `IdMacchina`;
- `IdLinea`;
- `CodMacchina`;
- `DescrizioneOperativa`;
- `CodRisorsaAdHoc`;
- `StatoOperativo`;
- `Attiva`;
- `NoteOperative`;
- `DataCreazione`;
- `DataModifica`.

Chiave primaria: `IdMacchina`.

Relazioni:

- appartiene eventualmente a `FF_LINEE`;
- puo essere usata da calendari, capacita, rilevazioni e costi;
- `CodRisorsaAdHoc` e solo un riferimento esterno se la macchina esiste gia in AdHoc o in altra anagrafica ufficiale.

Dati che NON devono essere duplicati da AdHoc:

- cespiti ufficiali;
- centri o risorse ufficiali;
- dati contabili della macchina;
- dati tecnici ufficiali gia presenti in AdHoc.

Motivo per cui deve stare in `DB_FARMFLOW`: FactoryFlow puo avere bisogno di stati e dati operativi di reparto non gestiti con sufficiente dettaglio da AdHoc.

### FF_LINEE_ARTICOLI

Nome tabella: `FF_LINEE_ARTICOLI`

Scopo: definisce quali articoli AdHoc sono producibili o preferiti su una linea FactoryFlow.

Campi principali:

- `IdLineaArticolo`;
- `IdLinea`;
- `CodArticoloAdHoc`;
- `PrioritaOperativa`;
- `Abilitato`;
- `NoteOperative`;
- `DataCreazione`;
- `DataModifica`.

Chiave primaria: `IdLineaArticolo`.

Relazioni:

- collega `FF_LINEE` agli articoli AdHoc tramite codice articolo;
- puo essere usata dalla pianificazione e dai filtri dell'interfaccia.

Dati che NON devono essere duplicati da AdHoc:

- descrizione articolo;
- unita di misura;
- distinta;
- ciclo ufficiale;
- dati tecnici articolo;
- giacenze e lotti.

Motivo per cui deve stare in `DB_FARMFLOW`: l'associazione linea-articolo e una regola operativa utile a FactoryFlow per velocita, filtri e pianificazione. Non e una seconda anagrafica articolo.

## Area Registrazioni FactoryFlow

### FF_PRODUZIONI

Nome tabella: `FF_PRODUZIONI`

Scopo: conserva lo storico applicativo delle dichiarazioni produzione eseguite da FactoryFlow.

Campi principali:

- `IdProduzione`;
- `IdConfig`;
- `DataProduzione`;
- `CodArticoloAdHoc`;
- `QuantitaProdotta`;
- `LottoProdottoInserito`;
- `MagazzinoProdotto`;
- `SerialeCaricoAdHoc`;
- `NumeroCaricoAdHoc`;
- `SerialeScaricoAdHoc`;
- `NumeroScaricoAdHoc`;
- `StatoFactoryFlow`;
- `EsitoMotore`;
- `MessaggioErrore`;
- `UtenteOperativo`;
- `Dispositivo`;
- `DataConferma`;
- `DataCreazione`.

Chiave primaria: `IdProduzione`.

Relazioni:

- appartiene a `FF_CONFIG`;
- ha righe in `FF_PRODUZIONE_COMPONENTI`;
- puo avere fotografie costi in `FF_COSTI_PRODUZIONE`;
- contiene riferimenti ai documenti ufficiali AdHoc generati.

Dati che NON devono essere duplicati da AdHoc:

- testata completa del documento AdHoc;
- righe documento ufficiali;
- causali, alfanumerici e segni;
- giacenze;
- dati ufficiali del lotto;
- descrizione articolo e unita di misura ufficiale.

Motivo per cui deve stare in `DB_FARMFLOW`: serve come audit FactoryFlow. Registra chi ha confermato, quando, con quale input e quali documenti AdHoc sono stati prodotti, senza diventare un documento gestionale parallelo.

### FF_PRODUZIONE_COMPONENTI

Nome tabella: `FF_PRODUZIONE_COMPONENTI`

Scopo: conserva lo snapshot operativo dei componenti inviati da FactoryFlow al momento della dichiarazione.

Campi principali:

- `IdProduzioneComponente`;
- `IdProduzione`;
- `CodComponenteAdHoc`;
- `QuantitaDistintaLetta`;
- `QuantitaProposta`;
- `QuantitaEffettiva`;
- `LottoSelezionato`;
- `MagazzinoComponente`;
- `DisponibilitaVisualizzata`;
- `ScadenzaVisualizzata`;
- `GestioneLottiVisualizzata`;
- `RigaDocumentoAdHoc`;
- `DataCreazione`.

Chiave primaria: `IdProduzioneComponente`.

Relazioni:

- appartiene a `FF_PRODUZIONI`;
- puo riferirsi logicamente alla riga documento AdHoc generata, se nota.

Dati che NON devono essere duplicati da AdHoc:

- riga completa di `DOC_DETT`;
- descrizione ufficiale componente;
- unita di misura ufficiale;
- distinta ufficiale;
- saldo lotto ufficiale;
- scadenza lotto ufficiale come dato master.

Motivo per cui deve stare in `DB_FARMFLOW`: documenta cosa l'operatore ha visto e scelto in FactoryFlow. E uno snapshot di audit, non una distinta e non un movimento di magazzino.

## Area Costi Industriali

### FF_COSTI_PRODUZIONE

Nome tabella: `FF_COSTI_PRODUZIONE`

Scopo: conserva la fotografia dei costi industriali calcolati al momento della produzione o in un ricalcolo successivo.

Campi principali:

- `IdCostoProduzione`;
- `IdProduzione`;
- `TipoCalcolo`;
- `VersioneParametri`;
- `CostoMaterialiCalcolato`;
- `CostoEnergiaCalcolato`;
- `CostoManodoperaCalcolato`;
- `CostoSetupCalcolato`;
- `CostoTotaleCalcolato`;
- `FonteCalcolo`;
- `DataCalcolo`;
- `NoteCalcolo`.

Chiave primaria: `IdCostoProduzione`.

Relazioni:

- appartiene a `FF_PRODUZIONI`;
- puo avere dettagli in `FF_COSTI_PRODUZIONE_DETTAGLIO`;
- puo usare parametri applicativi e rilevazioni operative.

Dati che NON devono essere duplicati da AdHoc:

- costi standard ufficiali;
- contabilita ufficiale;
- valore ufficiale di magazzino;
- dati contabili di fatture o paghe.

Motivo per cui deve stare in `DB_FARMFLOW`: il costo industriale FactoryFlow e una fotografia analitica operativa. Non sostituisce il costo standard o la contabilita AdHoc.

### FF_COSTI_PRODUZIONE_DETTAGLIO

Nome tabella: `FF_COSTI_PRODUZIONE_DETTAGLIO`

Scopo: dettaglia le componenti del costo industriale calcolato.

Campi principali:

- `IdCostoDettaglio`;
- `IdCostoProduzione`;
- `CategoriaCosto`;
- `DescrizioneOperativa`;
- `QuantitaBase`;
- `CostoUnitarioApplicato`;
- `CostoTotale`;
- `FonteDato`;
- `RiferimentoEsterno`;
- `Note`.

Chiave primaria: `IdCostoDettaglio`.

Relazioni:

- appartiene a `FF_COSTI_PRODUZIONE`.

Dati che NON devono essere duplicati da AdHoc:

- costo standard ufficiale come master;
- movimenti contabili;
- anagrafiche ufficiali di fornitori, personale o articoli.

Motivo per cui deve stare in `DB_FARMFLOW`: rende trasparente il calcolo industriale FactoryFlow, mantenendo la fonte e la versione del dato usato.

### FF_RILEVAZIONI_OPERATIVE

Nome tabella: `FF_RILEVAZIONI_OPERATIVE`

Scopo: raccoglie dati operativi futuri utili al calcolo industriale, come tempi, energia, setup o fermate.

Campi principali:

- `IdRilevazione`;
- `IdProduzione`;
- `IdLinea`;
- `IdMacchina`;
- `TipoRilevazione`;
- `ValoreRilevato`;
- `UnitaOperativa`;
- `DataInizio`;
- `DataFine`;
- `FonteRilevazione`;
- `UtenteOperativo`;
- `Note`.

Chiave primaria: `IdRilevazione`.

Relazioni:

- puo appartenere a `FF_PRODUZIONI`;
- puo riferirsi a `FF_LINEE` e `FF_MACCHINE`;
- puo alimentare `FF_COSTI_PRODUZIONE`.

Dati che NON devono essere duplicati da AdHoc:

- presenze ufficiali;
- paghe;
- contabilita energia;
- costi standard ufficiali;
- cicli ufficiali.

Motivo per cui deve stare in `DB_FARMFLOW`: sono dati operativi di reparto che servono all'analisi FactoryFlow e non alla contabilita ufficiale.

## Area Calendario E Capacita

### FF_CALENDARI_PRODUZIONE

Nome tabella: `FF_CALENDARI_PRODUZIONE`

Scopo: definisce calendari operativi usati da FactoryFlow per pianificazione, turni, aperture e chiusure.

Campi principali:

- `IdCalendario`;
- `CodCalendario`;
- `DescrizioneOperativa`;
- `Ambito`;
- `Attivo`;
- `DataCreazione`;
- `DataModifica`.

Chiave primaria: `IdCalendario`.

Relazioni:

- puo essere collegata a linee e macchine;
- puo avere eccezioni in `FF_CALENDARIO_GIORNI`.

Dati che NON devono essere duplicati da AdHoc:

- calendari ufficiali se gia gestiti in AdHoc;
- dati contabili o amministrativi;
- cicli ufficiali.

Motivo per cui deve stare in `DB_FARMFLOW`: serve a una pianificazione operativa moderna se AdHoc non fornisce un calendario adatto al reparto.

### FF_CALENDARIO_GIORNI

Nome tabella: `FF_CALENDARIO_GIORNI`

Scopo: definisce giorni, turni, chiusure ed eccezioni operative.

Campi principali:

- `IdCalendarioGiorno`;
- `IdCalendario`;
- `DataGiorno`;
- `TipoGiorno`;
- `OraInizio`;
- `OraFine`;
- `CapacitaTeorica`;
- `NoteOperative`.

Chiave primaria: `IdCalendarioGiorno`.

Relazioni:

- appartiene a `FF_CALENDARI_PRODUZIONE`;
- puo essere usata da `FF_CAPACITA_PRODUTTIVA` e pianificazione.

Dati che NON devono essere duplicati da AdHoc:

- calendari ufficiali gia governati da AdHoc;
- festivita o regole amministrative se gia presenti come fonte ufficiale.

Motivo per cui deve stare in `DB_FARMFLOW`: gestisce eccezioni e disponibilita operative per la pianificazione FactoryFlow.

### FF_CAPACITA_PRODUTTIVA

Nome tabella: `FF_CAPACITA_PRODUTTIVA`

Scopo: conserva capacita operative effettive per linea, macchina, articolo o periodo.

Campi principali:

- `IdCapacita`;
- `IdLinea`;
- `IdMacchina`;
- `CodArticoloAdHoc`;
- `DataInizioValidita`;
- `DataFineValidita`;
- `CapacitaOraria`;
- `UnitaCapacita`;
- `FattoreEfficienza`;
- `OrigineDato`;
- `NoteOperative`.

Chiave primaria: `IdCapacita`.

Relazioni:

- puo riferirsi a `FF_LINEE`;
- puo riferirsi a `FF_MACCHINE`;
- puo riferirsi logicamente a un articolo AdHoc;
- puo essere usata dai piani di produzione.

Dati che NON devono essere duplicati da AdHoc:

- ciclo ufficiale;
- tempi ciclo ufficiali, se governati da AdHoc;
- descrizione articolo;
- dati tecnici master.

Motivo per cui deve stare in `DB_FARMFLOW`: la capacita effettiva e un dato operativo per schedulazione e simulazione. Puo rappresentare override, coefficienti o eccezioni non gestite da AdHoc.

## Area Pianificazione

### FF_PIANI_PRODUZIONE

Nome tabella: `FF_PIANI_PRODUZIONE`

Scopo: rappresenta un piano operativo FactoryFlow, separato dai documenti ufficiali AdHoc.

Campi principali:

- `IdPiano`;
- `CodPiano`;
- `DescrizionePiano`;
- `StatoPiano`;
- `DataInizioPiano`;
- `DataFinePiano`;
- `OriginePiano`;
- `UtenteCreazione`;
- `DataCreazione`;
- `DataModifica`.

Chiave primaria: `IdPiano`.

Relazioni:

- contiene righe in `FF_PIANI_PRODUZIONE_RIGHE`;
- puo derivare da simulazioni o da fabbisogni letti da AdHoc.

Dati che NON devono essere duplicati da AdHoc:

- ordini ufficiali;
- impegni ufficiali;
- documenti;
- anagrafiche articoli;
- giacenze.

Motivo per cui deve stare in `DB_FARMFLOW`: la pianificazione FactoryFlow e uno scenario operativo, non una seconda verita gestionale.

### FF_PIANI_PRODUZIONE_RIGHE

Nome tabella: `FF_PIANI_PRODUZIONE_RIGHE`

Scopo: dettaglia le produzioni previste nel piano operativo.

Campi principali:

- `IdPianoRiga`;
- `IdPiano`;
- `CodArticoloAdHoc`;
- `QuantitaPrevista`;
- `DataOraInizioPrevista`;
- `DataOraFinePrevista`;
- `IdLinea`;
- `IdMacchina`;
- `Priorita`;
- `StatoRiga`;
- `RiferimentoAdHoc`;
- `NoteOperative`.

Chiave primaria: `IdPianoRiga`.

Relazioni:

- appartiene a `FF_PIANI_PRODUZIONE`;
- puo riferirsi a `FF_LINEE` e `FF_MACCHINE`;
- puo riferirsi logicamente a ordini o fabbisogni AdHoc tramite `RiferimentoAdHoc`.

Dati che NON devono essere duplicati da AdHoc:

- ordine ufficiale;
- righe ordine ufficiali;
- descrizione articolo;
- distinta;
- giacenze;
- cliente o fornitore.

Motivo per cui deve stare in `DB_FARMFLOW`: serve a gestire sequenze, assegnazioni e stati operativi della pianificazione FactoryFlow.

## Area Simulazioni Future

### FF_SIMULAZIONI

Nome tabella: `FF_SIMULAZIONI`

Scopo: conserva scenari di simulazione, inclusi futuri scenari MRP o di capacita.

Campi principali:

- `IdSimulazione`;
- `CodSimulazione`;
- `TipoSimulazione`;
- `DescrizioneSimulazione`;
- `StatoSimulazione`;
- `ParametriSintesi`;
- `DataEsecuzione`;
- `UtenteEsecuzione`;
- `Note`.

Chiave primaria: `IdSimulazione`.

Relazioni:

- contiene risultati in `FF_SIMULAZIONE_RIGHE`;
- puo generare un piano operativo FactoryFlow.

Dati che NON devono essere duplicati da AdHoc:

- fabbisogni ufficiali come master;
- ordini ufficiali;
- giacenze ufficiali;
- distinte;
- articoli.

Motivo per cui deve stare in `DB_FARMFLOW`: le simulazioni sono scenari FactoryFlow. Possono usare dati AdHoc come fonti, ma il risultato simulato non e una verita gestionale ufficiale.

### FF_SIMULAZIONE_RIGHE

Nome tabella: `FF_SIMULAZIONE_RIGHE`

Scopo: dettaglia risultati, proposte, criticita o fabbisogni calcolati da una simulazione.

Campi principali:

- `IdSimulazioneRiga`;
- `IdSimulazione`;
- `TipoRiga`;
- `CodArticoloAdHoc`;
- `QuantitaCalcolata`;
- `DataRichiesta`;
- `Priorita`;
- `EsitoSimulazione`;
- `RiferimentoAdHoc`;
- `Note`.

Chiave primaria: `IdSimulazioneRiga`.

Relazioni:

- appartiene a `FF_SIMULAZIONI`;
- puo riferirsi logicamente ad articoli, fabbisogni o ordini AdHoc.

Dati che NON devono essere duplicati da AdHoc:

- anagrafica articolo;
- distinta;
- giacenza;
- ordini ufficiali;
- impegni ufficiali.

Motivo per cui deve stare in `DB_FARMFLOW`: conserva l'esito di una simulazione FactoryFlow e non modifica la fonte ufficiale AdHoc.

## Area Audit

### FF_AUDIT_MODIFICHE

Nome tabella: `FF_AUDIT_MODIFICHE`

Scopo: traccia le modifiche applicative sui dati propri di FactoryFlow.

Campi principali:

- `IdAuditModifica`;
- `NomeEntita`;
- `IdEntita`;
- `TipoOperazione`;
- `ValoriPrecedentiSintesi`;
- `ValoriNuoviSintesi`;
- `UtenteOperativo`;
- `Dispositivo`;
- `DataOperazione`;
- `MotivoOperazione`.

Chiave primaria: `IdAuditModifica`.

Relazioni:

- riferimento logico all'entita FactoryFlow modificata.

Dati che NON devono essere duplicati da AdHoc:

- storico tecnico AdHoc;
- modifiche interne AdHoc;
- dati completi delle anagrafiche AdHoc.

Motivo per cui deve stare in `DB_FARMFLOW`: e audit applicativo di FactoryFlow, necessario per tracciabilita e manutenzione nel tempo.

### FF_AUDIT_CANCELLAZIONI

Nome tabella: `FF_AUDIT_CANCELLAZIONI`

Scopo: traccia cancellazioni logiche o fisiche di dati FactoryFlow.

Campi principali:

- `IdAuditCancellazione`;
- `NomeEntita`;
- `IdEntita`;
- `TipoCancellazione`;
- `ValoriCancellatiSintesi`;
- `UtenteOperativo`;
- `Dispositivo`;
- `DataCancellazione`;
- `MotivoCancellazione`;
- `Recuperabile`.

Chiave primaria: `IdAuditCancellazione`.

Relazioni:

- riferimento logico all'entita FactoryFlow cancellata.

Dati che NON devono essere duplicati da AdHoc:

- cancellazioni o annullamenti documentali ufficiali AdHoc;
- storico gestionale AdHoc;
- dati completi di documenti, articoli, lotti o giacenze.

Motivo per cui deve stare in `DB_FARMFLOW`: consente tracciabilita e recupero logico delle operazioni applicative FactoryFlow.

## Tabelle Da Non Creare In DB_FARMFLOW

Per coerenza con l'architettura, non devono essere create tabelle applicative che replichino:

- articoli;
- descrizioni articolo;
- unita di misura;
- distinte base;
- righe distinta;
- lotti;
- saldi lotto;
- giacenze;
- documenti di magazzino ufficiali;
- righe documento ufficiali;
- causali magazzino;
- tipi documento;
- alfanumerici documento;
- segni documento;
- clienti;
- fornitori;
- costi standard ufficiali;
- cicli ufficiali.

Se questi dati servono, FactoryFlow li legge da AdHoc o conserva solo riferimenti e snapshot di audit strettamente necessari.

## Moduli E Priorita

### Prima Versione Necessaria

Tabelle logiche da considerare nella prima fase:

- `FF_CONFIG`;
- `FF_PRODUZIONI`;
- `FF_PRODUZIONE_COMPONENTI`;
- `FF_AUDIT_MODIFICHE`;
- `FF_AUDIT_CANCELLAZIONI`.

Queste coprono configurazione, registrazione FactoryFlow e tracciabilita.

### Moduli Successivi

Tabelle da introdurre solo quando il modulo relativo viene davvero progettato:

- `FF_LINEE`;
- `FF_MACCHINE`;
- `FF_LINEE_ARTICOLI`;
- `FF_CALENDARI_PRODUZIONE`;
- `FF_CALENDARIO_GIORNI`;
- `FF_CAPACITA_PRODUTTIVA`;
- `FF_PIANI_PRODUZIONE`;
- `FF_PIANI_PRODUZIONE_RIGHE`;
- `FF_SIMULAZIONI`;
- `FF_SIMULAZIONE_RIGHE`;
- `FF_RILEVAZIONI_OPERATIVE`;
- `FF_COSTI_PRODUZIONE`;
- `FF_COSTI_PRODUZIONE_DETTAGLIO`.

La loro introduzione deve essere guidata da funzionalita reali, non da previsione astratta.

## Regola Di Validazione Per Nuove Tabelle

Prima di aggiungere una nuova tabella a `DB_FARMFLOW`, deve essere possibile rispondere positivamente ad almeno una di queste domande:

1. Il dato e una configurazione propria di FactoryFlow?
2. Il dato e operativo e non esiste in AdHoc?
3. Il dato e un audit dell'uso di FactoryFlow?
4. Il dato e uno snapshot necessario per spiegare cosa e successo in FactoryFlow?
5. Il dato e una simulazione o pianificazione non ufficiale?
6. Il dato e un calcolo industriale non contabile?

Se la risposta e negativa, la tabella non appartiene a `DB_FARMFLOW`.

## Conclusione

Il modello dati logico proposto mantiene `DB_FARMFLOW` leggero e coerente.

Le tabelle fondamentali sono quelle di configurazione, registrazione e audit. Le aree linee, macchine, pianificazione, simulazioni e costi industriali sono previste, ma devono essere introdotte solo quando il prodotto le richiede davvero.

La scelta piu importante resta evitare duplicazioni di AdHoc. FactoryFlow deve conservare riferimenti, snapshot applicativi e dati propri, non copie della verita gestionale.

## Aggiornamento MVP Giovedi

Nel primo rilascio operativo il modello logico viene ridotto al nucleo minimo:

- configurazione cliente;
- linee operative;
- associazioni linea-articolo;
- dichiarazioni produzione;
- componenti dichiarati;
- audit eventi.

Le tabelle di pianificazione, simulazione, MRP, energia, manodopera, setup e dashboard restano previste dalla roadmap ma non vengono introdotte nell'MVP.

`FF_LINEE_ARTICOLI` non duplica l'anagrafica articolo. Conserva solo `CodArticolo` come riferimento esterno ad AdHoc e dati operativi propri della linea.

`FF_DICHIARAZIONI_PRODUZIONE` e `FF_DICHIARAZIONI_COMPONENTI` sono storico FactoryFlow: conservano cosa e stato confermato dall'applicazione dopo che AdHoc ha generato i documenti ufficiali.


### Nota Su Produttivita Al Minuto

La produttivita al minuto non viene salvata come dato autonomo in `DB_FARMFLOW`, perche e un indicatore derivabile da informazioni gia appartenenti alla dichiarazione FactoryFlow:

- `QuantitaProdotta`;
- `OraInizioProduzione`;
- `OraFineProduzione`.

FactoryFlow puo esporre la produttivita al minuto nelle API e nella UI, ma il dato persistente resta l'evento produttivo con il suo intervallo temporale. In questo modo si evita di duplicare un valore calcolato che potrebbe diventare incoerente dopo una modifica della dichiarazione.

La media produttiva articolo-linea viene calcolata sulle dichiarazioni `CONFERMATA` con orari validi. Le dichiarazioni `PREVISTA` non alimentano la media reale fino alla conferma.

## Estensione Logica: Costi Produttivi E Team Operativo

DB_FARMFLOW introduce tabelle dedicate a team e costi perche queste informazioni non sono master data ERP. Sono dominio operativo MES.

Tabelle introdotte o consolidate:

- FF_OPERATORI: anagrafica minima FactoryFlow se non esiste fonte esterna autorevole;
- FF_RUOLI_OPERATIVI: ruoli svolti nel processo produttivo;
- FF_DICHIARAZIONI_OPERATORI: collegamento tra dichiarazione e team operativo, con snapshot storico;
- FF_MACCHINE: risorse macchina operative se non gia governate in modo sufficiente da AdHoc;
- FF_SETUP_TIPI: classificazione dei setup;
- FF_SETUP_REGOLE: regole standard e specifiche articolo-linea;
- FF_COSTI_LINEA: costi validi per periodo di linea/macchina;
- FF_COSTI_ARTICOLO_LINEA: costi variabili specifici articolo-linea;
- FF_METRICHE_PRODUZIONE: metriche operative derivate dalla dichiarazione;
- FF_COSTI_PRODUZIONE: fotografia del costo industriale calcolato.

I codici articolo restano riferimenti esterni ad AdHoc. Nessuna tabella duplica anagrafiche ERP.
