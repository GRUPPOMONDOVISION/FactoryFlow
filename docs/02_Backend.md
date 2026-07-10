# FactoryFlow - Backend

Il backend si trova in `backend` ed e organizzato come il progetto Cantieri.

## Progetti

- `FactoryFlow.Api`: controller e service applicativi.
- `FactoryFlow.Core`: DTO e interfacce.
- `FactoryFlow.Infrastructure`: accesso SQL Server / AdHoc.
- `FactoryFlow.Sql`: stored procedure e script SQL.

## Configurazione

`backend/FactoryFlow.Api/appsettings.json` punta a:

- Server: `SVILUPPO01\SQL2017`
- Database: `MOROSITO`
- Azienda AdHoc: `MOROS`
- Magazzino default: `01`

## Regole Configurazione Documenti

Il backend deve usare `FF_CONFIG` solo per identificare azienda, prefisso, causali documento e magazzini default.

`FF_CONFIG` contiene:

- `IdConfig`
- `CodAziAdhoc`
- `PrefissoAzienda`
- `CausaleCarico`
- `CausaleScarico`
- `MagazzinoPFDefault`
- `MagazzinoComponentiDefault`
- `Attiva`
- `DataCreazione`
- `DataModifica`

`CausaleCarico` e `CausaleScarico` identificano i documenti AdHoc da usare per la produzione.

Il backend non deve leggere da `FF_CONFIG`:

- tipo documento effettivo;
- alfanumerico documento;
- causale magazzino;
- segno documento.

Questi dati devono essere ricavati da `[AZIENDA]TIP_DOCU` usando la causale configurata:

- `TDTIPDOC`: codice documento effettivo;
- `TDALFDOC`: alfanumerico documento;
- `TDCAUMAG`: causale magazzino;
- `TD_SEGNO`: segno documento, se utile.

## API Produzione

### GET `/api/produzione/articoli`

Legge `[AZIENDA]ART_ICOL` e restituisce solo articoli con `ARCODDIS` valorizzato.

Campi restituiti:

- `codArticolo`
- `descrizione`
- `unitaMisura`
- `codiceDistinta`
- `gestioneLotti`

### GET `/api/produzione/distinta?codArticolo=...&quantita=...`

Legge `ART_ICOL.ARCODDIS` e carica i componenti da `[AZIENDA]DISTBASE`.

Calcolo:

```text
quantitaProposta = quantitaDistinta * quantitaProdotta
```

Campi restituiti per componente:

- `codComponente`
- `descrizione`
- `unitaMisura`
- `quantitaDistinta`
- `quantitaProposta`
- `quantitaDaScaricare`
- `magazzino`
- `gestioneLotti`

### GET `/api/produzione/lotti?codArticolo=...&magazzino=01&dataProduzione=...`

Legge `[AZIENDA]SALDILOT` e `[AZIENDA]LOTTIART`.

Filtri:

- lotto esistente;
- scadenza nulla oppure successiva alla data produzione.

Il controllo giacenza non blocca: la disponibilita viene mostrata all'operatore.

### POST `/api/produzione/dichiarazione`

Riceve testata e componenti, poi chiama solo:

`dbo.sp_FactoryFlow_CreaDichiarazioneProduzione`

Il backend non ricostruisce in C# la logica di scrittura su `DOC_MAST` e `DOC_DETT`.
