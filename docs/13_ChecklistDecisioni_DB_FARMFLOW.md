# FactoryFlow - Checklist Decisioni DB_FARMFLOW

## Scopo Del Documento

Questo documento deriva dalla sezione "Questioni Aperte Prima Dello Script SQL" di `docs/12_SchemaFisico_DB_FARMFLOW.md`.

L'obiettivo e chiudere le decisioni progettuali prima di generare lo script SQL definitivo di `DB_FARMFLOW`.

Non contiene SQL e non contiene modifiche tecniche. E una checklist decisionale finale.

## 1. Configurazioni Storiche In FF_CONFIG

Questione: decidere se `FF_CONFIG` deve permettere piu configurazioni storiche per la stessa azienda o imporre una sola configurazione attiva.

Spiegazione semplice: nel tempo potrebbero cambiare causali, magazzini default o prefisso aziendale. Serve decidere se conservare le vecchie configurazioni per storico oppure sovrascrivere sempre quella esistente.

Scelta consigliata: permettere piu configurazioni storiche, ma una sola configurazione attiva per azienda.

Motivo: consente di sapere quale configurazione era valida quando una produzione e stata registrata, senza creare ambiguita operativa.

Impatto se scegliamo male: se permettiamo piu configurazioni attive, FactoryFlow potrebbe usare causali o magazzini sbagliati. Se non conserviamo lo storico, in futuro sara difficile spiegare vecchie registrazioni.

Decisione da confermare: una sola configurazione attiva per `CodAziAdhoc` e `PrefissoAzienda`, mantenendo le configurazioni disattivate come storico.

## 2. Stati Applicativi Controllati

Questione: stabilire l'elenco controllato degli stati applicativi per produzioni, linee, macchine, piani e simulazioni.

Spiegazione semplice: campi come `StatoFactoryFlow`, `StatoOperativo`, `StatoPiano` e `StatoSimulazione` non devono diventare testo libero scritto ogni volta in modo diverso.

Scelta consigliata: definire liste chiuse di stati applicativi documentate, ma non creare subito tabelle dedicate agli stati.

Motivo: nella prima fase bastano valori controllati dall'applicazione. Le tabelle di dominio possono essere aggiunte solo se serviranno configurazioni dinamiche.

Impatto se scegliamo male: testo libero non governato produce dati sporchi, filtri incoerenti e report poco affidabili. Troppe tabelle di dominio introdotte subito rendono il modello piu pesante del necessario.

Decisione da confermare: usare valori applicativi controllati e documentati; introdurre tabelle stati solo quando servira configurabilita da interfaccia.

## 3. Formato Audit Valori Sintesi

Questione: decidere se gli audit `ValoriPrecedentiSintesi`, `ValoriNuoviSintesi` e `ValoriCancellatiSintesi` devono essere testo libero o formato strutturato.

Spiegazione semplice: quando FactoryFlow registra una modifica o cancellazione, deve salvare cosa e cambiato. Questo puo essere una frase leggibile oppure una struttura dati piu precisa.

Scelta consigliata: usare formato strutturato testuale, con contenuto leggibile e stabile.

Motivo: consente audit leggibile dagli operatori e anche analisi futura da parte del sistema. Il testo libero puro e comodo all'inizio, ma fragile.

Impatto se scegliamo male: con testo libero sara difficile cercare differenze e ricostruire cambiamenti. Con un formato troppo rigido rischiamo invece di complicare l'audit prima di averne bisogno.

Decisione da confermare: salvare sintesi strutturate ma non normalizzare ogni singolo campo modificato in tabelle separate.

## 4. Righe Duplicate In FF_PRODUZIONE_COMPONENTI

Questione: chiarire se `FF_PRODUZIONE_COMPONENTI` deve consentire righe duplicate per stesso componente, lotto e magazzino nella stessa produzione.

Spiegazione semplice: lo stesso componente potrebbe comparire piu volte se arriva da righe distinta diverse, se viene suddiviso su piu lotti o se l'operatore fa scelte operative particolari.

