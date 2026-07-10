# FactoryFlow - Checklist Deploy Cliente

Checklist ufficiale per installare e collaudare FactoryFlow presso un cliente.

Il documento e' pensato per essere usato durante l'intervento tecnico, non come descrizione teorica. Ogni punto va verificato e, dove necessario, annotato con i valori reali dell'ambiente cliente.

## 1. Prerequisiti Server

### Runtime e componenti

- [ ] Server Windows disponibile e accessibile con privilegi amministrativi.
- [ ] .NET 8 Runtime installato.
- [ ] ASP.NET Core Runtime 8 installato, se il backend viene eseguito come applicazione ASP.NET Core framework-dependent.
- [ ] SQL Server raggiungibile dal server applicativo.
- [ ] IIS installato per pubblicare il frontend Flutter Web.
- [ ] Browser disponibile sul server per test locale.
- [ ] Accesso da almeno un client di rete per test da postazione operatore.

### Verifiche rapide

- [ ] `dotnet --info` mostra runtime .NET 8.
- [ ] SQL Server risponde dal server applicativo.
- [ ] IIS Manager si apre con `inetmgr`.
- [ ] Il servizio Windows puo' essere creato dall'utente corrente.

### Porte

Compilare con i valori effettivi del cliente.

| Componente | Porta | URL atteso | Stato |
|---|---:|---|---|
| Backend API | 5100 | `http://<server>:5100` | [ ] |
| Frontend Flutter Web | 5200 | `http://<server>:5200` | [ ] |

- [ ] Porta backend aperta sul firewall.
- [ ] Porta frontend aperta sul firewall.
- [ ] Nessun altro processo occupa le porte scelte.

### Permessi servizio Windows

- [ ] Il servizio backend viene eseguito con un account autorizzato.
- [ ] L'account del servizio puo' leggere la cartella backend.
- [ ] L'account del servizio puo' leggere `appsettings.json`.
- [ ] L'account del servizio puo' raggiungere SQL Server.
- [ ] L'account del servizio ha permessi sui database necessari oppure usa credenziali SQL in connection string.

## 2. Database

### Database AdHoc

- [ ] Database AdHoc esistente.
- [ ] Nome database AdHoc annotato.
- [ ] Azienda AdHoc corretta identificata.
- [ ] Prefisso tabelle aziendali corretto identificato.
- [ ] Stored procedure FactoryFlow installata nel database AdHoc.
- [ ] Compatibility level SQL adeguato alla stored procedure.
- [ ] Tabelle AdHoc principali raggiungibili.

Annotazioni:

| Voce | Valore |
|---|---|
| Server SQL |  |
| Istanza SQL |  |
| Database AdHoc |  |
| Codice azienda |  |
| Prefisso azienda |  |
| Esercizio |  |

### Database FactoryFlow

- [ ] Database FactoryFlow creato.
- [ ] Script schema DB_FARMFLOW eseguito senza errori.
- [ ] Tabelle `FF_` presenti.
- [ ] Foreign key interne create.
- [ ] Indici principali creati.
- [ ] Nessuna foreign key punta al database AdHoc.

Annotazioni:

| Voce | Valore |
|---|---|
| Database FactoryFlow |  |
| Utente SQL / autenticazione |  |
| Data creazione |  |
| Tecnico |  |

### FF_CONFIG

Verificare che esista una sola configurazione attiva o comunque quella corretta per il cliente.

- [ ] `FF_CONFIG` contiene una riga attiva.
- [ ] `CodAziAdhoc` corretto.
- [ ] `PrefissoAzienda` corretto.
- [ ] `CausaleCarico` corretta.
- [ ] `CausaleScarico` corretta.
- [ ] `MagazzinoPFDefault` corretto.
- [ ] `MagazzinoComponentiDefault` corretto.
- [ ] `Attiva = 1`.

Valori installati:

| Campo | Valore |
|---|---|
| CodAziAdhoc |  |
| PrefissoAzienda |  |
| CausaleCarico |  |
| CausaleScarico |  |
| MagazzinoPFDefault |  |
| MagazzinoComponentiDefault |  |
| Attiva |  |

### Verifica causali su AdHoc

Le causali configurate in FactoryFlow identificano i documenti AdHoc. I dettagli documentali non devono essere duplicati in DB_FARMFLOW.

- [ ] La causale carico esiste in `[AZIENDA]TIP_DOCU`.
- [ ] La causale scarico esiste in `[AZIENDA]TIP_DOCU`.
- [ ] Da `TIP_DOCU` sono leggibili tipo documento, alfanumerico, causale magazzino e segno.
- [ ] I progressivi AdHoc collegati sono presenti in `cpwarn`.

## 3. Backend

### Publish

