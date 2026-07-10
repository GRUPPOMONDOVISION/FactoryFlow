# FactoryFlow - Database AdHoc

FactoryFlow lavora direttamente sulle tabelle ufficiali di AdHoc Revolution nel database `MOROSITO`.

## Tabelle Coinvolte

Con azienda `MOROS` le tabelle sono:

- `MOROSART_ICOL`
- `MOROSDOC_MAST`
- `MOROSDOC_DETT`
- `MOROSDISMBASE`
- `MOROSDISTBASE`
- `MOROSSALDILOT`
- `MOROSLOTTIART`
- `MOROSTIP_DOCU`
- `cpwarn`

## Regole Principali

- `ART_ICOL.ARCODDIS` identifica la distinta base collegata all'articolo prodotto.
- `ART_ICOL.ARFLLOTT = 'S'` identifica un articolo gestito a lotti.
- `[AZIENDA]TIP_DOCU` governa documenti, alfanumerici, causali magazzino e segni.
- `cpwarn` gestisce i progressivi AdHoc.
- I progressivi devono essere letti e aggiornati in transazione.

## Registrazione Produzione

La stored procedure ufficiale e:

`backend/FactoryFlow.Sql/stored/dbo.sp_FactoryFlow_CreaDichiarazioneProduzione.sql`

La stored:

- riceve testata produzione;
- riceve componenti in JSON;
- legge e aggiorna `cpwarn`;
- genera documento di carico prodotto finito;
- genera documento di scarico componenti;
- scrive su `DOC_MAST` e `DOC_DETT`;
- gestisce i lotti;
- aggiorna immediatamente le giacenze;
- esegue tutto in transazione;
- fa rollback completo in caso di errore.

## Configurazione DB_FARMFLOW

La tabella applicativa `FF_CONFIG` non deve contenere tipo documento, alfanumerico documento, causale magazzino o segno documento.

`FF_CONFIG` contiene solo:

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

Da `[AZIENDA]TIP_DOCU`, usando la causale configurata, si leggono:

- `TDTIPDOC`: codice documento effettivo;
- `TDALFDOC`: alfanumerico documento;
- `TDCAUMAG`: causale magazzino;
- `TD_SEGNO`: segno documento, se utile.

Non duplicare in `DB_FARMFLOW`:

- alfanumerico documento;
- causale magazzino;
- segno documento.

Questi dati restano governati da AdHoc dentro `[AZIENDA]TIP_DOCU`.

## Segni Movimento

- `MVFLCASC = '+'` per carico.
- `MVFLCASC = '-'` per scarico.
- `MVFLLOTT = '+'` per carico lotto.
- `MVFLLOTT = '-'` per scarico lotto.

Il controllo giacenza non blocca la dichiarazione: la disponibilita lotto viene mostrata all'operatore.

## Requisito SQL JSON

La stored definitiva usa `OPENJSON` per ricevere i componenti. Su SQL Server 2017 questo richiede database compatibility level almeno `130`.

Il backend e gia allineato alla firma della stored e invia i componenti in JSON.
