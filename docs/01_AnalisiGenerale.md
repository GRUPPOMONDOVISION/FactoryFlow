# FactoryFlow - Analisi Generale

FactoryFlow e un gestionale Web/Desktop per dichiarazione produzione interna integrato direttamente con Zucchetti AdHoc Revolution.

## Architettura

La struttura segue il progetto Cantieri:

- Backend ASP.NET Core Web API.
- Frontend Flutter Web/Desktop.
- SQL Server su `SVILUPPO01\SQL2017`.
- Database AdHoc `MOROSITO`.
- Layer backend: `FactoryFlow.Api`, `FactoryFlow.Core`, `FactoryFlow.Infrastructure`, `FactoryFlow.Sql`.

FactoryFlow non usa un database applicativo proprio per la produzione: legge e scrive direttamente sulle tabelle AdHoc.

## Prima Versione

La prima versione contiene solo la dichiarazione produzione.

Non sono implementati:

- login;
- autorizzazioni;
- linee produzione;
- macchine;
- pianificazione;
- MRP.

## Flusso Operativo

1. L'operatore seleziona un articolo producibile tramite autocomplete.
2. Gli articoli producibili sono quelli con `ART_ICOL.ARCODDIS` valorizzato.
3. Al cambio articolo o quantita il frontend ricarica automaticamente la distinta.
4. Il backend legge la distinta AdHoc e restituisce le quantita ricalcolate.
5. Per componenti lottizzati il frontend carica i lotti disponibili e mostra disponibilita/scadenza.
6. Alla conferma il backend chiama `dbo.sp_FactoryFlow_CreaDichiarazioneProduzione`.

La stored procedure e il motore ufficiale: genera carico prodotto finito e scarico componenti, aggiorna giacenze immediatamente ed esegue rollback completo in caso di errore.
