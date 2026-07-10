# FactoryFlow - Architettura Definitiva

## Scopo Del Documento

Questo documento congela i principi architetturali di FactoryFlow prima dell'estensione funzionale del prodotto.

Non contiene implementazione tecnica o dettagli di codice. Definisce invece dove devono vivere le informazioni, quali dati appartengono ad AdHoc Revolution e quali possono appartenere a `DB_FARMFLOW`.

L'obiettivo e costruire un modello mantenibile per molti anni, evitando duplicazioni, scorciatoie e tabelle applicative che replichino logiche gia governate dal gestionale principale.

## Premessa Fondamentale

FactoryFlow non sostituisce AdHoc.

FactoryFlow e un'estensione operativa e moderna di AdHoc Revolution. Deve rendere piu semplice, veloce e controllata l'operativita di reparto, ma non deve diventare un secondo gestionale parallelo.

AdHoc rimane il sistema ufficiale per:

- articoli;
- distinte base;
- documenti;
- magazzino;
- lotti;
- contabilita;
- costi standard;
- cicli;
- clienti;
- fornitori.

FactoryFlow gestisce solo cio che AdHoc non gestisce in modo moderno, mobile, ergonomico, tracciabile o adatto all'uso operativo in produzione.

## Principio Di Separazione

Ogni nuova informazione deve essere classificata prima di creare una tabella.

Se l'informazione e gia gestita da AdHoc, resta in AdHoc.

Se l'informazione e una regola ufficiale di documenti, magazzino, lotti, articoli, distinte, costi standard, cicli, clienti o fornitori, resta in AdHoc.

Se l'informazione nasce solo per FactoryFlow, serve all'esperienza operativa, alla pianificazione futura, all'audit applicativo, a dati temporanei o a calcoli industriali non ufficiali, puo stare in `DB_FARMFLOW`.

## Regola Anti-Duplicazione

`DB_FARMFLOW` non deve duplicare:

- anagrafiche articolo;
- descrizioni articolo ufficiali;
- unita di misura ufficiali;
- distinte base ufficiali;
- dati lotto ufficiali;
- giacenze ufficiali;
- causali magazzino AdHoc;
- tipi documento AdHoc;
- alfanumerici documento;
- segni documento;
- costi standard ufficiali;
- cicli ufficiali;
- clienti;
- fornitori.

Quando FactoryFlow deve visualizzare questi dati, li legge da AdHoc.

Quando FactoryFlow deve registrare un evento documentale ufficiale, usa il motore transazionale validato che scrive in AdHoc secondo le regole AdHoc.

## Database Di Riferimento

### Database AdHoc

Contiene la verita gestionale ufficiale.

FactoryFlow puo leggerlo e, tramite procedure controllate, puo produrre documenti ufficiali. Non deve pero creare proprie copie persistenti delle anagrafiche o delle regole governate da AdHoc.

### DB_FARMFLOW

Contiene soltanto:

- configurazioni proprie di FactoryFlow;
- preferenze operative;
- storico proprio dell'applicazione;
- dati operativi non presenti in AdHoc;
- dati temporanei;
- dati di supporto per interfaccia, pianificazione e analisi;
- calcoli industriali non ufficiali;
- audit applicativo.

`DB_FARMFLOW` non deve diventare un secondo magazzino, una seconda distinta base, un secondo archivio articoli o una seconda contabilita industriale ufficiale.

## Decisione Su FF_CONFIG

### Scelta

Mantenere la tabella, ma con struttura ridotta e pulita.

### Database

`DB_FARMFLOW`.

### Motivazione

La configurazione di integrazione e propria di FactoryFlow. Non esiste come concetto applicativo in AdHoc, perche stabilisce come FactoryFlow si collega all'azienda AdHoc e quali causali operative usa.

### Struttura Logica

`FF_CONFIG` deve contenere:

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

### Regola Definitiva

