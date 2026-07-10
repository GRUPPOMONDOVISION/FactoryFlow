# FactoryFlow - Refactoring Process Centric Review

## Scopo Del Documento

Questo documento e la review architetturale obbligatoria prima di qualunque intervento su codice, database, backend o frontend.

FactoryFlow deve essere riallineato al dominio piu recente:

```text
Processo Produttivo
  -> Processo Standard
  -> Attivita Produttiva
  -> Processo Consuntivato
  -> Dichiarazione
  -> Documento ERP AdHoc
  -> Dashboard Scostamenti
```

La dichiarazione produzione resta fondamentale, ma non deve piu essere il centro concettuale del sistema.

La dichiarazione deve evolvere in chiusura fase o consuntivo fase. La chiusura fase e la fotografia del lavoro reale, collegata a una fase di una versione di Processo Produttivo.

## Giudizio Del Custode

FactoryFlow oggi ha un MVP operativo prezioso e da proteggere.

La parte piu solida e l'integrazione con AdHoc: la dichiarazione genera documenti ERP veri, usa la distinta AdHoc, movimenta lotti e mantiene il legame con seriali e numeri documento.

La parte piu fragile e il modello concettuale interno: molte strutture sono nate attorno alla dichiarazione produzione e non ancora attorno al Processo Produttivo.

Questo non e un errore grave per l'MVP.

Diventerebbe pero un errore architetturale se venisse consolidato come modello definitivo.

La correzione deve essere additiva, progressiva e non distruttiva.

Non bisogna riscrivere l'MVP.

Bisogna introdurre il nuovo nucleo process-centric e collegare gradualmente la dichiarazione esistente a questo nucleo.

## Parti Gia Coerenti Con Il Nuovo Dominio

### AdHoc Rimane Fonte Ufficiale ERP

FactoryFlow continua a rispettare il principio corretto: AdHoc resta proprietario di articoli, distinte, documenti, lotti e giacenze.

La stored `dbo.sp_FactoryFlow_CreaDichiarazioneProduzione` rimane il punto ufficiale per generare l'effetto gestionale:

- carico prodotto finito;
- scarico componenti;
- aggiornamento lotti;
- collegamento documentale;
- seriali AdHoc.

Questa parte e coerente con il Domain Diagram: il Documento ERP e effetto gestionale ufficiale, non centro del dominio FactoryFlow.

### Dichiarazione Con Stati PREVISTA / CONFERMATA

La logica gia introdotta per la dichiarazione futura e corretta:

- se la data e futura, la dichiarazione resta `PREVISTA`;
- se manca il seriale AdHoc, non e ancora stata confermata verso ERP;
- solo alla conferma viene generato il documento AdHoc.

Questo anticipa correttamente il concetto di Attivita Produttiva prevista.

Il limite e che oggi questo comportamento vive ancora dentro la dichiarazione, non dentro una vera Attivita Produttiva.

### Tempi Di Produzione

I campi di ora inizio e ora fine produzione sono coerenti con il nuovo dominio.

Il tempo e un driver essenziale per:

- produttivita;
- costo macchina;
- costo manodopera;
- energia;
- scostamenti;
- confronto standard/consuntivo.

Questa scelta va mantenuta e collegata al futuro modello di attivita e processo.

### Team Operativo E Snapshot Sulla Dichiarazione

La presenza di operatori collegati alla dichiarazione e una base utile.

Il fatto che esistano snapshot come operatore, ruolo, costo orario applicato e costo totale e coerente con la fotografia storica.

Il principio e giusto: il costo storico non deve cambiare se domani cambia il costo orario dell'operatore o la composizione del team.

### Validita Temporale Parziale

Sono gia presenti segnali corretti:

- `ValidoDal` / `ValidoAl` su composizione team;
- `ValidoDal` / `ValidoAl` su regole setup;
- obsolescenza operatori;
- costi linea con periodo di validita.

Questa direzione e coerente con ADR-0005.

Va pero resa uniforme: ogni dato che incide su costi, tempi, capacita o produttivita deve seguire la stessa logica.

