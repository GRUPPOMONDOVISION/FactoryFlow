# ADR-0007
# Il Processo Produttivo Non Appartiene All'Articolo

## Stato

★★★★★

Decisione architetturale fondativa del modello process-centric.

---

## Contesto

FactoryFlow sta evolvendo da MVP di dichiarazione produzione a piattaforma MES.

Il primo MVP ha correttamente risolto il problema operativo piu urgente: registrare una produzione, generare documenti AdHoc, movimentare lotti e salvare lo storico FactoryFlow.

Durante l'evoluzione process-centric e emerso un rischio: modellare il Processo Produttivo come se appartenesse sempre a un Prodotto Finito o a un Articolo AdHoc.

Questa scelta sarebbe comoda per il caso minimo, ma sbagliata per il dominio industriale completo.

---

## Problema

Una fabbrica non esegue solo attivita che producono immediatamente un articolo.

Esegue anche:

- preparazioni macchina;
- setup;
- pulizie;
- cambi formato;
- controlli qualita;
- miscelazioni intermedie;
- fasi senza effetto magazzino;
- attivita di supporto;
- fasi che producono semilavorati;
- fasi che generano documenti ERP.

Se il Processo Produttivo viene legato obbligatoriamente all'articolo, FactoryFlow non riesce piu a descrivere correttamente queste attivita.

Il risultato sarebbe un modello fragile, troppo vicino alla distinta o al documento ERP e troppo lontano dal lavoro reale della fabbrica.

---

## Decisione

Il Processo Produttivo rappresenta un percorso operativo.

Non appartiene obbligatoriamente a un Prodotto Finito.

Non appartiene obbligatoriamente a un Articolo AdHoc.

Il modello corretto e:

```text
Processo Produttivo
  -> Versione Processo
  -> Fasi Processo
  -> Attivita di calendario
  -> Chiusura fase / consuntivo fase
  -> eventuale Documento ERP AdHoc
```

Ogni fase dichiara quali dati sono obbligatori alla chiusura.

L'articolo prodotto viene richiesto solo nella chiusura della fase che produce un articolo.

Il documento ERP AdHoc viene generato solo se la fase prevede un effetto gestionale.

---

## Motivazione

Questa decisione protegge FactoryFlow da un errore strutturale.

Il dominio MES deve descrivere il lavoro reale, non solo il risultato ERP.

AdHoc resta fonte ufficiale di articoli, distinte, documenti, lotti e giacenze.

FactoryFlow deve descrivere come la fabbrica lavora: fasi, tempi, risorse, team, setup, energia, qualita, consuntivi e decisioni.

Il punto di incontro tra FactoryFlow e AdHoc non e il processo.

Il punto di incontro e la fase che genera effetto ERP.

---

## Alternative Valutate

### Processo per articolo

Scartata.

Funziona nel caso minimo, ma non descrive fasi senza produzione materiale e rende difficile gestire processi condivisi o multi-fase.

### Processo per distinta

Scartata.

La distinta appartiene ad AdHoc e descrive materiali teorici. Non descrive tempi, setup, macchina, team, energia, qualita e costo operativo.

### Dichiarazione fine processo monolitica

Scartata come modello definitivo.

Una dichiarazione unica di fine processo non distingue correttamente le fasi e obbliga a raccogliere dati non sempre pertinenti.

### Chiusura fase

Scelta.

Permette di raccogliere solo i dati richiesti dalla fase, generare ERP solo quando serve e mantenere compatibile il vecchio MVP a fase unica.

---

## Conseguenze Positive

- Il modello descrive sia PMI semplici sia industrie complesse.
- Le fasi senza ERP diventano rappresentabili.
- Il prodotto finito resta dato AdHoc e non viene duplicato.
- La stored AdHoc resta invariata e viene chiamata solo quando serve.
- Il vecchio MVP resta compatibile come fase unica con effetto ERP.
- I costi possono essere misurati nel punto corretto: la chiusura fase.
- La qualita, il setup e le attivita ausiliarie trovano un posto naturale nel modello.

---

## Conseguenze Negative

- Il modello e piu espressivo e richiede maggiore disciplina.
- La UI deve guidare meglio l'utente nella configurazione delle fasi.
- Alcune strutture nate attorno alla dichiarazione produzione dovranno essere riallineate progressivamente.
- Le API future dovranno mantenere compatibilita con il MVP senza consolidare il vecchio modello.

---

## Livello Di Stabilita

★★★★★

Questa decisione deve essere considerata stabile.

Puo evolvere nei dettagli implementativi, ma non deve essere ribaltata senza ridefinire l'intero modello MES di FactoryFlow.
