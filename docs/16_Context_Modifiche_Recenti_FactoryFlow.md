# FactoryFlow - Contesto modifiche recenti

Documento di passaggio contesto per ChatGPT o per un tecnico che deve proseguire il lavoro su FactoryFlow.

Questo documento riassume le modifiche richieste e realizzate nelle ultime sessioni operative, soprattutto quelle introdotte rapidamente durante collaudo, installazione e affinamento UI.

## Premessa

FactoryFlow e' una piattaforma MES che estende AdHoc senza sostituirlo.

AdHoc resta il sistema ufficiale per:

- articoli;
- distinte;
- documenti;
- magazzino;
- lotti;
- progressivi;
- causali;
- saldi ufficiali.

DB_FARMFLOW contiene solo dati propri FactoryFlow:

- configurazioni operative;
- linee produzione;
- associazioni linea-articolo;
- dichiarazioni FactoryFlow;
- componenti dichiarazione;
- audit;
- pianificazioni e previsioni operative.

La stored procedure AdHoc resta il motore ufficiale per la registrazione reale di produzione quando una dichiarazione deve diventare documento AdHoc.

## Modifica principale: dichiarazioni PREVISTE

E' stata introdotta la distinzione tra dichiarazione di produzione confermata e dichiarazione prevista.

### Regola funzionale

Se l'operatore inserisce una dichiarazione con data successiva alla data odierna:

- la dichiarazione viene salvata solo in DB_FARMFLOW;
- lo stato viene impostato a `PREVISTA`;
- non viene chiamata la stored procedure AdHoc;
- non vengono creati documenti AdHoc;
- non vengono aggiornati DOC_MAST, DOC_DETT o SALDILOT;
- i seriali AdHoc restano nulli.

La discriminante fondamentale e' l'assenza dei seriali AdHoc nella registrazione FactoryFlow.

Una dichiarazione `PREVISTA` diventa registrazione reale solo quando:

- la data di sistema coincide con la data produzione della dichiarazione;
- l'operatore apre la dichiarazione;
- l'operatore conferma quantita' e lotti;
- l'operatore preme il comando esplicito `Conferma produzione`.

Solo in quel momento il backend chiama la stored procedure ufficiale e aggiorna la registrazione FactoryFlow a `CONFERMATA` salvando i seriali/numero dei documenti AdHoc.

### Motivazione architetturale

Una produzione futura non e' ancora un fatto contabile o di magazzino.

Quindi non deve vivere in AdHoc come documento reale finche' non viene confermata dall'operatore nel giorno operativo.

La previsione appartiene a FactoryFlow perche' e' un dato operativo MES, non un documento ERP.

## Stati dichiarazione

La tabella delle dichiarazioni FactoryFlow usa il campo `Stato`.

Gli stati attualmente usati sono:

- `PREVISTA`: dichiarazione futura salvata solo in FactoryFlow, senza seriali AdHoc;
- `CONFERMATA`: dichiarazione registrata anche in AdHoc, con seriali documenti valorizzati;
- `ANNULLATA`: dichiarazione cancellata logicamente da FactoryFlow.

La cancellazione non elimina fisicamente la riga dal database.

La scelta e' voluta: lo storico produttivo non deve sparire, soprattutto se in futuro servira' per audit, analisi, costi e tracciabilita'.

## Calendario come pagina principale

La pagina principale dell'app non e' piu' la maschera diretta di dichiarazione.

La pagina principale e' il calendario dichiarazioni, coerente con l'impostazione gia' usata nel progetto Cantieri.

### Layout calendario

Il calendario mostra:

- esercizio/anno in testa;
- selezione mese;
- griglia giorni del mese;
- badge con numero dichiarazioni presenti per giorno;
- elenco delle dichiarazioni del giorno selezionato sotto la griglia;
- dettaglio/modifica della dichiarazione selezionata.

Su desktop il layout e' master-detail:

- calendario ed elenco dichiarazioni a sinistra;
- dettaglio dichiarazione a destra.

Su mobile/tablet il layout diventa verticale e scrollabile.

## Elenco dichiarazioni sotto calendario

Sotto il calendario compare l'elenco delle dichiarazioni del giorno selezionato.

Ogni elemento mostra:

