# FactoryFlow - Process Centric Migration Plan

## Scopo Del Documento

Questo documento rappresenta la Fase 1 della migrazione process-centric di FactoryFlow.

Non contiene codice.

Non contiene SQL da eseguire.

Non autorizza ancora modifiche implementative.

Serve a fotografare lo stato attuale del progetto e a stabilire come far evolvere l'MVP senza riscriverlo.

Il principio guida e:

```text
EVOLUZIONE
mai
RISCRITTURA
```

FactoryFlow deve passare da applicazione centrata sulla "Dichiarazione Produzione" a piattaforma centrata su:

```text
Processo Produttivo
  -> Versione Processo
  -> Fasi Processo
  -> Attivita Produttiva
  -> Chiusura Fase
  -> eventuale Documento ERP AdHoc
```

La dichiarazione produzione non scompare.

Diventa uno dei possibili effetti della chiusura di una fase.

## Principio Del Custode

Prima di qualunque modifica occorre verificare se stiamo modellando:

- un processo;
- una fase;
- una attivita pianificata;
- una chiusura fase;
- un effetto ERP.

Se invece stiamo ancora ragionando come se tutto fosse una dichiarazione produzione, l'implementazione deve fermarsi.

## Sintesi Della Situazione Attuale

L'MVP attuale e prezioso e deve essere protetto.

Funziona per il caso operativo piu importante:

- selezione linea;
- selezione articolo producibile;
- caricamento distinta AdHoc;
- selezione lotti;
- inserimento quantita;
- conferma;
- chiamata alla stored AdHoc;
- generazione documenti;
- aggiornamento lotti;
- salvataggio storico FactoryFlow;
- gestione PREVISTA / CONFERMATA / ANNULLATA.

Questo flusso non va riscritto.

Va incapsulato come caso particolare:

```text
chiusura di una fase produttiva che genera ERP
```

## Elementi Gia Coerenti Con Il Nuovo Modello

### Documentazione

Sono gia coerenti e vanno mantenuti come riferimento:

- `docs/22_Processo_Fasi_Chiusura_Fase.md`
- `docs/ADR/ADR-0007_Processo_produttivo_non_appartiene_all_articolo.md`
- `docs/09_FactoryFlow_Domain_Diagram.md`
- `docs/08_FactoryFlow_Production_Domain.md`
- `docs/10_Process_Performance_And_Continuous_Improvement.md`
- `docs/11_Refactoring_Process_Centric_Review.md`

Questi documenti stabiliscono che il Processo Produttivo non appartiene obbligatoriamente all'articolo.

### Backend

Esistono gia primi controller process-centric:

- `ProcessiController`
- `AttivitaController`

Questi sono una base utile, ma non ancora corretta in tutti i dettagli.

### Database

La migrazione `20260705_Process_Centric_Model.sql` ha introdotto un primo nucleo:

- `FF_PROCESSI_PRODUTTIVI`
- `FF_PROCESSI_VERSIONI`
- `FF_PROCESSI_FASI`
- `FF_PROCESSI_FASI_RISORSE`
- `FF_ATTIVITA_PRODUTTIVE`
- `FF_ATTIVITA_METRICHE`
- `FF_ATTIVITA_SCOSTAMENTI`
- `FF_PROCESSI_MODIFICHE`

Queste tabelle vanno considerate una base da evolvere, non da cancellare.

### UI Flutter

Esiste gia una pagina:

- `processi_produttivi_page.dart`

Esiste gia una navigazione laterale:

- `app_shell.dart`

La struttura puo essere riutilizzata per la nuova area processi.

## Elementi Ancora Centrati Sulla Dichiarazione Produzione

### Backend - Controller

`ProduzioneController` e ancora il controller dominante per il flusso operativo.

Endpoint attuali:

- `GET /api/produzione/articoli`
- `GET /api/produzione/articoli/{codArticolo}/produttivita`
- `GET /api/produzione/distinta`
- `GET /api/produzione/lotti`
- `GET /api/produzione/dichiarazioni/calendario`
- `GET /api/produzione/dichiarazioni`
- `GET /api/produzione/dichiarazioni/{id}`
- `PUT /api/produzione/dichiarazioni/{id}`
- `DELETE /api/produzione/dichiarazioni/{id}`
- `POST /api/produzione/dichiarazioni/{id}/conferma`
- `POST /api/produzione/dichiarazione`

Questi endpoint non devono essere rimossi.

Devono diventare endpoint legacy/compatibili o adapter verso la chiusura fase.

### Backend - Service

`ProduzioneService` e ancora centrato su:

- articolo prodotto obbligatorio;
- quantita prodotta obbligatoria;
- lotto prodotto obbligatorio;
- componenti obbligatori;
- orari obbligatori sempre;
- distinta sempre legata ad articolo.

Nel nuovo modello questi obblighi non appartengono al servizio produzione.

Appartengono ai requisiti della fase.

### Backend - Repository

`ProduzioneRepository` contiene la logica piu delicata e va protetto.

Contiene:

- salvataggio dichiarazione prevista;
- chiamata a `dbo.sp_FactoryFlow_CreaDichiarazioneProduzione`;
- salvataggio storico in `FF_DICHIARAZIONI_PRODUZIONE`;
- salvataggio componenti;
- salvataggio operatori;
- conferma dichiarazione prevista;
- modifica storico;
- cancellazione logica;
- sincronizzazione AdHoc;
- riallineamento documenti e saldi.

Non va riscritto.

Va progressivamente invocato da un nuovo servizio di chiusura fase quando la fase genera ERP.

### Backend - DTO

DTO ancora centrati sulla dichiarazione:

- `DichiarazioneProduzioneRequestDto`
- `DichiarazioneProduzioneResultDto`
- `DichiarazioneProduzioneComponenteDto`
- `DichiarazioneStoricoDto`
- `DichiarazioneStoricoUpdateDto`
- `DichiarazioneStoricoComponenteDto`
- `DichiarazioneCalendarioGiornoDto`
- `DichiarazioneOperatoreDto`
- `ProduttivitaArticoloDto`
- `ArticoloProduzioneDto`
- `DistintaProduzioneDto`
- `LottoProduzioneDto`

Questi DTO devono rimanere disponibili per compatibilita.

Ma il nuovo linguaggio dominante deve introdurre DTO dedicati a:

- `Processo`
- `VersioneProcesso`
- `FaseProcesso`
- `RequisitiFase`
- `AttivitaProduttiva`
- `ChiusuraFase`
- `ConsuntivoFase`
- `ScostamentoProcesso`
- `EffettoErpAdHoc`

### Backend - AttivitaController

`AttivitaController` e utile ma ancora articolo-centrico.

Problema rilevato:

```text
SaveAttivita richiede CodArticolo obbligatorio.
```

Questo viola il nuovo modello.

Una attivita di calendario puo rappresentare una fase di preparazione, setup o controllo qualita senza articolo.

Da estendere:

- collegamento esplicito a `IdFase`;
- rimozione dell'obbligatorieta concettuale di `CodArticolo`;
- campi previsti solo se richiesti dalla fase;
- stato coerente con attivita e chiusura fase.

### Backend - ProcessiController

`ProcessiController` e una base corretta, ma ha ancora residui articolo-centrici.

Problemi rilevati:

- `ProcessoDto` contiene `CodArticolo`;
- `ProcessoRequest` contiene `CodArticolo`;
- `sp_FF_Processi_Save` gestisce `CodArticolo`;
- `FF_PROCESSI_PRODUTTIVI` contiene `CodArticolo`;
- esiste indice `IX_FF_PROCESSI_PRODUTTIVI_Articolo`.

Questi elementi non vanno rimossi subito.

Devono essere declassati a compatibilita o sostituiti da una relazione opzionale e temporale tra fase e articolo.

La regola corretta e:

```text
il processo non appartiene all'articolo;
l'articolo puo essere richiesto da una fase;
l'articolo puo essere consuntivato nella chiusura fase.
```

## Elementi Flutter Ancora Centrati Sulla Dichiarazione

### Pagina Dichiarazione

`dichiarazione_produzione_page.dart` e ancora costruita sul caso unico:

- linea;
- macchina;
- articolo;
- quantita;
- magazzino PF;
- lotto prodotto;
- data;
- ora inizio;
- ora fine;
- distinta;
- componenti;
- lotti;
- team operativo;
- conferma produzione.

Nel nuovo modello questa pagina deve diventare:

```text
Chiusura Fase
```

Il form non deve essere fisso.

Deve essere generato dai requisiti della fase.

### Pagina Calendario

`storico_dichiarazioni_page.dart` e oggi il calendario dichiarazioni.

Va mantenuto per retrocompatibilita, ma deve evolvere verso:

```text
calendario attivita produttive
```

La lista sotto calendario non deve mostrare soltanto dichiarazioni.

Deve mostrare attivita e chiusure, evidenziando se esiste o meno un effetto ERP.

### Service Flutter

`produzione_service.dart` contiene troppe responsabilita:

