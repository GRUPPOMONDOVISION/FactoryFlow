# ADR-0003 - Le Registrazioni Vengono Scritte Direttamente Su DOC_MAST E DOC_DETT

## Contesto

La prima area operativa di FactoryFlow è la dichiarazione produzione.

La registrazione della produzione deve generare documenti ufficiali AdHoc: carico del prodotto finito e scarico dei componenti.

In AdHoc i documenti ufficiali vivono nelle strutture documentali aziendali, tra cui `DOC_MAST` e `DOC_DETT`.

## Problema

FactoryFlow deve decidere se salvare le dichiarazioni in tabelle proprie e poi sincronizzarle, oppure scrivere direttamente i documenti ufficiali AdHoc.

Una registrazione produzione che resta solo in FactoryFlow non sarebbe immediatamente un documento gestionale ufficiale.

Questo creerebbe ritardi, riconciliazioni e rischio di incoerenza tra fabbrica e ERP.

## Decisione

Le registrazioni ufficiali di produzione vengono scritte direttamente su `DOC_MAST` e `DOC_DETT` tramite il motore transazionale validato.

FactoryFlow non ricostruisce un proprio sistema documentale parallelo.

`DB_FARMFLOW` conserva solo lo storico applicativo, gli input, gli esiti e i riferimenti ai documenti AdHoc generati.

## Motivazione

La produzione deve produrre effetti ufficiali nel gestionale ufficiale.

Se il carico prodotto finito e lo scarico componenti sono documenti AdHoc, devono nascere come documenti AdHoc, con progressivi, causali, righe, lotti e regole coerenti con il gestionale.

FactoryFlow deve semplificare l'operazione, non spostare la verità documentale fuori da AdHoc.

## Alternative Valutate

- Salvare dichiarazioni solo in `DB_FARMFLOW`: scartato perché non aggiornerebbe immediatamente il sistema gestionale ufficiale.
- Creare documenti intermedi da sincronizzare successivamente: scartato per rischio di disallineamento e gestione errori più complessa.
- Ricostruire un motore documentale FactoryFlow: scartato perché duplicherebbe una responsabilità già propria di AdHoc.

## Conseguenze Positive

- I documenti sono immediatamente ufficiali in AdHoc.
- Non esiste una seconda verità documentale.
- Il reparto lavora con una UI moderna, ma l'ERP resta coerente.
- Lo storico FactoryFlow resta leggero e orientato ad audit.
- Le giacenze e i lotti possono essere mantenuti allineati al flusso documentale AdHoc.

## Conseguenze Negative

- La scrittura richiede conoscenza precisa delle regole AdHoc.
- Eventuali differenze tra installazioni cliente devono essere gestite con attenzione.
- Il motore transazionale deve essere testato con casi reali.
- Errori documentali possono avere impatto diretto sul gestionale ufficiale.

## Livello Di Stabilità

★★★★☆

Decisione stabile. Potrà evolvere solo se in futuro AdHoc offrirà un'interfaccia ufficiale più adatta, completa e validata per lo stesso scopo.