`CausaleCarico` e `CausaleScarico` identificano i documenti AdHoc da usare per la produzione.

Da `[AZIENDA]TIP_DOCU`, usando la causale configurata, FactoryFlow ricava:

- codice documento effettivo;
- alfanumerico documento;
- causale magazzino;
- segno documento, se utile.

### Cosa Non Deve Contenere

`FF_CONFIG` non deve contenere:

- tipo documento carico;
- tipo documento scarico;
- alfanumerico carico;
- alfanumerico scarico;
- causale magazzino carico;
- causale magazzino scarico;
- segno carico;
- segno scarico.

Questi dati restano governati da AdHoc.

## Decisione Su Linee Produzione

### Scelta

Mantenere come dominio FactoryFlow, ma introdurre solo quando serve davvero.

### Database

`DB_FARMFLOW`.

### Motivazione

AdHoc gestisce articoli, distinte, cicli e documenti, ma non necessariamente una modellazione moderna e operativa delle linee viste dal reparto: disponibilita giornaliera, stato operativo, priorita, abilitazioni, vincoli ergonomici dell'interfaccia e regole di pianificazione visuale.

La linea produttiva, in FactoryFlow, e una risorsa operativa dell'applicazione. Non deve sostituire eventuali cicli AdHoc. Deve semmai appoggiarsi ai cicli ufficiali quando presenti.

### Regola

La linea non deve duplicare un centro di lavoro AdHoc se questo esiste gia come entita ufficiale. In quel caso FactoryFlow puo conservare solo un riferimento al codice AdHoc e i dati aggiuntivi propri dell'applicazione.

### Valutazione

Mantenerla, ma come tabella anagrafica applicativa snella.

## Decisione Su Macchine

### Scelta

Mantenere come dominio FactoryFlow, con attenzione a non duplicare cespiti o risorse gia ufficiali.

### Database

`DB_FARMFLOW`.

### Motivazione

Le macchine servono a FactoryFlow per operativita di reparto, stati, capacita, fermi, assegnazioni, raccolta tempi e costi industriali. Queste informazioni sono operative e spesso non sono gestite in AdHoc con il livello di dettaglio richiesto da una UI moderna.

### Regola

Se la macchina corrisponde a una risorsa, centro, cespite o ciclo gia presente in AdHoc, FactoryFlow deve conservare il riferimento esterno, non una copia completa dell'anagrafica ufficiale.

### Valutazione

Mantenerla, ma come estensione operativa e non come anagrafica gestionale parallela.

## Decisione Su Associazione Linea-Articoli

### Scelta

Mantenere, ma solo come regola operativa di FactoryFlow.

### Database

`DB_FARMFLOW`.

### Motivazione

L'associazione tra articoli producibili e linee puo servire per filtrare la UI, proporre la linea corretta, evitare errori operativi e alimentare la pianificazione.

Non deve pero duplicare la distinta, il ciclo o l'anagrafica articolo.

### Regola

La tabella deve contenere solo riferimenti al codice articolo AdHoc e alla linea FactoryFlow, piu eventuali preferenze operative come priorita o abilitazione.

### Valutazione

Mantenerla, ma vietare descrizioni articolo, unita di misura, distinta o dati tecnici duplicati.

## Decisione Su Storico Dichiarazioni

### Scelta

Mantenere, ma come audit FactoryFlow, non come documento alternativo.

### Database

`DB_FARMFLOW`.

### Motivazione

Il documento ufficiale di produzione vive in AdHoc. Tuttavia FactoryFlow puo avere bisogno di uno storico proprio per sapere:

- chi ha premuto conferma;
- da quale dispositivo;
- con quali dati iniziali;
- quale risposta ha dato il motore transazionale;
- quali seriali e numeri AdHoc sono stati generati;
- quali errori si sono verificati;
- quanto tempo e durata l'operazione.

Questo e storico applicativo, non duplicazione del documento.

### Regola

