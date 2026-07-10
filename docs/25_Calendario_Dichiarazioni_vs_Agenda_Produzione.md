# FactoryFlow - Calendario Dichiarazioni Vs Agenda Produzione

## Perche Esistono Due Porte

FactoryFlow deve servire aziende con maturita produttive diverse.

Alcune aziende vogliono solo dichiarare correttamente la produzione e ottenere documenti AdHoc coerenti.

Altre vogliono governare processi, fasi, attivita previste, consuntivi, costi e performance.

Forzare tutte le aziende dentro lo stesso calendario renderebbe il prodotto confuso.

Per questo FactoryFlow mantiene due esperienze distinte.

## Calendario Dichiarazioni

Il Calendario Dichiarazioni si usa quando l'azienda vuole registrare una produzione diretta.

Domanda principale:

```text
Che cosa ho prodotto oggi?
```

Risposta del sistema:

```text
Registro la produzione, scarico i componenti, aggiorno AdHoc e salvo lo storico FactoryFlow.
```

Caratteristiche:

- non richiede processi configurati;
- usa articolo, distinta e lotti AdHoc;
- consente macchina, team e tempi;
- genera documenti AdHoc quando confermato;
- resta coerente con l'MVP gia validato.

## Agenda Produzione

L'Agenda Produzione si usa quando l'azienda vuole pianificare e governare un percorso operativo.

Domanda principale:

```text
Quale attivita produttiva devo eseguire e quali fasi devo chiudere?
```

Risposta del sistema:

```text
Mostro il processo, le fasi previste, lo stato di avanzamento e consento la chiusura controllata delle fasi.
```

Caratteristiche:

- parte da una attivita prevista;
- collega articolo, processo, versione e fasi;
- ogni fase ha requisiti propri;
- solo alcune fasi generano ERP;
- prepara analisi di scostamento, performance e costi.

## Perche Non Sono La Stessa Cosa

Il Calendario Dichiarazioni registra un fatto produttivo diretto.

L'Agenda Produzione governa un processo composto da fasi.

Unificarli obbligherebbe l'utente semplice a vedere concetti inutili e impedirebbe all'utente evoluto di gestire davvero il processo.

## Compatibilita Con MVP

Il flusso MVP resta valido:

```text
articolo -> quantita -> lotto -> componenti -> conferma -> AdHoc
```

FactoryFlow non obbliga l'azienda a configurare processi.

Quando l'azienda sara' pronta, potra' usare l'Agenda Produzione senza perdere quanto gia costruito.

## Come L'Agenda Prepara Process Performance

L'Agenda produce informazioni che la dichiarazione diretta non puo' rappresentare completamente:

- fase prevista;
- fase consuntivata;
- ritardo o anticipo;
- macchina usata rispetto a macchina prevista;
- team previsto rispetto a team effettivo;
- tempo standard rispetto a tempo reale;
- costo previsto rispetto a costo reale;
- fasi ERP e fasi non ERP.

Queste informazioni alimentano il futuro modulo Process Performance.

## Regola Finale

Non cancellare il Calendario Dichiarazioni.

Non ridurre l'Agenda Produzione a una semplice dichiarazione.

FactoryFlow deve proteggere entrambe le esperienze perche rappresentano due livelli diversi di maturita industriale.
