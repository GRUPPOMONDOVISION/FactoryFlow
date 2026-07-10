# ADR-0006 - Cancellazione, Obsolescenza E Protezione Dello Storico

## Contesto

FactoryFlow contiene configurazioni operative che possono incidere su processi, costi, tempi, capacita, team, linee, macchine e dichiarazioni produttive.

Alcune informazioni sono semplici bozze mai utilizzate. Altre, invece, hanno contribuito a spiegare una produzione, una previsione, una metrica o un costo industriale.

Cancellare o modificare senza controllo queste informazioni renderebbe fragile il sistema e impedirebbe di ricostruire correttamente il passato.

## Problema

Una stessa azione utente chiamata "cancellazione" puo avere significati diversi:

- eliminare un dato mai usato;
- impedire usi futuri di un dato gia usato;
- mantenere consultabile un dato storico;
- bloccare una modifica che altererebbe consuntivi gia registrati.

Se FactoryFlow trattasse tutte queste situazioni nello stesso modo, rischierebbe di alterare dati storici, costi e analisi industriali.

## Decisione

FactoryFlow adotta una regola generale:

- se un'informazione non e mai stata usata e non ha generato dati storici, puo essere cancellata fisicamente;
- se un'informazione e stata usata, non deve essere cancellata fisicamente;
- se un'informazione usata non deve piu essere disponibile per il futuro, deve essere resa obsoleta, chiusa temporalmente o sostituita da una nuova versione;
- se una modifica altererebbe il significato storico di dati gia registrati, la modifica deve essere bloccata e deve essere richiesta una nuova versione.

Per i processi produttivi, le fasi operative di una versione non ancora usata possono essere modificate o cancellate.

Quando una versione del processo e gia stata usata da attivita produttive, le sue fasi non possono essere modificate o cancellate: occorre creare una nuova versione del processo.

## Motivazione

FactoryFlow non registra soltanto dati. Costruisce conoscenza storica della fabbrica.

La conoscenza storica deve essere ricostruibile anche dopo anni. Una produzione confermata deve continuare a raccontare quali regole, risorse, costi, fasi e configurazioni erano valide nel momento in cui e stata registrata.

La cancellazione fisica e corretta solo quando non esiste storia da proteggere.

## Alternative Valutate

### Cancellare sempre fisicamente

Alternativa scartata perche distrugge il contesto storico.

### Non cancellare mai nulla

Alternativa scartata perche accumula bozze e dati errati mai usati, rendendo il sistema meno leggibile.

### Usare solo un flag Attivo

Alternativa insufficiente per dati che incidono su costi, tempi e analisi. Per questi dati serve validita temporale, obsolescenza motivata o versionamento.

### Versionare solo alcune entita

Alternativa parziale. Le entita che incidono su storico e costi devono seguire tutte lo stesso principio, anche se con strumenti diversi.

## Conseguenze Positive

- Il passato resta ricostruibile.
- Le bozze inutili possono essere eliminate senza appesantire il sistema.
- Le configurazioni usate restano consultabili.
- Le modifiche future non alterano costi e analisi gia calcolati.
- Il comportamento e coerente fra processi, team, macchine, setup e costi.

## Conseguenze Negative

- Alcune modifiche richiedono la creazione di una nuova versione invece della modifica diretta.
- Le UI devono spiegare chiaramente perche una cancellazione e bloccata.
- Il backend deve controllare l'utilizzo storico prima di cancellare o modificare.
- Il modello dati deve prevedere obsolescenza, validita temporale o versionamento dove serve.

## Livello Di Stabilita

★★★★★

Decisione permanente.