- [ ] Backend pubblicato in Release.
- [ ] Target framework verificato: `net8.0`.
- [ ] Cartella publish copiata sul server.
- [ ] File `FactoryFlow.Api.exe` presente.
- [ ] File `FactoryFlow.Api.dll` presente.
- [ ] File `FactoryFlow.Api.runtimeconfig.json` presente.
- [ ] `runtimeconfig` richiede .NET 8.

Cartella consigliata:

`C:\test\farm\backend`

oppure:

`C:\FactoryFlow\Backend`

### appsettings cliente

- [ ] `appsettings.json` presente nella cartella backend.
- [ ] Connection string AdHoc corretta.
- [ ] Connection string FactoryFlow corretta.
- [ ] `AdHoc:CodAzi` corretto.
- [ ] `AdHoc:Esercizio` corretto.
- [ ] `AdHoc:MagazzinoDefault` corretto.
- [ ] `TrustServerCertificate=True` presente se necessario.
- [ ] Nessun file di configurazione di sviluppo lasciato per errore.

### Avvio manuale

Prima di creare il servizio Windows, avviare il backend manualmente.

Comando indicativo:

`FactoryFlow.Api.exe --contentRoot <cartella_backend> --urls http://0.0.0.0:5100`

Verifiche:

- [ ] Il backend parte senza errori.
- [ ] La console indica ascolto sulla porta backend.
- [ ] `GET /api/configurazione/attiva` risponde.
- [ ] `GET /api/produzione/articoli` risponde.
- [ ] `GET /api/linee` risponde.

### Windows Service

- [ ] Eventuale servizio precedente rimosso o aggiornato.
- [ ] Servizio creato puntando a `FactoryFlow.Api.exe`.
- [ ] `--contentRoot` impostato sulla cartella backend.
- [ ] URL impostato su `http://0.0.0.0:5100` o porta scelta.
- [ ] Servizio impostato come automatico.
- [ ] Servizio avviato.
- [ ] Servizio risulta `Running`.

Nome servizio consigliato:

`FactoryFlowBackend`

oppure nome cliente/progetto:

`TestFarm`

### Test API obbligatori

| Test | URL | Atteso | Esito |
|---|---|---|---|
| Configurazione attiva | `/api/configurazione/attiva` | JSON con configurazione cliente | [ ] |
| Articoli producibili | `/api/produzione/articoli` | Lista o array JSON valido | [ ] |
| Linee produzione | `/api/linee` | Lista o array JSON valido | [ ] |

Se `produzione/articoli` restituisce `[]`, non e' automaticamente errore backend: verificare dati AdHoc, prefisso azienda, articoli con distinta e query.

## 4. Frontend Flutter Web

### Build

Il frontend deve essere compilato con i parametri reali del cliente.

- [ ] `BASE_URL` punta al backend raggiungibile dai client.
- [ ] `COD_AZI` corrisponde all'azienda AdHoc.
- [ ] `ESERCIZIO` corretto.
- [ ] `MAGAZZINO_DEFAULT` corretto.
- [ ] Build Flutter Web completata senza errori bloccanti.

Esempio valori:

| Parametro | Valore |
|---|---|
| BASE_URL | `http://<ip-server>:5100` |
| COD_AZI |  |
| ESERCIZIO |  |
| MAGAZZINO_DEFAULT |  |

La cartella pubblicabile e':

`frontend/factoryflow_flutter/build/web`

### Pubblicazione su IIS

- [ ] Cartella frontend creata sul server.
- [ ] Copiato il contenuto di `build/web`, non la cartella `web` intera.
- [ ] Nella cartella fisica e' presente direttamente `index.html`.
- [ ] Sito IIS creato.
- [ ] Physical path punta alla cartella frontend.
- [ ] Binding HTTP configurato.
- [ ] Porta frontend configurata.
- [ ] Sito avviato.

Cartelle consigliate:

`C:\test\farm\frontend`

oppure:

`C:\inetpub\testfarm`

Struttura attesa:

`C:\test\farm\frontend\index.html`

non:

`C:\test\farm\frontend\web\index.html`

### Test frontend

- [ ] Apertura da server: `http://localhost:<porta_frontend>`.
- [ ] Apertura da client: `http://<ip-server>:<porta_frontend>`.
- [ ] La pagina non resta bianca.
- [ ] Il menu e' visibile.
- [ ] La pagina iniziale e' `Calendario dichiarazioni`.
- [ ] Il frontend chiama correttamente il backend.
- [ ] Non compaiono errori CORS nella console browser.

### CORS

Il backend attualmente consente le chiamate dal frontend tramite policy CORS aperta per l'MVP.

Se in futuro si restringe il CORS:

- [ ] aggiungere l'origine reale del frontend;
- [ ] includere porta frontend;
- [ ] verificare HTTP/HTTPS coerenti.

## 5. Collaudo Funzionale