### Calendario Come Punto Operativo

Il calendario dichiarazioni e una buona interfaccia operativa per la fabbrica.

Dal punto di vista del nuovo dominio, deve evolvere da calendario delle dichiarazioni a calendario delle attivita produttive.

La UI attuale puo rimanere compatibile, ma il significato deve cambiare progressivamente.

## Parti Ancora Troppo Centrate Sulla Dichiarazione

### La Dichiarazione E Ancora Il Centro Dei Dati

Le tabelle principali operative sono ancora:

- `FF_DICHIARAZIONI_PRODUZIONE`;
- `FF_DICHIARAZIONI_COMPONENTI`;
- `FF_DICHIARAZIONI_OPERATORI`;
- `FF_METRICHE_PRODUZIONE`;
- `FF_COSTI_PRODUZIONE`.

Queste tabelle descrivono cio che e stato dichiarato, ma non descrivono ancora:

- Processo Produttivo;
- Versione Processo;
- Fasi Processo;
- Attivita Produttiva;
- Standard atteso;
- Scostamenti processo.

Il rischio e che il consuntivo diventi anche lo standard.

Questo sarebbe concettualmente sbagliato.

### Le Metriche Sono Legate Alla Dichiarazione, Non All'Attivita

`FF_METRICHE_PRODUZIONE` e `FF_COSTI_PRODUZIONE` sono collegate a `IdDichiarazione`.

Per l'MVP e accettabile.

Per il modello futuro non basta.

Le metriche devono poter rispondere a domande come:

- questa attivita ha rispettato lo standard?
- questa versione del processo sta migliorando?
- questa fase crea piu scostamento?
- questa risorsa produce costi anomali?

Queste domande richiedono collegamento a:

- Attivita Produttiva;
- Versione Processo;
- Fase Processo;
- risorsa/fase;
- standard atteso.

### La Distinta Rischia Di Essere Trattata Come Processo

Gli endpoint e la UI attuali partono spesso da:

- articolo producibile;
- distinta;
- quantita;
- componenti;
- lotti;
- conferma.

Questo e corretto per registrare produzione.

Non e sufficiente per descrivere il processo produttivo.

La distinta appartiene ad AdHoc e descrive i materiali. Non descrive fasi, setup, tempi, risorse, energia, qualita e regole di costo.

Se FactoryFlow continua a partire solo da distinta e dichiarazione, il Processo Produttivo resta implicito. Un processo implicito non puo essere versionato, confrontato o migliorato.

### Linea E Macchina Non Sono Ancora Abbastanza Separate

Il dominio ha iniziato a distinguere linee e macchine, ma alcune strutture possono ancora creare confusione.

In particolare, `FF_MACCHINE` risulta collegata direttamente a una linea.

Questo puo funzionare per una PMI, ma non e sufficiente per il dominio definitivo:

- una macchina puo appartenere a piu linee in periodi diversi;
- una macchina puo partecipare a fasi diverse;
- una fase puo avere risorse alternative;
- una linea puo usare piu macchine.

Il collegamento macchina-linea deve diventare temporale e contestuale, non una proprieta rigida della macchina.

### Setup E Costi Sono Ancora Fuori Dal Processo

Le regole setup e i costi linea/macchina sono presenti, ma non sono ancora governati da una versione di Processo Produttivo.

Questo e un rischio.

Il costo industriale non deve essere appeso solo a linea, macchina o articolo.

Deve essere interpretato dentro il processo e dentro la sua versione valida.

### Operatori, Team E Ruoli Sono Configurazioni, Ma Non Ancora Contesto Di Processo

La gestione operatori/team e utile, ma oggi e ancora trattata principalmente come impostazione e come dettaglio della dichiarazione.

Nel nuovo modello il team puo essere:

- previsto dallo standard;
- selezionato per l'attivita;
- fotografato nel consuntivo;
- confrontato negli scostamenti.

Questa sequenza non e ancora completa.

