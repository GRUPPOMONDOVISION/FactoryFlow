# Dettaglio Modifiche Recenti - Orari Evento E Produttivita

Questo documento riassume le ultime due modifiche introdotte in FactoryFlow, pensate per rafforzare la lettura operativa della produzione senza duplicare dati AdHoc.

## 1. Orari Inizio/Fine Evento Produttivo

### Esigenza

La sola data produzione non era sufficiente per descrivere l'evento produttivo.

Per capire quanto tempo e stato necessario per produrre una certa quantita, FactoryFlow deve conoscere:

- ora inizio produzione;
- ora fine produzione.

Queste informazioni non esistono in AdHoc e appartengono al dominio MES/FactoryFlow.

### Scelta Architetturale

Gli orari sono stati aggiunti a `DB_FARMFLOW`, nella tabella:

`FF_DICHIARAZIONI_PRODUZIONE`

Campi:

- `OraInizioProduzione`;
- `OraFineProduzione`.

Non sono stati aggiunti ad AdHoc.
Non sono stati passati alla stored procedure documentale.
Non sono stati duplicati nei documenti ERP.

### Regole

- Gli orari sono obbligatori per nuove dichiarazioni e conferme.
- `OraFineProduzione` deve essere successiva a `OraInizioProduzione`.
- Le dichiarazioni storiche gia presenti possono avere temporaneamente valori nulli per compatibilita.
- Le dichiarazioni `PREVISTA` possono contenere orari previsti.
- Alla conferma, gli stessi orari diventano parte dello storico operativo reale.

### UI

Nella schermata Dichiarazione Produzione sono stati aggiunti i campi:

- Ora inizio;
- Ora fine.

Nella scheda di modifica da calendario gli stessi campi sono visibili e modificabili.

## 2. Produttivita Al Minuto E Media Produttiva

### Esigenza

Dopo aver inserito quantita prodotta e orari, FactoryFlow deve calcolare la resa produttiva:

`quantita prodotta / minuti produzione`

Questo consente di capire se una dichiarazione e coerente con il comportamento medio dell'articolo.

### Scelta Architetturale

La produttivita al minuto non viene salvata come colonna autonoma.

Motivo: e un dato calcolato da informazioni gia presenti in FactoryFlow:

- quantita prodotta;
- ora inizio;
- ora fine.

Salvare anche il valore calcolato creerebbe duplicazione e rischio di incoerenza dopo modifiche successive.

### API

E stata aggiunta una lettura della produttivita media articolo:

`GET /api/produzione/articoli/{codArticolo}/produttivita?idLinea=...`

La media viene calcolata usando solo dichiarazioni:

- in stato `CONFERMATA`;
- con orari valorizzati;
- con durata positiva;
- con quantita prodotta maggiore di zero.

Se la linea e selezionata, la media viene calcolata per articolo su quella linea.

### UI Inserimento

Quando l'operatore seleziona un articolo producibile, FactoryFlow mostra:

- media storica in pezzi/minuto;
- numero dichiarazioni usate per la media;
- resa corrente della dichiarazione in compilazione;
- scostamento percentuale rispetto alla media.

Se lo scostamento supera il 20%, il dato viene evidenziato in rosso.

### UI Calendario/Storico

Nell'elenco delle dichiarazioni:

- viene mostrata la resa al minuto della singola dichiarazione, quando calcolabile;
- la quantita prodotta viene colorata in rosso se la produttivita si discosta oltre il 20% dalla media dell'articolo.

Nella scheda di modifica:

- il campo quantita prodotta viene evidenziato in rosso se la dichiarazione risulta anomala rispetto alla media.

## Cosa Non E Stato Fatto

Non e stata modificata la stored procedure AdHoc.

Non sono stati modificati DOC_MAST o DOC_DETT per salvare gli orari.

Non e stata creata una nuova tabella per statistiche produttive.

Non e stato salvato un valore statico di produttivita al minuto.

## Principio Architetturale Confermato

FactoryFlow salva i dati operativi che AdHoc non possiede.

FactoryFlow calcola gli indicatori quando derivabili dai dati operativi.

AdHoc resta il sistema ufficiale per documenti, articoli, lotti, magazzino e saldi.

FactoryFlow diventa il sistema che interpreta il lavoro produttivo e aiuta l'azienda a capire se sta producendo bene.