Il collaudo deve essere fatto con quantita' minime e articolo noto.

Non usare quantita' elevate durante il primo test cliente.

### Preparazione

- [ ] Articolo prodotto noto identificato.
- [ ] Distinta base presente in AdHoc.
- [ ] Componenti presenti e leggibili.
- [ ] Lotti disponibili verificati se necessari.
- [ ] Causali documentali corrette confermate.
- [ ] Progressivi AdHoc presenti.
- [ ] Backup o punto di ripristino disponibile se richiesto dal cliente.

### Linee produzione

- [ ] Creare una linea produzione da UI.
- [ ] Verificare che la linea compaia nell'elenco.
- [ ] Verificare flag `Attiva`.
- [ ] Associare almeno un articolo producibile alla linea.
- [ ] Verificare che l'articolo compaia tra quelli selezionabili nella dichiarazione.

### Dichiarazione futura PREVISTA

Scegliere una data successiva alla data odierna.

- [ ] Dal calendario selezionare un giorno futuro.
- [ ] Premere `Nuova`.
- [ ] Verificare che la data produzione sia quella selezionata.
- [ ] Inserire articolo, quantita' minima, lotto PF e componenti.
- [ ] Salvare la previsione.
- [ ] Verificare stato `PREVISTA` in UI.
- [ ] Verificare riga in `FF_DICHIARAZIONI_PRODUZIONE`.
- [ ] Verificare componenti in `FF_DICHIARAZIONI_COMPONENTI`.
- [ ] Verificare audit in `FF_AUDIT_EVENTI`.
- [ ] Verificare che i seriali AdHoc siano nulli.
- [ ] Verificare che non siano stati creati documenti AdHoc.
- [ ] Verificare che SALDILOT non sia stato modificato.

### Conferma dichiarazione odierna

Usare quantita' minima.

- [ ] Selezionare data odierna.
- [ ] Creare o aprire dichiarazione prevista per oggi.
- [ ] Confermare quantita' effettive.
- [ ] Confermare lotti componenti.
- [ ] Premere `Conferma produzione`.
- [ ] Verificare messaggio positivo in UI.
- [ ] Verificare stato `CONFERMATA`.
- [ ] Verificare seriale/numero carico salvati in FactoryFlow.
- [ ] Verificare seriale/numero scarico salvati in FactoryFlow.

### Verifiche AdHoc

- [ ] Record carico prodotto finito presente in `DOC_MAST`.
- [ ] Record scarico componenti presente in `DOC_MAST`.
- [ ] Righe carico presenti in `DOC_DETT`.
- [ ] Righe scarico presenti in `DOC_DETT`.
- [ ] Collegamento scarico-carico coerente.
- [ ] Lotti valorizzati dove previsto.
- [ ] SALDILOT aggiornato.
- [ ] Documento apribile in AdHoc.

### Verifiche DB_FARMFLOW

- [ ] `FF_DICHIARAZIONI_PRODUZIONE` popolata correttamente.
- [ ] `FF_DICHIARAZIONI_COMPONENTI` popolata correttamente.
- [ ] `FF_AUDIT_EVENTI` popolata correttamente.
- [ ] Stato dichiarazione coerente.
- [ ] Seriale AdHoc valorizzato solo dopo conferma.
- [ ] Nessuna cancellazione fisica indesiderata.

## 6. Regole Critiche

Queste regole non devono essere violate durante installazione, test o successive modifiche.

- [ ] Le previsioni future non scrivono AdHoc.
- [ ] Una dichiarazione futura resta solo in DB_FARMFLOW con stato `PREVISTA`.
- [ ] I seriali AdHoc valorizzati indicano dichiarazione confermata in ERP.
- [ ] La conferma in AdHoc deve avvenire solo tramite comando esplicito.
- [ ] La stored procedure resta il motore ufficiale di scrittura AdHoc.
- [ ] Il backend non deve ricostruire in C# la logica documentale AdHoc.
- [ ] La cancellazione e' logica, non fisica.
- [ ] Le linee dismesse vanno disattivate, non eliminate.
- [ ] AdHoc resta fonte ufficiale per articoli, distinte, lotti, documenti e saldi.
- [ ] DB_FARMFLOW non deve duplicare dati gia' governati da AdHoc.

## 7. Troubleshooting

### Backend non parte

Sintomi:

- il servizio non si avvia;
- errore in console;
- URL backend non risponde.

Controlli:

- [ ] .NET 8 Runtime installato.
- [ ] Pacchetto backend compilato per `net8.0`.
- [ ] `FactoryFlow.Api.exe` presente.
- [ ] `appsettings.json` valido.
- [ ] Connection string corrette.
- [ ] Porta backend libera.
- [ ] Permessi account servizio corretti.
- [ ] Log in Visualizzatore eventi Windows.

### Servizio Windows non avviato

