# ADR-0004 - SALDILOT Viene Aggiornato Replicando La Logica Applicativa AdHoc E Non Tramite Trigger SQL

## Contesto

Durante la validazione della dichiarazione produzione è emerso che i documenti AdHoc creati da FactoryFlow venivano generati correttamente, ma i saldi lotto non venivano aggiornati automaticamente.

L'analisi dei sorgenti AdHoc ha mostrato che l'aggiornamento di `SALDILOT` avviene nella logica applicativa di salvataggio riga, non tramite trigger sul database.

FactoryFlow, scrivendo direttamente i documenti, deve quindi garantire anche la coerenza dei saldi lotto.

## Problema

Limitarsi a inserire righe in `DOC_DETT` non aggiorna automaticamente `SALDILOT`.

Creare un trigger SQL potrebbe sembrare una soluzione rapida, ma introdurrebbe una logica implicita, difficile da governare e potenzialmente diversa da quella AdHoc.

Serve replicare il comportamento rilevante di AdHoc in modo esplicito, transazionale e controllato.

## Decisione

`SALDILOT` viene aggiornato replicando la logica applicativa AdHoc individuata nell'analisi.

L'aggiornamento avviene nello stesso flusso transazionale della registrazione documentale FactoryFlow.

Non vengono creati trigger SQL per aggiornare `SALDILOT`.

## Motivazione

AdHoc non aggiorna `SALDILOT` come effetto automatico di un trigger su `DOC_DETT`.

Replica controllata significa rispettare il comportamento applicativo reale: usare i campi riga corretti, applicare il segno del movimento, aggiornare o inserire il saldo lotto e mantenere coerenza nella stessa transazione.

Un trigger nasconderebbe la logica nel database e potrebbe essere attivato anche da flussi non previsti, creando effetti collaterali difficili da diagnosticare.

## Alternative Valutate

- Non aggiornare `SALDILOT`: scartato perché lascerebbe documenti e saldi lotto incoerenti.
- Aggiornare `SALDILOT` manualmente fuori dalla transazione: scartato perché introdurrebbe rischio di saldi parziali.
- Creare un trigger su `DOC_DETT`: scartato perché AdHoc non usa questa modalità e perché renderebbe la logica implicita.
- Richiedere sempre apertura e salvataggio manuale in AdHoc: scartato perché annullerebbe il valore operativo di FactoryFlow.

## Conseguenze Positive

- I documenti FactoryFlow aggiornano i saldi lotto in modo immediato.
- La logica resta esplicita e testabile.
- Non vengono introdotti trigger nascosti.
- La registrazione rimane transazionale.
- Il comportamento è allineato alla logica applicativa AdHoc analizzata.

## Conseguenze Negative

- FactoryFlow deve mantenere una replica mirata di una logica applicativa AdHoc.
- Eventuali cambi futuri nella logica AdHoc dovranno essere rivalutati.
- La procedura di registrazione diventa più delicata.
- I test devono includere casi di lotto esistente, lotto nuovo, carico e scarico.

## Livello Di Stabilità

★★★★☆

Decisione stabile, basata su analisi del comportamento reale AdHoc. Da rivalutare solo se cambia la logica ufficiale AdHoc o se viene introdotta una modalità ufficiale alternativa.