## Nomi, DTO, Endpoint, Pagine E Tabelle A Rischio Ambiguita

### Backend - Endpoint

Gli endpoint attuali sono MVP-oriented:

- `GET /api/produzione/articoli`;
- `GET /api/produzione/distinta`;
- `GET /api/produzione/lotti`;
- `POST /api/produzione/dichiarazione`;
- `GET /api/produzione/dichiarazioni`;
- `GET /api/produzione/dichiarazioni/calendario`;
- `POST /api/produzione/dichiarazioni/{id}/conferma`;
- endpoint parametri operativi per macchine, setup, team e costi.

Il rischio non e tecnico.

Il rischio e semantico: tutto passa ancora da `produzione` e `dichiarazione`, mentre il nuovo dominio richiede `processi`, `versioni`, `fasi`, `attivita`, `metriche` e `scostamenti`.

### Backend - DTO E Servizi

Sono semanticamente da rivedere:

- `DichiarazioneProduzioneRequestDto`;
- `DichiarazioneProduzioneResultDto`;
- `DichiarazioneStoricoDto`;
- `DichiarazioneStoricoUpdateDto`;
- `ProduttivitaArticoloDto`;
- `DistintaProduzioneDto`;
- `ProduzioneService`;
- `IProduzioneRepository`;
- `ProduzioneRepository`.

Questi nomi non sono sbagliati per l'MVP, ma non devono diventare il linguaggio dominante del sistema.

Il futuro nucleo deve introdurre nomi espliciti:

- `ProcessoProduttivo`;
- `VersioneProcesso`;
- `FaseProcesso`;
- `AttivitaProduttiva`;
- `MetricaAttivita`;
- `ScostamentoProcesso`.

### Frontend - Pagine

Le pagine attuali sono:

- calendario dichiarazioni;
- dichiarazione produzione;
- impostazioni;
- assegnazione articoli;
- team operativi;
- macchine;
- setup;
- costi produzione.

Sono utili per l'MVP, ma manca la pagina concettualmente centrale:

- Processi Produttivi.

Manca anche una dashboard:

- Process Performance.

La pagina dichiarazione produzione deve restare, ma non deve continuare a essere il solo ingresso operativo al dominio produttivo.

### Tabelle

Sono semanticamente da preservare ma non da elevare a centro definitivo:

- `FF_DICHIARAZIONI_PRODUZIONE`;
- `FF_DICHIARAZIONI_COMPONENTI`;
- `FF_DICHIARAZIONI_OPERATORI`;
- `FF_METRICHE_PRODUZIONE`;
- `FF_COSTI_PRODUZIONE`.

Sono invece da rivedere con attenzione:

- `FF_MACCHINE`, se mantiene un legame troppo rigido con una sola linea;
- `FF_COSTI_LINEA`, se diventa proprietaria del costo invece di contribuire al costo del processo;
- `FF_SETUP_REGOLE`, se resta fuori da versione/fase/processo;
- `FF_LINEE_ARTICOLI`, se viene interpretata come processo invece che come abilitazione operativa semplice.

## Modifiche Necessarie

### Introdurre Il Nucleo Process-Centric

Il nuovo nucleo minimo deve introdurre concettualmente:

- Processo Produttivo;
- Versione Processo;
- Fase Processo;
- Risorse ammesse per fase;
- Setup previsto per fase/processo;
- Costi standard per fase/processo;
- Attivita Produttiva;
- Metriche Attivita;
- Scostamenti Attivita/Processo;
- Modifiche Processo motivate.

Questo nucleo deve essere introdotto in modo additivo.

Non deve sostituire subito le dichiarazioni esistenti.

### Collegare La Dichiarazione A Una Attivita Produttiva

La dichiarazione deve ricevere un collegamento verso l'Attivita Produttiva.

Il flusso corretto deve diventare:

```text
Processo Produttivo
  -> Versione valida
  -> Attivita Produttiva
  -> Dichiarazione prevista o confermata
  -> Documento ERP AdHoc se confermata
```