Controlli:

- [ ] Il servizio punta a `FactoryFlow.Api.exe`.
- [ ] `--contentRoot` punta alla cartella backend.
- [ ] La cartella contiene `appsettings.json`.
- [ ] L'app e' stata configurata con supporto Windows Service.
- [ ] Avvio manuale dell'EXE funziona.

### Backend risponde ma configurazione mancante

Sintomo:

`Configurazione FactoryFlow attiva mancante.`

Controlli:

- [ ] Database FactoryFlow corretto nella connection string.
- [ ] Tabella `FF_CONFIG` presente.
- [ ] Riga `Attiva = 1` presente.
- [ ] Valori azienda e prefisso corretti.

### `GET /api/produzione/articoli` restituisce vuoto

Possibili cause:

- azienda/prefisso errati;
- articoli senza distinta valorizzata;
- query AdHoc da verificare sul cliente;
- dati AdHoc non presenti nell'ambiente di test;
- permessi SQL insufficienti.

Controlli:

- [ ] Prefisso azienda in `FF_CONFIG` corretto.
- [ ] Articoli con distinta esistenti in `[AZIENDA]ART_ICOL`.
- [ ] `ARCODDIS` valorizzato.
- [ ] Utente SQL vede le tabelle AdHoc.

### Frontend pagina bianca

Controlli:

- [ ] File copiati correttamente.
- [ ] `index.html` e' nella root della cartella IIS.
- [ ] Browser cache svuotata o URL con parametro cache-buster.
- [ ] Console browser senza errori JavaScript bloccanti.
- [ ] MIME type per `.wasm` se necessario.
- [ ] IIS serve correttamente file statici.

### BASE_URL errato

Sintomi:

- UI visibile ma dati non caricano;
- errori di rete nel browser;
- chiamate a `localhost:5100` da un client remoto.

Soluzione:

- [ ] Ricompilare Flutter Web con `BASE_URL` reale.
- [ ] Usare IP o nome server raggiungibile dai client.
- [ ] Verificare porta backend aperta.

### Porta bloccata

Controlli:

- [ ] Verificare processo in ascolto sulla porta.
- [ ] Cambiare porta o fermare processo precedente.
- [ ] Aggiornare firewall.
- [ ] Aggiornare build frontend se cambia porta backend.

### CORS

Sintomi:

- il backend risponde da browser diretto;
- il frontend non riesce a chiamarlo;
- console browser mostra errore CORS.

Controlli:

- [ ] Policy CORS backend attiva.
- [ ] Origine frontend inclusa, se CORS ristretto.
- [ ] HTTP/HTTPS coerenti.
- [ ] Porta frontend corretta.

### Stored procedure fallisce

Controlli:

- [ ] Stored procedure installata nel database AdHoc corretto.
- [ ] Compatibility level adeguato.
- [ ] Causali configurate corrette.
- [ ] Progressivi `cpwarn` presenti.
- [ ] Lotti validi.
- [ ] Parametri ricevuti dal backend corretti.
- [ ] Errore SQL completo acquisito.

### SALDILOT non aggiornato

Controlli:

- [ ] La dichiarazione e' `CONFERMATA`, non `PREVISTA`.
- [ ] I documenti AdHoc sono stati creati.
- [ ] I lotti sono valorizzati sulle righe interessate.
- [ ] La stored procedure contiene la logica di aggiornamento SALDILOT.
- [ ] `MVLOTMAG`, `MVCODLOT`, `MVKEYSAL` e campi lotto sono coerenti.
- [ ] Confrontare con documento manuale AdHoc se necessario.

## 8. Report Finale Installazione

Compilare a fine intervento.

| Voce | Valore |
|---|---|
| Cliente |  |
| Data installazione |  |
| Tecnico |  |
| Server applicativo |  |
| IP server |  |
| Database AdHoc |  |
| Database FactoryFlow |  |
| Azienda |  |
| Backend URL |  |
| Frontend URL |  |
| Servizio Windows |  |
| Esito configurazione attiva |  |
| Esito articoli producibili |  |
| Esito previsione futura |  |
| Esito conferma produzione |  |
| Esito verifica AdHoc |  |
| Esito SALDILOT |  |
| Note/anomalie |  |

## 9. Autorizzazione al Rilascio

Il rilascio cliente puo' essere considerato completato solo se:

- [ ] backend avviato come servizio;
- [ ] frontend raggiungibile da client;
- [ ] configurazione attiva letta correttamente;
- [ ] dati AdHoc leggibili;
- [ ] previsione futura salvata senza scrivere AdHoc;
- [ ] dichiarazione confermata scrive documenti AdHoc;
- [ ] SALDILOT aggiornato;
- [ ] storico FactoryFlow popolato;
- [ ] audit popolato;
- [ ] eventuali anomalie documentate.
