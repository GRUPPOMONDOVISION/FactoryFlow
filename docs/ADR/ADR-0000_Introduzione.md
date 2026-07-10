# ADR-0000 - Introduzione Agli Architecture Decision Records

## Contesto

FactoryFlow è una piattaforma MES destinata a crescere negli anni.

Il progetto integra AdHoc Revolution, introduce `DB_FARMFLOW` e dovrà evolvere verso produzione, pianificazione, capacità produttiva, costi industriali, monitoraggio e Factory Intelligence.

In un prodotto di questo tipo il codice non basta a spiegare il perché delle scelte. Serve un modo semplice, stabile e consultabile per conservare le decisioni architetturali importanti.

## Cosa Sono Gli ADR

Gli Architecture Decision Records, o ADR, sono documenti brevi che registrano una decisione architetturale.

Un ADR non descrive genericamente il sistema. Spiega una scelta precisa:

- quale contesto l'ha generata;
- quale problema risolve;
- quale decisione è stata presa;
- perché è stata scelta;
- quali alternative sono state valutate;
- quali conseguenze positive e negative comporta.

Gli ADR aiutano chi entrerà nel progetto in futuro a capire non solo cosa è stato fatto, ma perché è stato fatto.

## Perché Li Introduciamo

FactoryFlow deve rimanere coerente nel tempo.

Molte decisioni del progetto non sono semplici dettagli tecnici. Sono scelte di dominio:

- AdHoc rimane la fonte ufficiale;
- FactoryFlow estende AdHoc senza duplicarlo;
- `DB_FARMFLOW` contiene solo dati propri della piattaforma;
- alcune scritture avvengono direttamente sulle tabelle ufficiali AdHoc;
- alcune logiche AdHoc devono essere replicate con grande attenzione quando non sono attivate automaticamente dal database.

Queste decisioni devono essere visibili, motivate e stabili.

Gli ADR impediscono che la conoscenza resti solo nella memoria delle persone o nascosta dentro il codice.

## Quando Creare Un ADR

Ogni decisione importante del progetto deve avere un ADR dedicato.

Un ADR è necessario quando una scelta:

- definisce il rapporto tra FactoryFlow e AdHoc;
- introduce o modifica una responsabilità di `DB_FARMFLOW`;
- decide dove vive un'informazione;
- evita una duplicazione di dati ERP;
- stabilisce una regola di integrazione con AdHoc;
- impatta il modello dati;
- influenza la manutenzione futura del prodotto;
- esclude consapevolmente un'alternativa possibile.

Non serve un ADR per ogni piccola modifica di interfaccia o dettaglio implementativo. Serve per le decisioni che, se dimenticate, potrebbero portare il progetto fuori rotta.

## Formato Ufficiale Di Ogni ADR

Ogni ADR FactoryFlow deve seguire questo formato:

### Contesto

Descrive la situazione in cui nasce la decisione.

### Problema

Spiega il problema da risolvere e perché non può essere ignorato.

### Decisione

Indica chiaramente la scelta presa.

### Motivazione

Spiega perché quella scelta è coerente con FactoryFlow.

### Alternative Valutate

Elenca le alternative considerate e perché non sono state scelte.

### Conseguenze Positive

Descrive i benefici attesi.

### Conseguenze Negative

Descrive i costi, i vincoli o i rischi introdotti dalla decisione.

### Livello Di Stabilità

Indica quanto la decisione è considerata stabile:

- ★☆☆☆☆ decisione provvisoria;
- ★★☆☆☆ decisione debole, da validare;
- ★★★☆☆ decisione valida ma potenzialmente rivedibile;
- ★★★★☆ decisione stabile;
- ★★★★★ decisione fondativa, da cambiare solo con forte motivazione.

## Regola Di Governo

Gli ADR non sostituiscono la documentazione generale, ma la rendono più governabile.

I documenti di architettura spiegano la visione complessiva. Gli ADR fissano le decisioni che non devono essere perse.

Quando una decisione cambia, non si cancella la storia: si crea un nuovo ADR o si aggiorna lo stato della decisione spiegando il motivo.

FactoryFlow deve poter essere mantenuto fra dieci anni. Gli ADR sono uno degli strumenti che rendono possibile questa continuità.