Lo storico deve conservare chiavi di collegamento ai documenti AdHoc e metadati FactoryFlow. Non deve diventare una copia completa di `DOC_MAST`.

### Valutazione

Mantenerla, con struttura orientata ad audit e tracciabilita.

## Decisione Su Storico Componenti

### Scelta

Mantenere solo come snapshot operativo della richiesta FactoryFlow.

### Database

`DB_FARMFLOW`.

### Motivazione

Le righe ufficiali sono in AdHoc. Pero FactoryFlow puo dover conservare cio che l'operatore ha inviato alla conferma: quantita effettiva, lotto scelto, disponibilita visualizzata al momento, eventuale modifica rispetto alla proposta.

Questo serve per audit e analisi dell'esperienza operativa, soprattutto se la distinta AdHoc cambia successivamente.

### Regola

Non deve essere usato per calcolare giacenze o ricostruire il documento ufficiale. Deve collegarsi ai seriali e alle righe AdHoc quando disponibili.

### Valutazione

Mantenerla, ma con nome e scopo chiari: storico input FactoryFlow, non dettaglio documento gestionale.

## Decisione Su Storico Costi

### Scelta

Modificare l'idea: separare costi ufficiali da costi industriali calcolati.

### Database

Costi standard ufficiali in AdHoc. Storico costi industriali calcolati in `DB_FARMFLOW`.

### Motivazione

AdHoc resta la fonte ufficiale per costi standard e contabilita. FactoryFlow puo pero calcolare costi industriali effettivi o stimati usando energia, manodopera, setup, tempi macchina e scostamenti.

Questi calcoli non devono sovrascrivere ne duplicare i costi ufficiali. Devono essere storicizzati come analisi FactoryFlow.

### Valutazione

Mantenere solo per analisi FactoryFlow, con chiaro collegamento ai documenti AdHoc e alla versione dei parametri usati.

## Decisione Su Costi Energia

### Scelta

Mantenere in `DB_FARMFLOW` se FactoryFlow deve raccogliere o stimare consumi.

### Database

`DB_FARMFLOW`.

### Motivazione

Il consumo energetico operativo per linea, macchina, turno o produzione non e normalmente parte del documento di magazzino AdHoc. E un dato industriale utile a FactoryFlow.

### Regola

Se il costo energia deriva da contabilita ufficiale o fatture, il valore ufficiale resta nel sistema contabile. FactoryFlow puo conservare parametri operativi, tariffe applicative, consumi stimati o misurati e versioni usate per calcoli.

### Valutazione

Mantenerla come modulo futuro, non necessaria nella prima versione.

## Decisione Su Costi Manodopera

### Scelta

Mantenere in `DB_FARMFLOW` solo per rilevazioni operative e calcoli industriali.

### Database

`DB_FARMFLOW`, con riferimenti esterni se esistono anagrafiche ufficiali del personale.

### Motivazione

FactoryFlow puo rilevare operatori, tempi, squadre, turni e costo industriale stimato. Questo e utile per controllo produzione ma non deve sostituire paghe, presenze o contabilita.

### Regola

Non duplicare anagrafiche dipendenti ufficiali. Conservare solo codici di riferimento e dati operativi necessari.

### Valutazione

Mantenere come estensione futura.

## Decisione Su Costi Setup

### Scelta

Mantenere come dato FactoryFlow, se non governato dai cicli AdHoc.

### Database

`DB_FARMFLOW`, oppure riferimento ad AdHoc se il setup e gia previsto nel ciclo ufficiale.

### Motivazione

Il setup puo essere un dato operativo usato per pianificazione, consuntivazione e costo industriale. Se AdHoc lo gestisce gia nei cicli, FactoryFlow deve leggerlo da li. Se invece FactoryFlow introduce regole piu granulari per reparto, puo mantenerle nel proprio database.

### Valutazione

Modificare la struttura prevista: deve distinguere dato letto da AdHoc, override operativo e consuntivo reale.