- articolo prodotto;
- descrizione;
- quantita';
- lotto prodotto;
- linea produzione associata;
- stato della dichiarazione.

E' stata aggiunta l'indicazione della linea di produzione nell'elenco, perche' senza questo dato l'operatore non riusciva a distinguere facilmente produzioni simili fatte su linee diverse.

## Inserimento nuova dichiarazione dal calendario

Il pulsante `Nuova` nel calendario apre la pagina di dichiarazione produzione usando come data iniziale il giorno selezionato nel calendario.

Questa scelta e' importante per la logica delle previsioni:

- se l'operatore seleziona un giorno futuro e preme `Nuova`, la dichiarazione nasce con quella data futura;
- il pulsante della maschera cambia significato in `Salva previsione`;
- il backend salva la registrazione come `PREVISTA` senza scrivere su AdHoc.

Se invece la data e' odierna o passata, il flusso resta quello di conferma produzione reale.

## Conferma delle previsioni

Nel dettaglio di una dichiarazione `PREVISTA` compare il pulsante:

`Conferma produzione`

Il pulsante e' disponibile solo quando:

- lo stato e' `PREVISTA`;
- i seriali AdHoc sono assenti;
- la data della dichiarazione coincide con la data odierna.

Prima della conferma l'operatore puo' modificare:

- quantita' prodotta;
- lotto prodotto finito;
- magazzino PF;
- quantita' effettive dei componenti;
- lotti dei componenti gestiti a lotto;
- magazzini componenti.

Alla conferma:

- il backend salva le ultime modifiche in DB_FARMFLOW;
- chiama la stored procedure ufficiale;
- crea i documenti AdHoc;
- aggiorna SALDILOT tramite la logica gia' validata nella stored;
- aggiorna lo stato a `CONFERMATA`;
- salva i seriali/numero carico e scarico in DB_FARMFLOW;
- scrive audit evento.

## Modifica e cancellazione dichiarazioni previste

Le dichiarazioni `PREVISTA` possono essere modificate o cancellate senza toccare AdHoc.

La logica backend e' stata adeguata affinche':

- se mancano i seriali AdHoc, l'allineamento AdHoc viene saltato;
- la modifica resta interna a DB_FARMFLOW;
- la cancellazione imposta lo stato `ANNULLATA` in FactoryFlow;
- non vengono cercati documenti AdHoc inesistenti.

Questo evita errori su previsioni non ancora trasformate in registrazioni ERP.

## Miglioria UI assegnazione articoli-linea

La gestione dell'associazione articoli a linea di produzione e' stata ripensata in forma master-detail.

### Prima

La pagina era poco intuitiva: l'utente vedeva una gestione troppo piatta e poco chiara.

### Dopo

All'apertura viene mostrato l'elenco delle linee di produzione.

Su desktop:

- codice e descrizione linea appaiono in riga;
- il pulsante `+` e' collocato in posizione comoda per aggiungere una linea.

Su mobile:

- le informazioni sono impilate;
- il pulsante `+` e' piu' adatto al layout touch.

Quando si seleziona una linea:

- si apre il master della linea;
- sotto compare l'elenco degli articoli associati;
- gli articoli possono essere modificati o rimossi;
- un pulsante `+` consente di aggiungere nuovi articoli alla linea.

## Flag attivo sulle linee produzione

Nel master della linea e' presente il flag `Attiva`.

Una linea dismessa non deve essere cancellata fisicamente, perche':

- le dichiarazioni storiche devono continuare a mostrare la linea corretta;
- analisi e report futuri devono poter leggere il passato;
- la cancellazione romperebbe il significato storico dei dati.

Una linea non piu' usata va quindi disattivata, non eliminata.

## Cambio dicitura menu

La voce di menu `Storico` e' stata rinominata in:

`Calendario dichiarazioni`

Motivazione: la pagina non e' solo uno storico, ma il punto principale di lavoro operativo, consultazione e inserimento nuove dichiarazioni.

## Calendario come default all'ingresso

L'app apre direttamente la pagina `Calendario dichiarazioni`.

Motivazione: per un operatore di produzione il calendario e' il punto naturale da cui capire:

- cosa e' stato fatto oggi;
- cosa e' previsto nei prossimi giorni;
- quali dichiarazioni sono da completare;
- quali dichiarazioni sono gia' confermate.