Per retrocompatibilita, le dichiarazioni esistenti potranno avere attivita generata automaticamente o collegamento nullo temporaneo.

### Versionare Il Processo

Ogni modifica significativa deve generare una nuova versione.

Non devono essere aggiornati retroattivamente:

- tempi standard;
- setup standard;
- risorse ammesse;
- costi standard;
- benchmark produttivi;
- regole energetiche;
- fasi.

### Spostare Lo Standard Fuori Dalla Dichiarazione

La dichiarazione deve fotografare il consuntivo.

Lo standard deve vivere nella versione di processo.

La dichiarazione puo salvare snapshot dei valori standard usati al momento, ma non deve esserne proprietaria concettuale.

### Rendere Le Risorse Temporali

Le relazioni tra:

- fase e macchina;
- fase e linea;
- macchina e linea;
- team e processo;
- setup e fase;
- costo e risorsa;

devono avere validita temporale quando incidono su costi, tempi, capacita o produttivita.

### Introdurre Scostamenti Espliciti

Gli scostamenti devono diventare cittadini di primo livello.

Minimo:

- produttivita prevista/reale;
- costo previsto/reale;
- tempo previsto/reale;
- setup previsto/reale;
- materiali teorici/reali;
- energia prevista/reale;
- manodopera prevista/reale.

Quando i dati non bastano, il valore deve restare nullo e deve essere indicato il motivo del calcolo incompleto.

Meglio nessun numero che un numero falso.

## Modifiche Da Rinviare Per Non Rompere L'MVP

### Non Rinominare Subito Gli Endpoint Esistenti

Gli endpoint della dichiarazione produzione devono restare stabili.

Cambiarli subito romperebbe frontend, installazioni e collaudi.

Il nuovo modello deve affiancarli con endpoint nuovi e, in un secondo momento, farli diventare compatibilita.

### Non Eliminare Tabelle Esistenti

Non usare `DROP`.

Non distruggere `FF_DICHIARAZIONI_*`.

La storia gia registrata deve restare valida.

Le nuove tabelle devono essere additive.

### Non Mettere L'Ordine Di Produzione Al Centro

L'Ordine di Produzione va rinviato.

Non deve entrare ora come centro del modello, perche il focus attuale e:

- processo;
- standard;
- attivita;
- consuntivo;
- scostamenti;
- storicita.

### Non Fare Dashboard Avanzata

La dashboard Process Performance deve nascere semplice.

Prima deve mostrare pochi indicatori affidabili.

Grafici complessi senza modello consolidato sarebbero estetica, non architettura.

### Non Implementare MRP, OEE Completo, AI O Schedulazione Automatica

Questi moduli dipendono dal nuovo nucleo.

Implementarli prima significherebbe costruire sopra fondamenta ancora mobili.

## Rischi Di Retrocompatibilita

### Rischio Dati Esistenti

Le dichiarazioni gia registrate non hanno ancora:

- processo;
- versione processo;
- attivita produttiva;
- fase;
- scostamenti completi.

Serve una strategia di migrazione morbida:

- valori null ammessi per storico pre-refactoring;
- eventuale attivita tecnica generata solo se utile;
- nessuna ricostruzione inventata.

### Rischio Frontend

La UI attuale e costruita attorno a calendario e dichiarazione.

Inserire processi produttivi senza una transizione chiara rischia di confondere l'operatore.

La UI deve continuare a permettere il flusso rapido:

- scelgo articolo;
- scelgo linea;
- inserisco quantita;
- scelgo lotti;
- confermo.

Il processo deve emergere progressivamente come guida, non come ostacolo.

### Rischio Backend

Il repository `ProduzioneRepository` concentra molte responsabilita:

- lettura AdHoc;
- gestione dichiarazioni;
- storico;
- update AdHoc;
- metriche;
- operatori;
- conferma prevista.

Il nuovo modello richiede separazione graduale:

- produzione ERP/AdHoc;
- dichiarazioni;
- attivita produttive;
- processi;
- performance.

Non va riscritto tutto in una volta.