## Decisione Su Pianificazione

### Scelta

Mantenere come dominio FactoryFlow futuro, ma non nella prima versione.

### Database

`DB_FARMFLOW`.

### Motivazione

La pianificazione operativa moderna, visuale e mobile e uno dei motivi naturali per cui FactoryFlow puo crescere. AdHoc resta fonte per ordini, articoli, distinte, giacenze e cicli; FactoryFlow puo gestire scenari, sequenze, assegnazioni a linea, stati e simulazioni.

### Regola

La pianificazione FactoryFlow non deve creare una seconda verita sugli ordini o sui fabbisogni ufficiali. Deve riferirsi a dati AdHoc e generare piani operativi.

### Valutazione

Mantenere, ma progettare come modulo separato e disattivabile.

## Decisione Su MRP

### Scelta

Non implementare ora. Progettare solo i confini.

### Database

`DB_FARMFLOW` solo per scenari, risultati di simulazione e parametri applicativi. Fonti ufficiali in AdHoc.

### Motivazione

Un MRP completo rischia di duplicare troppe logiche gestionali. Se FactoryFlow lo introdurra, dovra essere un motore di simulazione e supporto decisionale, non un secondo gestionale ordini.

### Regola

Fabbisogni, giacenze, distinte, ordini e articoli devono arrivare da AdHoc. `DB_FARMFLOW` puo conservare scenari, elaborazioni, esiti, priorita e proposte.

### Valutazione

Rimandare. Ogni tabella MRP definitiva va disegnata solo dopo aver chiarito quali fonti AdHoc saranno usate.

## Decisione Su Calendario Produzione

### Scelta

Mantenere come calendario operativo FactoryFlow, se non esiste gia un calendario AdHoc equivalente.

### Database

`DB_FARMFLOW`, con eventuali riferimenti a calendari AdHoc.

### Motivazione

La UI di reparto e la pianificazione hanno bisogno di giorni lavorativi, turni, chiusure, eccezioni e capacita. Se AdHoc contiene gia queste regole, FactoryFlow deve leggerle. Se non sono disponibili o non sono abbastanza operative, FactoryFlow puo conservarle.

### Regola

Il calendario deve essere chiaramente operativo, non contabile.

### Valutazione

Mantenerla come modulo futuro, legata a linee e macchine.

## Decisione Su Capacita Produttiva

### Scelta

Mantenere in `DB_FARMFLOW` come dato operativo, con riferimento ai cicli AdHoc se presenti.

### Database

`DB_FARMFLOW`.

### Motivazione

La capacita produttiva usata per schedulare e simulare e spesso diversa dal dato tecnico ufficiale. FactoryFlow puo gestire capacita effettive per linea, macchina, turno, articolo o periodo.

### Regola

Non duplicare il ciclo ufficiale. Salvare solo capacita operative, coefficienti, eccezioni o override motivati.

### Valutazione

Mantenerla, ma come estensione della pianificazione e non come anagrafica isolata.

## Decisione Su Costi Industriali

### Scelta

Mantenere come area analitica FactoryFlow.

### Database

`DB_FARMFLOW`.

### Motivazione

I costi industriali effettivi possono combinare dati AdHoc e dati FactoryFlow: componenti consumati, produzione registrata, tempi, energia, manodopera, setup, scarti e fermate.

Il risultato e una vista industriale operativa, non contabilita ufficiale.

### Regola

Ogni costo industriale calcolato deve conservare:

- collegamento al documento AdHoc;
- fonti usate;
- versione dei parametri;
- data del calcolo;
- indicazione se e stima, consuntivo o ricalcolo.

### Valutazione

Mantenere, ma non introdurla finche mancano linee, macchine e rilevazioni reali.

## Decisione Su Storico Modifiche

### Scelta

Mantenere come audit applicativo.

### Database

`DB_FARMFLOW`.

### Motivazione