## Migliorie UI dichiarazione produzione

La UI della dichiarazione produzione e' stata resa piu' gestionale e responsive.

Sono state aggiunte o migliorate:

- testata piu' leggibile;
- campo articolo largo;
- quantita' prodotta piu' evidente;
- magazzino PF;
- lotto prodotto;
- data produzione;
- pulsante conferma ben visibile;
- distinzione desktop/tablet/mobile;
- tabella componenti su desktop;
- card componenti su mobile;
- niente scroll orizzontale su mobile;
- spinner durante caricamento distinta;
- pulsante disabilitato durante conferma;
- snackbar di esito positivo/errore.

Le colonne quantita' sono state rinominate:

- `Qta distinta` diventa `Distinta`;
- `Qta proposta` diventa `Proposta`;
- `Qta da scaricare` diventa `Effettiva`.

## Evidenza lotti e disponibilita'

Per i componenti gestiti a lotto:

- viene mostrato il badge `LOTTO`;
- viene mostrata la combo lotti;
- la combo mostra codice lotto, disponibilita' e scadenza;
- alla selezione lotto vengono aggiornate disponibilita' e scadenza in riga.

La disponibilita' lotto viene colorata:

- verde se sufficiente;
- arancione se positiva ma inferiore alla quantita' richiesta;
- rosso se zero o non disponibile.

Per i componenti non gestiti a lotto il campo lotto non deve essere visibile.

## Correzioni overflow e scroll

Sono stati corretti diversi problemi UI:

- overflow nei campi del dettaglio dichiarazione;
- campo lotto troppo stretto;
- impossibilita' di scorrere l'elenco dichiarazioni su desktop;
- riquadri gialli/neri di overflow Flutter;
- pagina bianca dovuta a errori runtime Flutter;
- gestione piu' solida degli scroll nei pannelli desktop.

## Backend: endpoint previsione

E' stato aggiunto un endpoint backend per trasformare una previsione in produzione confermata:

`POST /api/produzione/dichiarazioni/{id}/conferma`

Questo endpoint:

- carica la dichiarazione da DB_FARMFLOW;
- verifica che sia `PREVISTA`;
- verifica che non abbia seriali AdHoc;
- verifica che la data coincida con oggi;
- ricostruisce la richiesta per la stored procedure;
- chiama la stored procedure;
- aggiorna la dichiarazione a `CONFERMATA`;
- salva seriali e numeri documenti;
- scrive audit.

## Backend: salvataggio dichiarazioni future

Il normale endpoint di inserimento dichiarazione e' stato modificato.

Se `DataProduzione > oggi`:

- salva storico FactoryFlow con stato `PREVISTA`;
- non chiama la stored procedure;
- restituisce messaggio di previsione salvata.

Se `DataProduzione <= oggi`:

- mantiene il comportamento precedente;
- chiama la stored procedure;
- salva storico con stato `CONFERMATA`.

## Packaging e installazione cliente

Durante l'installazione su server cliente e' emerso che il server aveva installato solo .NET 8.

Il backend era inizialmente compilato per .NET 10, quindi e' stato portato a:

`net8.0`

Motivazione: .NET 8 e' una scelta piu' adatta a installazioni cliente perche' LTS e gia' presente sul server.

Sono stati aggiornati i progetti backend:

- FactoryFlow.Api;
- FactoryFlow.Core;
- FactoryFlow.Infrastructure.

## Supporto Windows Service

Il backend e' stato aggiornato per supportare correttamente l'esecuzione come servizio Windows.

E' stata aggiunta la configurazione applicativa per Windows Service.

Motivazione: avviare una Web API ASP.NET Core come servizio Windows richiede che l'app si agganci correttamente al Service Control Manager.

Il servizio cliente e' stato configurato per avviare l'eseguibile pubblicato:

`FactoryFlow.Api.exe`

non il solo DLL tramite `dotnet`.

## Configurazione cliente LACOM

Per l'ambiente cliente sono stati usati questi riferimenti:

- server SQL: `SERVER\\WINCC`;
- database AdHoc: `DB_AHR`;
- database FactoryFlow: `DB_TEST`;
- azienda: `LACOM`;
- esercizio: `2026`;
- magazzino default: `01`.

