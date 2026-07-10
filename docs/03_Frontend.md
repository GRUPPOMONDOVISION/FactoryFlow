# FactoryFlow - Frontend

Il frontend si trova in `frontend/factoryflow_flutter` ed e sviluppato in Flutter Web/Desktop.

## Pagina Iniziale

La pagina unica iniziale e:

`FactoryFlow - Dichiarazione Produzione`

Campi testata:

- autocomplete articolo producibile;
- quantita prodotta;
- data produzione;
- lotto prodotto;
- magazzino prodotto finito.

## Comportamento

Quando cambiano articolo o quantita prodotta, il frontend ricarica automaticamente la distinta tramite backend.

Non esiste il pulsante "Carica distinta".

## Griglia Componenti

Colonne:

- codice;
- descrizione;
- UM;
- quantita distinta;
- quantita proposta;
- quantita da scaricare modificabile;
- lotto, visibile solo se `gestioneLotti = true`;
- disponibilita lotto;
- scadenza lotto.

Per componenti lottizzati il frontend carica la combo lotti tramite API. Ogni opzione mostra codice lotto, disponibilita e scadenza. Alla selezione aggiorna disponibilita e scadenza della riga.

## Conferma

Il pulsante `CONFERMA PRODUZIONE` valida i dati obbligatori e invia al backend:

- `codAzi`;
- `esercizio`;
- `dataProduzione`;
- `articoloProdotto`;
- `lottoProdotto`;
- `magazzinoProdotto`;
- `quantitaProdotta`;
- `componenti`.

L'esito mostra seriale/numero carico e scarico restituiti dalla stored procedure.