Scelta consigliata: consentire righe multiple, ma distinguere le righe con una chiave surrogate e, se possibile, con un numero riga operativo.

Motivo: vietare duplicati troppo presto rischia di bloccare casi reali di produzione. La tabella e uno snapshot operativo, non una distinta normalizzata.

Impatto se scegliamo male: se imponiamo un vincolo troppo stretto, alcune produzioni reali non saranno registrabili. Se permettiamo duplicati senza ordine o contesto, l'audit diventera poco chiaro.

Decisione da confermare: consentire duplicati controllati e valutare l'aggiunta di un campo `NumeroRiga` nello script fisico.

## 5. Univocita Seriali AdHoc In FF_PRODUZIONI

Questione: definire se i seriali AdHoc in `FF_PRODUZIONI` devono essere univoci obbligatori quando valorizzati.

Spiegazione semplice: ogni registrazione FactoryFlow dovrebbe puntare a documenti AdHoc generati una sola volta. Lo stesso seriale AdHoc non dovrebbe comparire su piu produzioni FactoryFlow.

Scelta consigliata: rendere univoci i seriali AdHoc quando valorizzati.

Motivo: il seriale AdHoc e il collegamento piu forte tra audit FactoryFlow e documento ufficiale. Duplicarlo creerebbe ambiguita.

Impatto se scegliamo male: senza univocita, potremmo avere due registrazioni FactoryFlow che sembrano riferirsi allo stesso documento AdHoc. Con un vincolo troppo rigido ma mal disegnato, potremmo bloccare record ancora in errore o non confermati.

Decisione da confermare: usare vincoli univoci filtrati sui seriali non nulli.

## 6. Introduzione Tabelle Future

Questione: decidere quando introdurre fisicamente tabelle future come linee, macchine, pianificazione, simulazioni, costi e rilevazioni.

Spiegazione semplice: il modello le prevede, ma non e detto che debbano nascere tutte nel primo script.

Scelta consigliata: creare subito solo il nucleo necessario e rimandare le tabelle dei moduli futuri finche la funzionalita non viene progettata nel dettaglio.

Motivo: riduce complessita iniziale e migrazioni inutili. Una tabella non usata tende a invecchiare male.

Impatto se scegliamo male: creando tutto subito rischiamo uno schema grande, non testato e forse sbagliato. Creando troppo poco, potremmo dover fare migrazioni ravvicinate, ma questo e un rischio piu gestibile.

Decisione da confermare: primo script con `FF_CONFIG`, `FF_PRODUZIONI`, `FF_PRODUZIONE_COMPONENTI`, audit minimo; moduli futuri in script successivi.

## 7. Relazione Macchine-Linee

Questione: chiarire se `FF_MACCHINE` deve essere obbligatoriamente figlia di una linea o se puo restare autonoma.

Spiegazione semplice: alcune aziende ragionano sempre per linee, altre hanno macchine indipendenti o usate in piu contesti.

Scelta consigliata: mantenere `IdLinea` nullable.

Motivo: lascia flessibilita. Una macchina puo essere autonoma all'inizio e associata a una linea in seguito.

Impatto se scegliamo male: se rendiamo la linea obbligatoria, obblighiamo il cliente a modellare linee anche quando non servono. Se la lasciamo libera senza regole, la pianificazione potrebbe diventare incoerente.

Decisione da confermare: macchina autonoma ammessa; quando usata in pianificazione, le regole applicative decidono se richiedere linea, macchina o entrambe.

## 8. Scala Quantita E Valori Monetari

Questione: definire la scala definitiva dei campi quantitativi e monetari se AdHoc usa precisioni diverse in installazioni future.

Spiegazione semplice: quantita e costi devono avere abbastanza decimali per non perdere precisione, ma senza diventare incoerenti con AdHoc.

Scelta consigliata: usare `DECIMAL(18, 6)` come standard iniziale per quantita e costi calcolati.

Motivo: e una precisione ampia e prudente per produzione, consumi e costi industriali.

Impatto se scegliamo male: con pochi decimali si introducono arrotondamenti pericolosi. Con precisioni diverse tra tabelle si creano incongruenze nei calcoli e nei report.

