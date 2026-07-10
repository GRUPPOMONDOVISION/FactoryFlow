# FactoryFlow - DB_FARMFLOW

`DB_FARMFLOW` contiene solo configurazioni applicative FactoryFlow. Non deve duplicare informazioni gia presenti e governate da AdHoc Revolution.

## FF_CONFIG

La tabella `FF_CONFIG` deve contenere esclusivamente:

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

La configurazione non deve usare:

- `TipoDocCarico`
- `TipoDocScarico`
- `AlfDocCarico`
- `AlfDocScarico`

## Regola Documento AdHoc

`CausaleCarico` e `CausaleScarico` identificano i documenti AdHoc da usare per la produzione.

Da `[AZIENDA]TIP_DOCU`, usando la causale configurata, si leggono:

- `TDTIPDOC`: codice documento effettivo;
- `TDALFDOC`: alfanumerico documento;
- `TDCAUMAG`: causale magazzino;
- `TD_SEGNO`: segno documento, se utile.

## Dati Da Non Duplicare

Non duplicare in `DB_FARMFLOW`:

- alfanumerico documento;
- causale magazzino;
- segno documento.

Questi dati restano governati da AdHoc dentro `[AZIENDA]TIP_DOCU`.

## Principio

AdHoc resta la fonte ufficiale per le regole documentali e di magazzino.

FactoryFlow deve configurare solo quali causali usare per carico e scarico produzione. Gli attributi documentali derivati devono essere letti da AdHoc al momento dell'utilizzo.

## MVP Operativo Entro Giovedi

Per l'MVP operativo `DB_FARMFLOW` contiene solo il nucleo minimo necessario:

- `FF_CONFIG` per configurazione attiva cliente;
- `FF_LINEE_LAVORAZIONE` per linee operative di reparto;
- `FF_LINEE_ARTICOLI` per associazioni operative tra linea e codice articolo AdHoc;
- `FF_DICHIARAZIONI_PRODUZIONE` per storico applicativo della conferma produzione;
- `FF_DICHIARAZIONI_COMPONENTI` per snapshot operativo dei componenti confermati;
- `FF_AUDIT_EVENTI` per audit minimo.

Le associazioni linea-articolo salvano solo il codice articolo AdHoc come riferimento esterno. Non salvano descrizione, unita di misura, distinta o giacenze.

Le descrizioni e unita di misura eventualmente presenti nelle dichiarazioni sono snapshot storici dell'operazione, non anagrafiche parallele.

La sequenza corretta della conferma produzione e:

1. chiamata al motore AdHoc validato;
2. se AdHoc conferma, salvataggio storico in `DB_FARMFLOW`;
3. salvataggio evento audit.

Se AdHoc fallisce, FactoryFlow non salva una dichiarazione confermata in `DB_FARMFLOW`.
