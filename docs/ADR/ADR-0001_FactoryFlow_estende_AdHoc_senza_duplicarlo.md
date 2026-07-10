# ADR-0001 - FactoryFlow Estende AdHoc Senza Duplicarlo

## Contesto

FactoryFlow nasce come piattaforma MES integrata con AdHoc Revolution.

AdHoc è già il sistema ufficiale dell'azienda per articoli, distinte, documenti, magazzino, lotti, contabilità, costi standard, cicli, clienti e fornitori.

FactoryFlow deve migliorare l'operatività di fabbrica senza creare un secondo gestionale parallelo.

## Problema

Se FactoryFlow duplicasse i dati governati da AdHoc, nascerebbero due fonti della verità.

Nel tempo articoli, distinte, lotti, giacenze e regole documentali potrebbero cambiare in AdHoc ma restare disallineati in FactoryFlow.

Questo renderebbe il sistema fragile, difficile da mantenere e rischioso per l'azienda.

## Decisione

FactoryFlow estende AdHoc senza duplicarlo.

AdHoc rimane la fonte ufficiale dei dati ERP.

FactoryFlow legge e valorizza le informazioni AdHoc, ma salva nel proprio dominio solo dati applicativi, operativi, storici o decisionali che AdHoc non possiede già come fonte ufficiale.

## Motivazione

Questa decisione protegge la coerenza del dominio.

FactoryFlow deve essere un livello moderno di operatività, pianificazione, controllo e intelligenza di fabbrica, non una copia dell'ERP.

Il valore del prodotto nasce dalla capacità di usare bene i dati AdHoc, non dal duplicarli.

## Alternative Valutate

- Creare anagrafiche FactoryFlow parallele: scartato perché introdurrebbe doppia manutenzione e rischio di disallineamento.
- Copiare periodicamente dati AdHoc in FactoryFlow: scartato come regola generale perché trasformerebbe snapshot tecnici in dati percepiti come ufficiali.
- Usare AdHoc solo come destinazione finale: scartato perché FactoryFlow perderebbe il legame con la verità gestionale durante il processo.

## Conseguenze Positive

- Una sola fonte ufficiale per i dati ERP.
- Meno rischio di incoerenza tra reparto e gestionale.
- Architettura più pulita e mantenibile.
- FactoryFlow resta focalizzato su ciò che AdHoc non gestisce in modo moderno.
- Le evoluzioni future partono da un dominio più chiaro.

## Conseguenze Negative

- FactoryFlow dipende dalla qualità e disponibilità dei dati AdHoc.
- Le integrazioni richiedono maggiore conoscenza del dominio AdHoc.
- Alcune funzionalità richiedono letture dirette da AdHoc invece di dati locali più semplici.
- I test devono verificare sempre la coerenza con il comportamento reale di AdHoc.

## Livello Di Stabilità

★★★★★

Decisione fondativa. Deve essere cambiata solo se cambia la natura stessa del prodotto.