- configurazione;
- linee;
- operatori;
- ruoli;
- macchine;
- setup;
- costi linea;
- processi;
- articoli;
- distinta;
- lotti;
- dichiarazioni;
- conferma.

Per la migrazione va mantenuto, ma non deve crescere ulteriormente.

Serve separare progressivamente:

- `ProcessiService`;
- `AttivitaService`;
- `ChiusureFaseService`;
- `ProduzioneLegacyService` o adapter compatibile.

### Modelli Flutter

`produzione.dart` contiene sia modelli legacy sia modelli nuovi.

Questo e accettabile per l'MVP, ma non per la crescita del prodotto.

Va separato in file coerenti:

- `processo.dart`;
- `fase_processo.dart`;
- `attivita_produttiva.dart`;
- `chiusura_fase.dart`;
- `produzione_legacy.dart`;
- `risorse.dart`;
- `operatori.dart`;
- `setup.dart`.

## Tabelle Da Mantenere

### AdHoc / ERP

Non modificare:

- `DOC_MAST`;
- `DOC_DETT`;
- `SALDILOT`;
- `LOTTIART`;
- `cpwarn`;
- tabelle AdHoc coinvolte dalla stored validata.

La stored:

- `dbo.sp_FactoryFlow_CreaDichiarazioneProduzione`

resta il motore ufficiale dell'effetto ERP.

### DB_FARMFLOW - MVP

Mantenere:

- `FF_CONFIG`;
- `FF_LINEE_LAVORAZIONE`;
- `FF_LINEE_ARTICOLI`;
- `FF_DICHIARAZIONI_PRODUZIONE`;
- `FF_DICHIARAZIONI_COMPONENTI`;
- `FF_DICHIARAZIONI_OPERATORI`;
- `FF_AUDIT_EVENTI`.

Queste tabelle rappresentano lo storico del MVP e la compatibilita operativa.

Non devono essere cancellate.

### DB_FARMFLOW - Nuovo nucleo

Mantenere ed evolvere:

- `FF_PROCESSI_PRODUTTIVI`;
- `FF_PROCESSI_VERSIONI`;
- `FF_PROCESSI_FASI`;
- `FF_PROCESSI_FASI_RISORSE`;
- `FF_ATTIVITA_PRODUTTIVE`;
- `FF_ATTIVITA_METRICHE`;
- `FF_ATTIVITA_SCOSTAMENTI`;
- `FF_PROCESSI_MODIFICHE`.

## Tabelle Da Rinominare Concettualmente O Riallineare

### FF_DICHIARAZIONI_FINE_PROCESSO

La migrazione `20260706_Dichiarazione_Fine_Processo.sql` ha introdotto:

- `FF_DICHIARAZIONI_FINE_PROCESSO`;
- `FF_DICHIARAZIONI_FASI`;
- `FF_DICHIARAZIONI_FASI_RISORSE`;
- `FF_DICHIARAZIONI_FASI_TEAM`.

Questa direzione e stata superata dalla decisione ADR-0007.

Non usare DROP.

Non usarle come modello dominante.

Classificarle come strutture da congelare e riallineare.

La direzione corretta non e "fine processo", ma:

```text
chiusura fase / consuntivo fase
```

Possibili azioni future:

- creare nuove tabelle `FF_CHIUSURE_FASE` e correlate;
- oppure riutilizzare le tabelle esistenti solo se rinominate concettualmente tramite layer applicativo e compatibilita;
- evitare di costruire nuova UI sopra `FF_DICHIARAZIONI_FINE_PROCESSO`.

### FF_ATTIVITA_PRODUTTIVE

Problema:

- contiene `CodArticolo NOT NULL`;
- contiene `IdDichiarazione`;
- contiene `IdLinea`, `IdMacchina`, `IdTeam` direttamente sull'attivita.

Nuova regola:

- l'attivita deve riferirsi alla fase;
- articolo, linea, macchina e team devono essere richiesti o consuntivati secondo i requisiti della fase;
- i campi attuali possono restare per compatibilita MVP, ma vanno resi opzionali nel modello futuro.

## Tabelle Da Estendere

### FF_PROCESSI_FASI

Deve contenere o essere collegata ai requisiti della fase.

Requisiti necessari:

- richiede macchina;
- richiede team;
- richiede setup;
- richiede orari;
- richiede articolo prodotto;
- richiede lotto;
- richiede componenti;
- richiede controllo qualita;
- richiede note;
- genera ERP;
- genera carico PF;
- genera scarico componenti.

Scelta consigliata:

creare una tabella separata:

```text
FF_PROCESSI_FASI_REQUISITI
```

Motivo:

- evita di gonfiare `FF_PROCESSI_FASI`;
- permette evoluzioni future;
- consente requisiti diversi per versione/fase;
- rende leggibile la generazione dinamica della UI.

### FF_ATTIVITA_PRODUTTIVE

Da estendere con:

- `IdFase`;
- stato coerente con pianificazione e chiusura;
- riferimento opzionale alla chiusura fase;
- dati previsti minimi.

### Nuova area Chiusura Fase

Da introdurre in modo additivo:

- `FF_CHIUSURE_FASE`;
- `FF_CHIUSURE_FASE_RISORSE`;
- `FF_CHIUSURE_FASE_TEAM`;
- `FF_CHIUSURE_FASE_COMPONENTI`;
- `FF_CHIUSURE_FASE_QUALITA`;
- `FF_CHIUSURE_FASE_ERP`.

Queste tabelle devono conservare la fotografia storica del consuntivo.

Non devono sostituire subito `FF_DICHIARAZIONI_PRODUZIONE`.

Devono collegarsi ad essa quando la fase genera ERP.

## Cosa Va Rinominato

### Linguaggio Utente

Da:

```text
Dichiarazione Produzione
```

A:

```text
Chiusura Fase
```

Eccezione:

la vecchia voce puo restare come "Dichiarazione" o "Dichiarazione ERP" per retrocompatibilita.

### Linguaggio Backend

Non usare come linguaggio dominante:

- `ProduzioneService`;
- `ProduzioneRepository`;
- `DichiarazioneProduzioneRequest`;
- `DichiarazioneProduzioneResult`;
- `DichiarazioneStorico`.

Introdurre:

- `ChiusuraFaseService`;
- `ChiusuraFaseRepository`;
- `ChiusuraFaseRequest`;
- `ChiusuraFaseResult`;
- `ConsuntivoFaseDto`;
- `EffettoErpAdHocDto`.

### Linguaggio Flutter

Da introdurre:

- `chiusura_fase_page.dart`;
- `attivita_produttive_page.dart`;
- `processi_dashboard_page.dart`;
- `chiusura_fase_service.dart`;
- `attivita_service.dart`.

## Cosa Va Esteso

### Processi

Estendere il processo in modo che non sia articolo-centrico.

Azioni future:

- non rendere obbligatorio `CodArticolo`;
- non usare l'articolo come filtro principale del processo;
- aggiungere relazioni opzionali fase-articolo dove serve;
- mostrare chiaramente che il processo e un percorso operativo.

### Fasi

Estendere ogni fase con requisiti di chiusura.

Le fasi devono poter essere:

- preparazione macchina;
- setup;
- tostatura;
- miscelazione;
- confezionamento;
- controllo qualita;
- fase produttiva ERP;
- fase senza ERP.

### Attivita

Trasformare le attivita da produzione prevista a fase pianificata.

Azioni future:

- collegare l'attivita a `IdFase`;
- consentire attivita senza articolo;
- consentire attivita senza quantita;
- consentire attivita senza ERP;
- conservare la compatibilita con il calendario MVP.

### Chiusura Fase

Introdurre il nuovo punto operativo.

La chiusura fase deve:

- leggere i requisiti della fase;
- validare solo i dati richiesti;
- salvare snapshot storico;
- generare ERP solo se richiesto;
- collegare eventuale dichiarazione legacy;
- calcolare metriche e scostamenti.

## Cosa NON Deve Essere Toccato

Non modificare:

- stored AdHoc `dbo.sp_FactoryFlow_CreaDichiarazioneProduzione`;
- logica documenti ERP;
- logica carico/scarico;
- gestione lotti;
- seriali AdHoc;
- progressivi AdHoc;
- aggiornamento `SALDILOT`;
- endpoint esistenti se non mantenendo retrocompatibilita;
- dati storici gia confermati;
- tabelle AdHoc.

Non usare:

- `DROP`;
- riscritture invasive;
- rinomina fisica immediata di tabelle usate dal MVP;
- migrazioni che obbligano tutti i processi ad avere articolo.

## Dipendenze

### Dipendenze Tecniche

- La chiusura fase con ERP dipende dalla stored AdHoc validata.
- La chiusura fase con componenti dipende dalla distinta AdHoc.
- La scelta lotti dipende da AdHoc e disponibilita `SALDILOT`.
- La chiusura fase con team dipende da operatori, ruoli e team operativi.
- La chiusura fase con macchina dipende da anagrafica macchine e validita temporale.
- Gli scostamenti dipendono da standard fase e consuntivo fase.

### Dipendenze Funzionali