La configurazione attiva in DB_FARMFLOW risulta:

- `CodAziAdhoc = LACOM`;
- `PrefissoAzienda = LACOM`;
- `CausaleCarico = PRDIC`;
- `CausaleScarico = PRSCC`;
- `MagazzinoPFDefault = 01`;
- `MagazzinoComponentiDefault = 01`.

## Frontend Flutter Web cliente

Il frontend Flutter Web deve essere compilato con l'indirizzo reale del backend.

Per il cliente e' stato individuato l'IP server:

`192.168.1.200`

Quindi il frontend va compilato con:

`BASE_URL=http://192.168.1.200:5100`

Parametri usati:

- `BASE_URL=http://192.168.1.200:5100`;
- `COD_AZI=LACOM`;
- `ESERCIZIO=2026`;
- `MAGAZZINO_DEFAULT=01`.

Il frontend puo' essere pubblicato in IIS con sito dedicato, porta consigliata `5200`, cartella fisica ad esempio:

`C:\test\farm\frontend`

oppure:

`C:\inetpub\testfarm`

Nella cartella fisica deve trovarsi direttamente `index.html`, non una sottocartella `web`.

## Porte operative

Durante il collaudo sono state usate:

- backend: `5100`;
- frontend: `5200`.

URL backend:

`http://192.168.1.200:5100`

URL frontend:

`http://192.168.1.200:5200`

## Regole importanti da mantenere

1. Una previsione futura non deve creare documenti AdHoc.
2. La presenza dei seriali AdHoc indica che la dichiarazione e' gia' stata confermata in ERP.
3. Una dichiarazione senza seriali AdHoc e in stato `PREVISTA` vive solo in FactoryFlow.
4. La cancellazione deve essere logica, non fisica.
5. Linee dismesse vanno disattivate, non cancellate.
6. La pagina principale deve restare il calendario dichiarazioni.
7. AdHoc resta il sistema ufficiale per documenti, lotti, magazzino e saldi.
8. DB_FARMFLOW non deve duplicare dati gia' governati da AdHoc.
9. Ogni nuova informazione deve essere valutata chiedendosi se appartiene ad AdHoc, a DB_FARMFLOW o se non deve essere salvata.

## Stato finale dopo queste modifiche

Il sistema dispone di:

- backend ASP.NET Core compatibile .NET 8;
- backend installabile come servizio Windows;
- frontend Flutter Web compilabile con parametri cliente;
- calendario dichiarazioni come pagina principale;
- gestione dichiarazioni previste;
- conferma differita delle previsioni;
- associazione articoli-linea piu' usabile;
- UI piu' responsive e piu' adatta a reparto;
- logica coerente con il principio FactoryFlow estende AdHoc senza duplicarlo.

## Prossimi punti consigliati

- Collaudare da client reale in rete.
- Verificare `GET /api/produzione/articoli` su azienda LACOM.
- Verificare caricamento distinta reale.
- Inserire una dichiarazione futura e verificare stato `PREVISTA`.
- Confermare una dichiarazione odierna e verificare DOC_MAST, DOC_DETT e SALDILOT.
- Aggiornare una checklist ufficiale di deploy cliente.
- Valutare autenticazione e gestione utenti solo dopo aver stabilizzato il flusso MVP.

## Modifiche Recenti - Orari Evento E Produttivita

Sono stati introdotti in `FF_DICHIARAZIONI_PRODUZIONE` gli orari dell'evento produttivo:

- `OraInizioProduzione`;
- `OraFineProduzione`.

Questi dati non appartengono ad AdHoc: descrivono il tempo operativo reale o previsto della dichiarazione FactoryFlow. Sono necessari per misurare la resa produttiva.

FactoryFlow calcola ora anche la produttivita al minuto:

- resa corrente durante l'inserimento dichiarazione;
- media storica dell'articolo, opzionalmente filtrata per linea;
- scostamento percentuale rispetto alla media;
- evidenza rossa quando lo scostamento supera il 20%.

La media usa solo dichiarazioni `CONFERMATA` con orari validi. Le `PREVISTA` restano escluse fino alla conferma, per non alterare le statistiche reali con dati pianificati.
