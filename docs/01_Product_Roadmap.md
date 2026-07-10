# FactoryFlow - Product Roadmap

## Scopo Del Documento

FactoryFlow ha raggiunto una maturitÃ  architetturale sufficiente per essere guidato da una visione di prodotto, non da singole richieste funzionali.

Questo documento descrive come FactoryFlow potrÃ  crescere nei prossimi anni attraverso livelli progressivi di maturitÃ .

Un livello di maturità misura la capacità del prodotto di generare valore stabile per l'azienda.

Ogni livello deve rispettare la filosofia FactoryFlow:

- AdHoc rimane la fonte ufficiale dei dati ERP;
- FactoryFlow estende AdHoc senza duplicarlo;
- ogni dato salvato deve avere uno scopo;
- ogni modulo deve preparare il prodotto a decisioni migliori.

## Livello 1 - Dichiarazione Produzione Affidabile

### Problema Risolto

L'azienda ha bisogno di registrare la produzione in modo semplice, veloce e coerente con AdHoc.

L'operatore deve poter dichiarare prodotto finito, componenti e lotti senza entrare nella complessitÃ  gestionale completa dell'ERP.

### Valore Per L'Azienda

La produzione viene registrata direttamente nel sistema ufficiale, riducendo errori manuali, passaggi doppi e ambiguitÃ  tra reparto e amministrazione.

L'azienda ottiene un flusso operativo piÃ¹ chiaro: ciÃ² che accade in reparto produce documenti e movimenti coerenti in AdHoc.

### Moduli Introdotti

- dichiarazione produzione;
- selezione articolo producibile;
- lettura distinta da AdHoc;
- gestione componenti;
- gestione lotti;
- conferma produzione;
- storico applicativo FactoryFlow;
- audit minimo.

### Dipendenze

- AdHoc per articoli, distinte, documenti, magazzino e lotti;
- motore transazionale validato;
- configurazione FactoryFlow minima.

### Cosa Diventa Possibile Dopo

Diventa possibile costruire una base storica affidabile delle registrazioni FactoryFlow.

Questa base permette di analizzare come gli operatori dichiarano la produzione, quali componenti vengono modificati, quali lotti vengono scelti e quali errori operativi ricorrono.

## Livello 2 - TracciabilitÃ  Operativa

### Problema Risolto

Registrare un documento non basta. L'azienda deve sapere chi ha fatto cosa, quando, da dove e con quali scelte operative.

La tracciabilitÃ  non deve duplicare AdHoc, ma spiegare l'uso di FactoryFlow.

### Valore Per L'Azienda

Il responsabile produzione puÃ² ricostruire il percorso di una dichiarazione: operatore, dispositivo, articolo, quantitÃ , lotti scelti, componenti modificati, esito della registrazione.

Questo migliora controllo, qualitÃ  interna e capacitÃ  di risolvere anomalie.

### Moduli Introdotti

- storico dichiarazioni FactoryFlow;
- storico componenti dichiarati;
- audit modifiche;
- audit cancellazioni;
- stati applicativi controllati.

### Dipendenze

- Livello 1;
- modello dati `DB_FARMFLOW` minimo;
- regole chiare sui dati da salvare come snapshot.

### Cosa Diventa Possibile Dopo

Diventa possibile distinguere il dato ufficiale AdHoc dal comportamento operativo osservato in FactoryFlow.

Questa distinzione abilita analisi su errori ricorrenti, rettifiche frequenti, lotti problematici e differenze tra distinta teorica e consumo effettivo.

## Livello 3 - Risorse Produttive

### Problema Risolto

La produzione non avviene in astratto. Avviene su linee, macchine, reparti e risorse operative.

AdHoc puÃ² contenere cicli o centri ufficiali, ma FactoryFlow deve rappresentare il modo in cui la fabbrica lavora realmente ogni giorno.

### Valore Per L'Azienda

L'azienda inizia a collegare le dichiarazioni produttive alle risorse che le hanno rese possibili.

Questo permette di capire dove si produce, quali linee sono usate, quali macchine sono coinvolte e quali aree richiedono attenzione.

### Moduli Introdotti

- linee operative;
- macchine operative;
- associazione linea-articolo;
- stati operativi di linea e macchina;
- regole operative di abilitazione.

### Dipendenze

- Livello 1;
- Livello 2;
- verifica di eventuali cicli o centri giÃ  presenti in AdHoc.

### Cosa Diventa Possibile Dopo

Diventa possibile pianificare non solo cosa produrre, ma dove produrlo.

Si prepara il terreno per capacitÃ  produttiva, calendari, sequenze e analisi di efficienza.