FactoryFlow deve sapere chi ha modificato configurazioni, piani, capacita, associazioni operative, parametri o dati propri. Questo non e duplicazione di AdHoc: e tracciabilita applicativa.

### Regola

Lo storico modifiche deve riguardare dati FactoryFlow. Le modifiche a dati AdHoc restano tracciate secondo strumenti AdHoc, salvo registrare l'evento applicativo che ha invocato una procedura ufficiale.

### Valutazione

Mantenerla.

## Decisione Su Storico Cancellazioni

### Scelta

Mantenere come audit applicativo e recupero logico.

### Database

`DB_FARMFLOW`.

### Motivazione

Le cancellazioni di configurazioni, pianificazioni, associazioni, parametri e dati operativi FactoryFlow devono essere tracciabili. Per un prodotto destinato a durare anni, cancellare senza memoria e un errore architetturale.

### Regola

Preferire disattivazione o cancellazione logica per entita configurative importanti. La cancellazione fisica va limitata a dati temporanei o tecnici.

### Valutazione

Mantenerla.

## Tabelle Da Evitare

Le seguenti tabelle non devono essere create in `DB_FARMFLOW` come copie di AdHoc:

- articoli FactoryFlow;
- distinte FactoryFlow;
- lotti FactoryFlow;
- giacenze FactoryFlow;
- documenti FactoryFlow equivalenti a `DOC_MAST`;
- righe documento FactoryFlow equivalenti a `DOC_DETT`;
- causali magazzino FactoryFlow;
- tipi documento FactoryFlow;
- clienti FactoryFlow;
- fornitori FactoryFlow;
- costi standard FactoryFlow.

Se servono per visualizzazione o ricerca, devono essere viste o letture da AdHoc, non copie persistenti.

## Tabelle Ammissibili In DB_FARMFLOW

Le tabelle ammissibili sono quelle che rappresentano dati propri di FactoryFlow:

- configurazione applicativa;
- audit applicativo;
- storico richieste e risposte;
- preferenze operative;
- linee operative;
- macchine operative;
- associazioni operative linea-articolo;
- calendari operativi;
- capacita operative;
- piani e scenari;
- risultati di simulazione MRP;
- rilevazioni tempi;
- rilevazioni energia;
- rilevazioni setup;
- calcoli industriali;
- dati temporanei di sessione o lavorazione.

Ogni tabella deve poter rispondere a questa domanda: quale informazione contiene che AdHoc non possiede gia come fonte ufficiale?

Se la risposta non e chiara, la tabella non va creata.

## Riesame Critico Delle Idee Discusse

### Salvare Tipo Documento E Alfanumerico In FF_CONFIG

Decisione: eliminare.

Motivo: tipo documento e alfanumerico sono regole AdHoc. Duplicarle in FactoryFlow genera incoerenza quando AdHoc cambia.

### Salvare Causale Magazzino In FF_CONFIG

Decisione: eliminare.

Motivo: la causale magazzino deriva da `[AZIENDA]TIP_DOCU`. FactoryFlow deve configurare la causale documento da usare, non copiare gli attributi interni del documento.

### Creare Anagrafiche Articolo FactoryFlow

Decisione: eliminare.

Motivo: gli articoli sono ufficialmente in AdHoc. FactoryFlow puo salvare preferenze operative riferite al codice articolo, non una seconda anagrafica.

### Creare Distinte FactoryFlow

Decisione: eliminare.

Motivo: la distinta ufficiale e AdHoc. FactoryFlow deve leggerla, proporla e permettere rettifiche operative al momento della dichiarazione, ma non diventare il gestore delle distinte.

### Creare Tabelle Giacenze O Lotti FactoryFlow

Decisione: eliminare.

Motivo: lotti e giacenze sono ufficiali in AdHoc. FactoryFlow puo mostrarli e puo invocare procedure che li aggiornano, ma non deve mantenere saldi propri.

### Salvare Storico Dichiarazioni FactoryFlow