- Prima di creare una attivita occorre avere processo, versione e fase.
- Prima di chiudere una fase occorre conoscere i requisiti della fase.
- Prima di generare ERP occorre avere articolo, quantita, lotto e componenti se richiesti.
- Prima di calcolare costi occorre fotografia storica di team, macchina, tempi e risorse.

### Dipendenze Di Compatibilita

- Le dichiarazioni esistenti devono continuare ad apparire nel calendario.
- Le API `/api/produzione/*` devono continuare a funzionare.
- La UI MVP deve restare utilizzabile per il caso fase unica ERP.
- I dati storici non devono essere riscritti.

## Rischi

### Rischio 1 - Tornare All'Articolo Come Centro

Rischio alto.

Segnali:

- rendere obbligatorio `CodArticolo` su processo o attivita;
- filtrare i processi solo per articolo;
- generare sempre distinta;
- mostrare sempre lotto e componenti.

Mitigazione:

- requisiti fase obbligatori;
- articolo solo nella chiusura della fase che lo richiede.

### Rischio 2 - Usare "Fine Processo" Come Oggetto Monolitico

Rischio alto.

La migrazione del 2026-07-06 ha introdotto una struttura utile come esperienza, ma concettualmente superata.

Mitigazione:

- congelare quella direzione;
- introdurre chiusura fase come nucleo;
- non costruire nuova UI su `FF_DICHIARAZIONI_FINE_PROCESSO`.

### Rischio 3 - Rompere Il MVP Validato

Rischio alto.

La stored AdHoc e il flusso documentale sono validati.

Mitigazione:

- non toccare stored;
- chiamarla solo come effetto ERP della chiusura fase;
- mantenere adapter legacy.

### Rischio 4 - Creare UI Troppo Generica

Rischio medio.

Una UI completamente dinamica puo diventare poco usabile.

Mitigazione:

- generazione dinamica guidata dai requisiti fase;
- template predefiniti per fasi comuni;
- MVP fase unica quasi identico all'attuale.

### Rischio 5 - Perdere Ricostruibilita Storica

Rischio alto.

Modifiche a team, costi, macchine o setup non devono alterare chiusure gia avvenute.

Mitigazione:

- snapshot su chiusura fase;
- validita temporale;
- nessun aggiornamento retroattivo dei costi storici.

## Piano Di Migrazione Consigliato

### Passo 1 - Congelamento Semantico

Accettare formalmente che:

- `Dichiarazione Produzione` e legacy compatibile;
- `Chiusura Fase` e il nuovo nucleo;
- `Dichiarazione Fine Processo` non e il modello guida.

### Passo 2 - Requisiti Fase

Introdurre requisiti fase nel modello dati e nelle API.

Non modificare ancora la UI principale.

### Passo 3 - Attivita Per Fase

Estendere `FF_ATTIVITA_PRODUTTIVE` e API correlate per collegare una attivita a una fase.

Rendere articolo e quantita opzionali nel nuovo modello.

### Passo 4 - Chiusura Fase

Introdurre endpoint e tabelle di chiusura fase.

La chiusura fase deve poter salvare anche fasi senza ERP.

### Passo 5 - Adapter ERP

Quando una fase genera ERP, la chiusura fase costruisce il payload compatibile con la stored validata e salva il collegamento alla dichiarazione legacy.

### Passo 6 - UI Chiusura Fase

Trasformare la pagina dichiarazione in pagina chiusura fase.

Per il caso fase unica ERP, la UI deve apparire quasi identica all'MVP.

### Passo 7 - Dashboard Processi

Creare dashboard:

```text
Processi Produttivi
  -> Versioni
  -> Fasi
  -> Attivita
  -> Chiusure
  -> Scostamenti
```

La vecchia dashboard dichiarazioni resta disponibile.

## Decisione Del Custode

Autorizzato procedere solo dopo questo piano con una migrazione additiva.

Non e autorizzato:

- riscrivere il MVP;
- cancellare tabelle;
- modificare la stored AdHoc;
- rendere il processo obbligatoriamente legato ad articolo;
- costruire la nuova fase su "dichiarazione fine processo" come oggetto centrale.

La prossima implementazione ammessa deve partire dai requisiti fase e dalla chiusura fase.

## Regola Finale

FactoryFlow non deve piu crescere attorno alla domanda:

```text
che cosa ho prodotto?
```

Deve crescere attorno alla domanda:

```text
quale fase del processo ho chiuso, quali dati richiedeva, e quale effetto ha generato?
```

Solo cosi la dichiarazione del prodotto finito diventa una conseguenza corretta del processo industriale, non il centro fragile del sistema.