### Rischio Stored AdHoc

La stored AdHoc e validata e non deve essere modificata per introdurre il dominio processo.

Il collegamento processo/attivita deve restare in DB_FARMFLOW.

La stored deve continuare a ricevere i dati necessari per produrre il documento ERP.

### Rischio Linguaggio

Se nei nomi futuri si continua a usare genericamente "produzione" per tutto, il dominio restera ambiguo.

Serve disciplina:

- processo e modello operativo;
- attivita e esecuzione prevista o reale;
- dichiarazione e fotografia;
- documento ERP e effetto AdHoc;
- scostamento e confronto standard/consuntivo.

## Compatibilita Consigliata

### Strategia Ponte

La strategia corretta e:

1. introdurre processi/versioni/fasi in modo additivo;
2. mantenere gli endpoint dichiarazione esistenti;
3. quando l'utente crea una nuova dichiarazione, creare o collegare una Attivita Produttiva;
4. salvare sulla dichiarazione il riferimento all'attivita;
5. calcolare metriche e scostamenti se esistono dati standard;
6. se non esistono dati standard, lasciare scostamenti nulli;
7. non alterare il comportamento AdHoc gia validato.

### Processo Minimo Per MVP

Per non bloccare l'operativita, deve essere possibile creare un processo minimo:

- prodotto/articolo AdHoc;
- una versione corrente;
- una fase unica;
- linea ammessa;
- macchina opzionale;
- tempi standard opzionali;
- costi standard opzionali.

Questo permette alla PMI di usare il modello senza burocrazia.

### Processo Completo Per Evoluzione

La stessa struttura deve poter crescere verso:

- piu fasi;
- piu risorse per fase;
- alternative macchina;
- setup per fase;
- costi standard per fase;
- energia;
- qualita;
- scostamenti dettagliati;
- dashboard performance.

## Decisioni Architetturali Da Prendere Prima Della Fase 2

### 1. Processo Riutilizzabile E Non Articolo-Centrico

Decisione aggiornata: il processo non appartiene all'articolo.

Il Processo Produttivo e un percorso operativo riutilizzabile e versionato. L'articolo AdHoc entra nella chiusura della fase solo quando quella fase produce un articolo o deve generare effetto ERP.

Motivo: in alcuni casi articoli simili possono condividere una struttura produttiva; in altri una fase non produce alcun articolo. Legare rigidamente il processo all'articolo renderebbe impossibili preparazioni, setup, controlli qualita e attivita operative senza effetto magazzino.

### 2. Processo Consuntivato Come Tabella Autonoma?

Scelta consigliata per MVP: non introdurlo subito come tabella autonoma.

La fotografia consuntivata puo vivere inizialmente in dichiarazione, metriche, costi e scostamenti, purche sia collegata ad attivita e versione processo.

Una tabella autonoma potra arrivare quando il processo multi-fase sara maturo.

### 3. Fasi Obbligatorie?

Scelta consigliata: si, almeno una fase tecnica.

Motivo: senza fase, il modello non scala. Per una PMI la fase puo essere unica e invisibile o precompilata.

### 4. Collegamento Macchina-Linea

Scelta consigliata: spostare progressivamente il legame rigido verso relazioni temporali linea/macchina/fase.

Non rimuovere subito `IdLinea` da `FF_MACCHINE`, ma non usarlo come unica verita futura.

### 5. Scostamenti Salvati O Calcolati?

Scelta consigliata: salvare la fotografia degli scostamenti principali al momento della conferma, mantenendo anche la possibilita di ricalcoli analitici controllati.

Motivo: la dashboard storica non deve cambiare se cambiano gli standard futuri.

## Roadmap Tecnica Consigliata Dopo Questa Review

### Passo 1 - Documento Modello Dati Concettuale

Prima di scrivere SQL, aggiornare il modello dati logico con:

- processi;
- versioni;
- fasi;
- attivita;
- metriche;
- scostamenti;
- modifiche motivate.

### Passo 2 - Migrazione Additiva