Decisione: mantenere.

Motivo: serve audit applicativo. Deve contenere solo chiavi, stato, input, esito e riferimenti ai documenti AdHoc.

### Salvare Storico Componenti FactoryFlow

Decisione: mantenere con struttura controllata.

Motivo: serve sapere cosa l'operatore ha scelto al momento della conferma. Non deve sostituire le righe ufficiali AdHoc.

### Introdurre Subito Linee, Macchine E Pianificazione

Decisione: rimandare.

Motivo: sono moduli importanti, ma introdurli troppo presto rischia di irrigidire il modello. Prima serve consolidare dichiarazione produzione e confini con AdHoc.

### Introdurre Subito MRP

Decisione: rimandare in modo netto.

Motivo: MRP e un modulo ad alto rischio di duplicazione gestionale. Va progettato solo come simulazione o supporto operativo basato su fonti AdHoc.

## Architettura A Moduli

FactoryFlow deve crescere per moduli separati.

### Modulo Produzione Base

Responsabilita:

- selezione articolo producibile;
- lettura distinta AdHoc;
- scelta lotti;
- conferma produzione;
- chiamata al motore transazionale ufficiale;
- audit FactoryFlow dell'operazione.

Fonti ufficiali:

- AdHoc per articoli, distinte, documenti, lotti e giacenze.

Database proprio:

- solo configurazione e storico applicativo.

### Modulo Risorse Produttive

Responsabilita:

- linee;
- macchine;
- stati operativi;
- associazioni operative;
- capacita effettiva.

Fonti ufficiali:

- AdHoc per eventuali cicli o centri gia gestiti.

Database proprio:

- dati operativi non presenti o non sufficientemente moderni in AdHoc.

### Modulo Pianificazione

Responsabilita:

- piani di produzione;
- assegnazione a linee;
- sequenze;
- scenari;
- simulazioni.

Fonti ufficiali:

- AdHoc per ordini, articoli, giacenze, distinte e cicli.

Database proprio:

- scenari, piani operativi, priorita, stati e simulazioni.

### Modulo Costi Industriali

Responsabilita:

- consuntivi industriali;
- energia;
- manodopera;
- setup;
- scostamenti.

Fonti ufficiali:

- AdHoc per documenti e costi standard.

Database proprio:

- misure operative, parametri di calcolo, risultati analitici e versioni.

### Modulo Audit

Responsabilita:

- modifiche;
- cancellazioni;
- conferme;
- errori;
- operazioni utente.

Database proprio:

- `DB_FARMFLOW`.

## Regole Di Evoluzione Del Database

Prima di aggiungere una tabella a `DB_FARMFLOW`, verificare:

1. AdHoc possiede gia questa informazione?
2. Se si, FactoryFlow deve solo leggerla?
3. Se si, serve davvero conservarne uno snapshot?
4. Lo snapshot e audit o duplicazione?
5. La tabella contiene una regola ufficiale o una preferenza operativa?
6. Cosa succede se AdHoc cambia il dato?
7. La tabella puo vivere dieci anni senza diventare incoerente?

Se una tabella non supera queste domande, non deve essere creata.

## Conclusione Architetturale

La direzione corretta e un FactoryFlow leggero, operativo e integrato.

AdHoc resta il proprietario della verita gestionale.

`DB_FARMFLOW` deve contenere solo cio che permette a FactoryFlow di offrire un'esperienza moderna: configurazione, audit, dati operativi, pianificazione, rilevazioni e analisi industriali.

Le idee piu rischiose da eliminare subito sono:

- duplicare tipi documento e alfanumerici;
- duplicare causali magazzino e segni;
- creare copie di articoli, distinte, lotti o giacenze;
- costruire un MRP indipendente da AdHoc;
- trasformare lo storico FactoryFlow in un secondo documento gestionale.

Questa separazione e la condizione principale per mantenere FactoryFlow stabile, estendibile e coerente nel tempo.

