# ADR-0002 - DB_FARMFLOW Contiene Solo Dati Operativi

## Contesto

FactoryFlow introduce un database applicativo dedicato, `DB_FARMFLOW`.

Questo database serve alla piattaforma MES, ma convive con AdHoc, che resta il sistema ufficiale ERP.

È necessario definire con precisione quali dati possono vivere in `DB_FARMFLOW`.

## Problema

Senza una regola chiara, `DB_FARMFLOW` potrebbe crescere copiando dati AdHoc: articoli, distinte, documenti, lotti, giacenze, clienti, fornitori o costi standard.

Questo trasformerebbe il database FactoryFlow in un secondo ERP incompleto e potenzialmente incoerente.

## Decisione

`DB_FARMFLOW` contiene solo dati propri di FactoryFlow.

In particolare può contenere:

- configurazioni applicative;
- storico applicativo;
- audit;
- dati operativi di reparto;
- linee e macchine quando non sono già governate da AdHoc;
- associazioni operative;
- pianificazioni e simulazioni;
- rilevazioni;
- fotografie di costi industriali calcolati;
- dati temporanei o di supporto.

Non contiene copie master dei dati ERP AdHoc.

## Motivazione

`DB_FARMFLOW` esiste perché non tutto appartiene all'ERP.

FactoryFlow ha bisogno di ricordare il proprio comportamento: chi ha registrato, cosa ha scelto, quali dati sono stati mostrati, quali scenari sono stati simulati, quali decisioni operative sono state prese.

Questi dati sono propri della piattaforma MES.

Al contrario, i dati ufficiali già governati da AdHoc devono restare in AdHoc.

## Alternative Valutate

- Non creare `DB_FARMFLOW`: scartato perché FactoryFlow avrebbe bisogno di forzare dentro AdHoc dati che non appartengono al dominio ERP.
- Usare `DB_FARMFLOW` come replica completa di AdHoc: scartato perché genererebbe duplicazione e disallineamento.
- Salvare solo log tecnici: scartato perché FactoryFlow deve conservare anche dati operativi e decisionali propri.

## Conseguenze Positive

- Il confine tra ERP e MES resta leggibile.
- FactoryFlow può crescere senza sporcare AdHoc.
- I dati operativi e decisionali hanno una sede naturale.
- Il modello dati resta più semplice da governare.
- Ogni nuova tabella deve motivare la propria esistenza.

## Conseguenze Negative

- Occorre valutare ogni nuovo dato prima di salvarlo.
- Alcune analisi richiederanno letture combinate tra AdHoc e `DB_FARMFLOW`.
- Non tutte le funzionalità potranno essere sviluppate velocemente copiando dati in locale.
- Servirà disciplina architetturale costante.

## Livello Di Stabilità

★★★★★

Decisione fondativa. Definisce il confine tra AdHoc e FactoryFlow.