## Livello 4 - Calendario E CapacitÃ  Produttiva

### Problema Risolto

Sapere che una linea esiste non basta. L'azienda deve sapere quando Ã¨ disponibile e quanto puÃ² produrre.

Senza calendario e capacitÃ , la pianificazione resta una lista di intenzioni.

### Valore Per L'Azienda

Il responsabile produzione puÃ² ragionare su disponibilitÃ  reale: turni, chiusure, eccezioni, capacitÃ  teorica, capacitÃ  effettiva e vincoli operativi.

La fabbrica diventa piÃ¹ leggibile e piÃ¹ prevedibile.

### Moduli Introdotti

- calendari produttivi;
- giorni e turni operativi;
- capacitÃ  per linea;
- capacitÃ  per macchina;
- capacitÃ  per articolo;
- coefficienti di efficienza;
- eccezioni operative.

### Dipendenze

- Livello 3;
- regole aziendali su turni e disponibilitÃ ;
- eventuali calendari o cicli ufficiali AdHoc da rispettare.

### Cosa Diventa Possibile Dopo

Diventa possibile costruire piani produttivi realistici.

FactoryFlow puÃ² iniziare a confrontare fabbisogni, risorse disponibili e capacitÃ  reale.

## Livello 5 - Pianificazione Operativa

### Problema Risolto

La produzione ha bisogno di una visione organizzata: cosa produrre, quando produrlo, su quale linea e con quale prioritÃ .

L'ERP conserva la veritÃ  gestionale. FactoryFlow deve trasformarla in una pianificazione utilizzabile dal reparto.

### Valore Per L'Azienda

L'azienda passa da registrare ciÃ² che Ã¨ giÃ  avvenuto a guidare ciÃ² che deve avvenire.

Il reparto puÃ² lavorare con sequenze piÃ¹ chiare, prioritÃ  piÃ¹ leggibili e assegnazioni coerenti con la capacitÃ  disponibile.

### Moduli Introdotti

- piani di produzione;
- righe piano;
- assegnazione a linee;
- assegnazione a macchine;
- prioritÃ  operative;
- stati di avanzamento piano;
- confronto tra pianificato e dichiarato.

### Dipendenze

- Livello 1;
- Livello 2;
- Livello 3;
- Livello 4.

### Cosa Diventa Possibile Dopo

Diventa possibile misurare lo scostamento tra piano e realtÃ .

Questo apre la strada a simulazioni, capacitÃ  residua, colli di bottiglia e suggerimenti automatici.

## Livello 6 - Rilevazioni Di Reparto

### Problema Risolto

La dichiarazione di produzione racconta cosa Ã¨ stato prodotto. Non racconta sempre quanto tempo Ã¨ servito, quanta energia Ã¨ stata consumata, dove si Ã¨ perso tempo o quali setup hanno inciso.

Per migliorare la fabbrica servono dati operativi piÃ¹ vicini al processo reale.

### Valore Per L'Azienda

L'azienda inizia a misurare il lavoro produttivo in modo piÃ¹ completo: tempi, setup, fermi, consumi, anomalie e attivitÃ  operative.

Questi dati permettono di passare dalla semplice registrazione alla comprensione del processo.

### Moduli Introdotti

- rilevazioni tempi;
- rilevazioni setup;
- rilevazioni fermi;
- rilevazioni energia;
- collegamento rilevazioni-produzione;
- collegamento rilevazioni-linea/macchina.

### Dipendenze

- Livello 3;
- Livello 4;
- Livello 5 se le rilevazioni devono essere confrontate con il piano.

### Cosa Diventa Possibile Dopo

Diventa possibile calcolare costi industriali piÃ¹ realistici e identificare sprechi, inefficienze e aree di miglioramento.

## Livello 7 - Costi Industriali

### Problema Risolto

I costi standard e la contabilitÃ  ufficiale restano in AdHoc. Ma la fabbrica ha bisogno anche di una lettura industriale: quanto Ã¨ costato produrre davvero, secondo i dati operativi disponibili.

### Valore Per L'Azienda

FactoryFlow puÃ² offrire una fotografia dei costi calcolati al momento della produzione: materiali, energia, manodopera, setup e scostamenti.

Non sostituisce la contabilitÃ . Aiuta perÃ² a capire meglio la marginalitÃ  industriale e le cause operative dei costi.

### Moduli Introdotti

- calcolo costo produzione;
- dettaglio componenti costo;
- versioni parametri di calcolo;
- confronto tra costo teorico e costo operativo;
- storico fotografie costo.

### Dipendenze

- Livello 1;
- Livello 2;
- Livello 6;
- dati ufficiali AdHoc per documenti e costi standard.

