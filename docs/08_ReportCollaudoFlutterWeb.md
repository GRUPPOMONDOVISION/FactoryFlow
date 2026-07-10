# Report collaudo Flutter Web produzione

Data collaudo: 2026-06-30

## Vincoli rispettati

- Stored procedure non modificata.
- API non modificata.
- Interventi eseguiti solo su frontend Flutter e infrastruttura di test Web.

## Correzioni frontend necessarie al collaudo

Durante il collaudo Web sono emersi due problemi lato Flutter:

1. Il progetto non aveva ancora la piattaforma Web/Desktop generata. Eseguito `flutter create .` in `frontend/factoryflow_flutter`.
2. La griglia componenti usava `Scrollbar` senza `ScrollController`, causando errore in Flutter Web/debug. Aggiunti controller espliciti per scroll orizzontale e verticale.
3. In ambiente `flutter drive`, l'opzione dell'autocomplete non era tappabile come testo. Aggiunta selezione articolo da tastiera: inserendo il codice esatto e premendo Invio viene selezionato l'articolo e caricata la distinta.

File principali modificati:

- `frontend/factoryflow_flutter/lib/pagine/dichiarazione_produzione_page.dart`
- `frontend/factoryflow_flutter/pubspec.yaml`
- `frontend/factoryflow_flutter/integration_test/produzione_web_test.dart`
- `frontend/factoryflow_flutter/test_driver/integration_test.dart`

## Verifiche Flutter

Comandi eseguiti:

```powershell
flutter analyze
flutter drive --driver=test_driver\integration_test.dart --target=integration_test\produzione_web_test.dart -d chrome --dart-define=BASE_URL=http://localhost:5100 --dart-define=COD_AZI=MOROS --dart-define=ESERCIZIO=2023
flutter build web --dart-define=BASE_URL=http://localhost:5100 --dart-define=COD_AZI=MOROS --dart-define=ESERCIZIO=2023
```

Esiti:

- `flutter analyze`: nessun problema.
- `flutter drive`: test Web superato.
- `flutter build web`: completato, output in `build/web`.

## Flusso collaudato da Flutter Web

Il test automatico guida la pagina Flutter e verifica:

1. apertura pagina dichiarazione produzione;
2. inserimento articolo `CAPSULABIALETTIDIST`;
3. selezione articolo da tastiera;
4. caricamento distinta;
5. caricamento lotti componenti;
6. valorizzazione lotto prodotto `FFWEB`;
7. conferma produzione;
8. messaggio UI `Dichiarazione produzione confermata`.

## Documenti verificati

Ultima dichiarazione valida del collaudo Web:

| Documento | Seriale | Numero | Tipo | Alfanumerico | Collegamento |
|---|---|---:|---|---|---|
| Carico PF | 0000170026 | 821 | DPPRF | DP | |
| Scarico componenti | 0000170027 | 1571 | SCOMP | vuoto | MVNUMEST = 821, MVALFEST = DP |

Righe scarico ultimo documento:

| Componente | Lotto | Quantita | MVFLCASC | MVCAUMAG | MV_SEGNO |
|---|---|---:|---|---|---|
| CAPSULABIALETTI | 0090 | 1.000 | - | 205 | D |
| CARTAALLUMINIOMICROF | JOB 20295 | 0.380 | - | 205 | D |
| CARTAFILTRO1 | 150189667 | 0.110 | - | 205 | D |
| TOPBIALETTI | 22-1335-002 | 0.220 | - | 205 | D |

## SALDILOT

Snapshot prima del collaudo Web automatico:

| Articolo | Lotto | SUQTAPER |
|---|---|---:|
| CAPSULABIALETTI | 0090 | 33399.000 |
| CARTAALLUMINIOMICROF | JOB 20295 | 126.692 |
| CARTAFILTRO1 | 150189667 | 0.000 |
| TOPBIALETTI | 22-1335-002 | 29.004 |

Snapshot dopo i tentativi e il collaudo Web riuscito:

| Articolo | Lotto | SUQTAPER |
|---|---|---:|
| CAPSULABIALETTI | 0090 | 33394.000 |
| CARTAALLUMINIOMICROF | JOB 20295 | 124.792 |
| CARTAFILTRO1 | 150189667 | -0.550 |
| TOPBIALETTI | 22-1335-002 | 27.904 |

Nota: durante i tentativi di automazione Web sono state generate piu dichiarazioni minime `CAPSULABIALETTIDIST` prima del run finale riuscito. La variazione cumulata corrisponde a 5 conferme da quantita 1. L'ultima conferma valida e documentata e `0000170026 / 0000170027`.

## Progressivi dopo collaudo

| Progressivo | Autonum |
|---|---:|
| `prog\SEDOC\'MOROS'` | 170027 |
| `prog\PRDOC\'MOROS'\'2023'\'IV'\'DP        '` | 821 |
| `prog\PRDOC\'MOROS'\'2023'\'IV'\'          '` | 1571 |

## Esito finale

Collaudo Flutter Web positivo.

La UI carica articoli, distinta e lotti dagli endpoint reali, conferma la produzione tramite API, crea i documenti AdHoc e aggiorna `MOROSSALDILOT` tramite la stored gia validata.
