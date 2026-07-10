# FactoryFlow - MVP Giovedi

## Obiettivo

Entro giovedi FactoryFlow deve avere una base operativa funzionante per registrare produzione reale, collegando AdHoc e `DB_FARMFLOW` senza duplicare il dominio ERP.

## Deve Essere Pronto

### DB_FARMFLOW Creato

Lo script `backend/FactoryFlow.Sql/scripts/DB_FARMFLOW_Create.sql` crea il database applicativo minimo.

Tabelle incluse:

- `FF_CONFIG`;
- `FF_LINEE_LAVORAZIONE`;
- `FF_LINEE_ARTICOLI`;
- `FF_DICHIARAZIONI_PRODUZIONE`;
- `FF_DICHIARAZIONI_COMPONENTI`;
- `FF_AUDIT_EVENTI`.

### Configurazione Attiva

Deve esistere una configurazione attiva con:

- azienda AdHoc;
- prefisso azienda;
- causale carico;
- causale scarico;
- magazzino prodotto finito default;
- magazzino componenti default.

FactoryFlow non salva alfanumerici, causali magazzino o segni documento: questi restano letti da AdHoc.

### Linee

L'MVP consente di gestire linee operative semplici:

- elenco linee;
- nuova linea;
- modifica descrizione;
- linea attiva/non attiva.

### Articoli Per Linea

Ogni linea puo essere associata a uno o piu articoli producibili AdHoc.

L'associazione salva solo il codice articolo. Descrizione, UM, distinta e lotti restano in AdHoc.

### Dichiarazione Produzione

La schermata produzione richiede:

1. selezione linea;
2. selezione articolo associato alla linea;
3. quantita prodotta;
4. data produzione;
5. lotto prodotto finito;
6. lotti componenti dove richiesti;
7. conferma produzione.

Se non esistono linee configurate, l'operatore vede il messaggio:

`Nessuna linea configurata. Configurare almeno una linea di produzione.`

### Salvataggio AdHoc

Alla conferma il backend chiama la stored procedure AdHoc gia validata.

La registrazione ufficiale resta in AdHoc: documenti, righe, lotti e saldi ufficiali.

### Storico DB_FARMFLOW

Solo se AdHoc risponde correttamente, FactoryFlow salva:

- testata dichiarazione;
- righe componenti come snapshot operativo;
- riferimenti ai seriali e numeri documento AdHoc;
- evento audit.

Se AdHoc fallisce, non viene salvata una dichiarazione confermata in `DB_FARMFLOW`.

## Esclusioni Del MVP

Non fanno parte dell'MVP:

- MRP;
- pianificazione;
- AI;
- dashboard;
- costi energia/manodopera/setup;
- modifica o cancellazione dichiarazioni;
- mobile avanzato.

## Criterio Di Successo

Il successo del MVP non e avere molte funzioni.

Il successo e poter registrare una produzione reale, generare i documenti AdHoc ufficiali e conservare uno storico FactoryFlow coerente e consultabile.