Solo dopo approvazione del modello:

- creare migrazione idempotente;
- non usare `DROP`;
- non modificare stored AdHoc;
- non rompere dichiarazioni esistenti.

### Passo 3 - Backend Nuovo Nucleo

Introdurre repository/service separati:

- Processi;
- Attivita;
- Performance.

Non caricare ulteriore responsabilita dentro `ProduzioneRepository`.

### Passo 4 - UI Progressiva

Aggiungere:

- pagina Processi Produttivi;
- dettaglio versione/fasi;
- collegamento dichiarazione-attivita;
- prima dashboard Process Performance.

### Passo 5 - Test Storico

Verificare obbligatoriamente:

- modifica processo dopo conferma;
- costo storico invariato;
- scostamento storico invariato;
- documento AdHoc invariato;
- dichiarazione prevista non scrive AdHoc;
- dichiarazione confermata scrive AdHoc.

## Vincoli Da Non Violare

- Non fondere linea e macchina.
- Non trattare la distinta come processo.
- Non spostare dati AdHoc in DB_FARMFLOW se AdHoc ne e proprietario.
- Non aggiornare retroattivamente dati che hanno inciso su costi o scostamenti.
- Non usare `Attivo` come unica logica per dati che incidono sui costi.
- Non rendere l'Ordine di Produzione il centro del modello in questa fase.
- Non modificare la stored AdHoc per risolvere problemi di dominio MES.
- Non inventare scostamenti quando mancano dati standard.
- Non giudicare operatori o team; misurare condizioni e processo.

## Esito Della Review

Il progetto e pronto per una evoluzione process-centric, ma non e ancora process-centric.

L'MVP e valido e va preservato.

Il prossimo intervento non deve essere un refactoring impulsivo.

Deve essere una migrazione concettuale controllata:

```text
Dichiarazione centrica
  -> Dichiarazione collegata ad Attivita
  -> Attivita collegata a Versione Processo
  -> Versione collegata a Standard
  -> Consuntivo confrontato con Standard
  -> Dashboard Scostamenti
```

Autorizzazione architetturale:

- autorizzata la progettazione del nuovo modello dati concettuale;
- autorizzata solo successivamente una migrazione additiva e idempotente;
- non autorizzata alcuna riscrittura distruttiva dell'MVP;
- non autorizzato alcun cambio che rompa gli endpoint dichiarazione esistenti;
- non autorizzata alcuna modifica alla stored AdHoc validata per introdurre il dominio processo.

Il Custode dell'Architettura considera questa review il punto di controllo obbligatorio prima della Fase 2.

## Correzione Architetturale 2026-07-06 - Dal Processo Articolo-Centrico Alla Chiusura Fase

Questa review viene aggiornata con una correzione vincolante.

Il Processo Produttivo non deve essere progettato come appartenente a un Articolo AdHoc o a un Prodotto Finito.

Il Processo Produttivo e un percorso operativo. Il prodotto finito, la macchina, il team, i lotti, i componenti e il documento ERP sono dati da consuntivare nella chiusura della fase solo quando quella fase li richiede.

La catena corretta diventa:

```text
Processo Produttivo
  -> Versione Processo
  -> Fasi Processo
  -> Attivita di calendario
  -> Chiusura fase / consuntivo fase
  -> eventuale Documento ERP AdHoc
```

Conseguenze per il refactoring:

- le tabelle e le API gia nate attorno alla dichiarazione produzione devono rimanere compatibili, ma non devono guidare il modello futuro;
- la precedente idea di "dichiarazione fine processo" e troppo monolitica e va reinterpretata come chiusura fase;
- ogni fase deve dichiarare quali dati richiede alla chiusura;
- solo le fasi con effetto ERP chiamano la stored AdHoc;
- l'MVP a fase unica resta valido, ma deve essere letto come chiusura fase produttiva con effetto ERP.

La migrazione concettuale deve essere additiva e non distruttiva. Non si usano DROP e non si rompono endpoint esistenti senza compatibilita.