### Cosa Diventa Possibile Dopo

Diventa possibile valutare produzioni, articoli, linee e macchine anche dal punto di vista economico-operativo.

La pianificazione potrÃ  considerare non solo tempi e capacitÃ , ma anche impatto industriale.

## Livello 8 - Simulazioni E MRP Operativo

### Problema Risolto

L'azienda deve poter ragionare sul futuro: cosa manca, cosa si puÃ² produrre, quali componenti creano vincoli, quali risorse diventano critiche.

Un MRP operativo non deve diventare un secondo ERP. Deve essere uno strumento di simulazione basato su dati ufficiali AdHoc e dati operativi FactoryFlow.

### Valore Per L'Azienda

FactoryFlow puÃ² aiutare a valutare scenari prima di agire: fabbisogni, disponibilitÃ , capacitÃ , prioritÃ  e possibili criticitÃ .

La decisione diventa piÃ¹ informata e meno reattiva.

### Moduli Introdotti

- scenari di simulazione;
- risultati simulazione;
- proposte operative;
- criticitÃ  materiali;
- criticitÃ  capacitÃ ;
- simulazione MRP;
- generazione proposta piano.

### Dipendenze

- Livello 1;
- Livello 3;
- Livello 4;
- Livello 5;
- dati AdHoc per articoli, distinte, giacenze, ordini e fabbisogni.

### Cosa Diventa Possibile Dopo

Diventa possibile passare da un sistema che registra e pianifica a un sistema che suggerisce.

FactoryFlow inizia a diventare una piattaforma decisionale.

## Livello 9 - Dashboard Direzionali E Monitoraggio

### Problema Risolto

I dati di produzione, pianificazione, capacitÃ , costi e simulazioni hanno valore solo se diventano leggibili.

Le persone devono poter vedere rapidamente cosa sta andando bene, cosa richiede attenzione e dove intervenire.

### Valore Per L'Azienda

FactoryFlow offre una vista chiara della fabbrica: produzioni, ritardi, saturazione, consumi, costi, anomalie e scostamenti.

La direzione puÃ² prendere decisioni con informazioni piÃ¹ vicine alla realtÃ  operativa.

### Moduli Introdotti

- dashboard produzione;
- dashboard capacitÃ ;
- dashboard costi;
- dashboard pianificazione;
- indicatori operativi;
- alert e soglie;
- monitoraggio reparto.

### Dipendenze

- Livello 2;
- Livello 4;
- Livello 5;
- Livello 6;
- Livello 7.

### Cosa Diventa Possibile Dopo

Diventa possibile identificare pattern, anomalie e opportunitÃ  di miglioramento.

Questa conoscenza prepara il terreno a un livello superiore: Factory Intelligence.

## Factory Intelligence

Factory Intelligence Ã¨ la naturale evoluzione di FactoryFlow.

Non significa aggiungere un assistente che risponde semplicemente a domande.

Significa costruire un sistema capace di aiutare concretamente l'azienda a prendere decisioni operative.

Per arrivarci servono i livelli precedenti. Senza dati affidabili, tracciabilitÃ , risorse, capacitÃ , pianificazione, rilevazioni e costi, l'intelligenza artificiale sarebbe solo un'interfaccia elegante sopra informazioni deboli.

Con FactoryFlow, invece, la conoscenza viene costruita progressivamente:

- AdHoc fornisce la veritÃ  gestionale;
- FactoryFlow registra il comportamento operativo;
- la pianificazione descrive le intenzioni;
- le rilevazioni raccontano ciÃ² che accade davvero;
- i costi industriali spiegano l'impatto economico;
- le dashboard rendono visibili i segnali importanti.

Su questa base, un assistente AI puÃ² diventare utile in modo concreto.

PuÃ² aiutare a capire perchÃ© una linea Ã¨ satura.

PuÃ² suggerire quale produzione anticipare.

PuÃ² evidenziare un componente che rischia di bloccare il piano.

PuÃ² spiegare perchÃ© un costo Ã¨ aumentato.

PuÃ² confrontare scenari produttivi.

PuÃ² trasformare dati dispersi in decisioni operative comprensibili.

Factory Intelligence non sostituisce l'esperienza delle persone.

La rende piÃ¹ informata.

Il punto di arrivo non Ã¨ una fabbrica automatica che decide da sola.

Il punto di arrivo Ã¨ una fabbrica in cui imprenditori, responsabili produzione, operatori e consulenti possono decidere meglio, piÃ¹ rapidamente e con maggiore consapevolezza.

Questa Ã¨ la direzione di crescita di FactoryFlow.