Decisione da confermare: standard `DECIMAL(18, 6)`, salvo singole eccezioni motivate prima dello script.

## 9. Policy Di Cancellazione

Questione: stabilire una policy di cancellazione: logica sui dati configurativi e fisica solo su dati temporanei.

Spiegazione semplice: per un prodotto destinato a durare anni, cancellare dati importanti senza traccia e pericoloso.

Scelta consigliata: usare cancellazione logica o disattivazione per configurazioni, linee, macchine, associazioni, piani e dati di audit. Riservare cancellazione fisica solo a dati tecnici temporanei.

Motivo: protegge storico, tracciabilita e possibilita di spiegare decisioni passate.

Impatto se scegliamo male: cancellazioni fisiche su dati importanti possono rompere audit e relazioni storiche. Solo cancellazioni logiche ovunque, invece, possono appesantire tabelle temporanee se non governate.

Decisione da confermare: aggiungere flag di attivazione/stato dove serve e registrare cancellazioni in audit.

## 10. Formato Riferimenti Esterni AdHoc

Questione: definire il formato dei riferimenti esterni AdHoc quando non basta un solo codice testuale.

Spiegazione semplice: alcuni riferimenti AdHoc sono semplici, come un codice articolo. Altri sono composti, come documento, seriale, numero, esercizio, alfanumerico o riga.

Scelta consigliata: usare campi specifici quando il riferimento e stabile e importante; usare `RiferimentoAdHoc` testuale solo per riferimenti generici o futuri.

Motivo: i riferimenti principali devono essere interrogabili e affidabili. Un unico campo testuale e comodo ma debole per report e controlli.

Impatto se scegliamo male: se mettiamo tutto in un campo generico, poi sara difficile filtrare, collegare e verificare i dati. Se normalizziamo troppo presto ogni possibile riferimento AdHoc, appesantiamo lo schema e rischiamo di copiare logiche AdHoc.

Decisione da confermare: per produzione mantenere campi dedicati a seriali e numeri documento; per moduli futuri usare `RiferimentoAdHoc` finche il dominio non e stabile.

## Checklist Finale Prima Dello Script

- Confermare una sola `FF_CONFIG` attiva per azienda/prefisso.
- Confermare liste chiuse di stati applicativi gestite dall'applicazione.
- Confermare audit in formato strutturato testuale.
- Confermare duplicati controllati in `FF_PRODUZIONE_COMPONENTI`.
- Confermare univocita filtrata dei seriali AdHoc quando valorizzati.
- Confermare primo script limitato al nucleo minimo.
- Confermare `FF_MACCHINE.IdLinea` nullable.
- Confermare `DECIMAL(18, 6)` per quantita e costi.
- Confermare cancellazione logica per dati configurativi e storici.
- Confermare riferimenti AdHoc dedicati solo per legami stabili e importanti.

## Raccomandazione Complessiva

La scelta piu prudente e partire con un nucleo fisico piccolo ma ben governato:

- configurazione;
- registrazioni FactoryFlow;
- componenti dichiarati;
- audit.

Linee, macchine, pianificazione, simulazioni, rilevazioni e costi industriali devono restare progettati ma non necessariamente creati nel primo script.

Questo mantiene `DB_FARMFLOW` coerente con l'architettura: estendere AdHoc senza duplicarlo.

## Decisione Applicata Per MVP Giovedi

Per il primo MVP operativo si conferma la scelta prudente:

- creare subito solo il nucleo minimo;
- mantenere una sola configurazione attiva per azienda/prefisso;
- introdurre linee operative e associazioni articolo-linea;
- salvare storico FactoryFlow solo dopo conferma AdHoc riuscita;
- non introdurre ancora pianificazione, MRP, dashboard o costi industriali completi.

La duplicazione di descrizioni articolo e unita di misura resta vietata nelle tabelle operative di configurazione o associazione. Nelle dichiarazioni e ammesso solo lo snapshot storico di quanto mostrato/confermato dall'operatore.
