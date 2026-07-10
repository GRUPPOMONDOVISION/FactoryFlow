# FactoryFlow - Manifesto

## Perché Nasce FactoryFlow

FactoryFlow nasce da un'esigenza concreta: portare la gestione della produzione più vicino alle persone che lavorano ogni giorno in fabbrica.

Molte aziende possiedono già un sistema ERP solido, ricco di dati e centrale per la vita aziendale. In questo progetto quel sistema è AdHoc Revolution. Dentro AdHoc vivono articoli, distinte, magazzino, lotti, documenti, clienti, fornitori, contabilità e molte delle regole che governano l'azienda.

Il problema non è sostituire tutto questo.

Il problema è rendere più semplice, più veloce e più moderno l'uso operativo di queste informazioni nel contesto della produzione.

FactoryFlow nasce per colmare questo spazio: non un nuovo ERP, non un duplicato, non un sistema parallelo, ma uno strumento progettato per rendere più fluido il lavoro tra ufficio, reparto produttivo e dati gestionali ufficiali.

## Quale Problema Risolve

In molte realtà produttive, i dati esistono già, ma non sempre sono facili da usare nel momento in cui servono.

L'operatore deve dichiarare una produzione. Il responsabile vuole capire cosa è stato prodotto. Il consulente deve verificare coerenza tra distinta, lotti e magazzino. L'imprenditore vuole conoscere meglio la fabbrica, non solo a fine mese, ma mentre il lavoro accade.

FactoryFlow risolve questo problema costruendo un'interfaccia e un metodo di lavoro orientati alla produzione reale.

Il suo compito è rendere disponibili le informazioni giuste, nel punto giusto, con il minor attrito possibile.

Non nasce per accumulare dati. Nasce per rendere i dati utili.

## La Filosofia FactoryFlow

FactoryFlow non nasce per registrare dati.

Nasce per aiutare le aziende a prendere decisioni migliori.

Ogni informazione memorizzata deve avere uno scopo preciso. Se un dato non serve a decidere, controllare, spiegare, migliorare o semplificare il lavoro, probabilmente non deve essere salvato.

Ogni funzionalità deve essere valutata non solo per ciò che fa, ma per come cambia il lavoro delle persone.

Una buona funzione non aggiunge complessità. La riduce.

Una buona schermata non mostra tutto. Mostra ciò che serve.

Una buona architettura non nasce per impressionare. Nasce per durare.

FactoryFlow deve rimanere fedele a questa idea: la tecnologia ha valore solo quando rende più chiaro, più affidabile e più semplice il lavoro umano.

## Il Rapporto Con AdHoc

AdHoc rimane il sistema ERP ufficiale.

FactoryFlow estende AdHoc. Non lo sostituisce.

AdHoc continua a essere la fonte ufficiale per articoli, distinte, documenti, magazzino, lotti, contabilità, costi standard, cicli, clienti e fornitori.

FactoryFlow non deve duplicare queste informazioni. Deve leggerle, rispettarle e valorizzarle.

Questo principio è essenziale.

Duplicare dati ERP significa creare due verità. E quando esistono due verità, prima o poi una delle due diventa sbagliata.

FactoryFlow deve evitare questa trappola. Deve appoggiarsi ad AdHoc dove AdHoc è già forte, e aggiungere valore solo dove serve davvero: esperienza operativa, tracciabilità applicativa, pianificazione moderna, raccolta dati di fabbrica, analisi industriale e strumenti decisionali.

## Perché Usiamo Le Tabelle Ufficiali AdHoc

Abbiamo scelto di utilizzare direttamente le strutture ufficiali di AdHoc perché vogliamo che FactoryFlow lavori sulla realtà gestionale dell'azienda, non su una copia.

Quando un documento viene creato, deve essere un documento vero.

Quando una giacenza viene aggiornata, deve essere la giacenza ufficiale.

Quando un lotto viene movimentato, deve essere il lotto governato da AdHoc.

Questa scelta richiede attenzione, rigore e conoscenza del dominio. Non è la strada più superficiale, ma è quella più coerente con l'obiettivo del progetto.

FactoryFlow non deve produrre dati isolati. Deve produrre effetti corretti nel sistema gestionale ufficiale.

## Perché Esiste DB_FARMFLOW

Se AdHoc rimane la fonte ufficiale, perché creare un database FactoryFlow?

Perché non tutto appartiene all'ERP.

FactoryFlow ha bisogno di conservare informazioni proprie: configurazioni applicative, storico delle operazioni eseguite dall'applicazione, preferenze operative, dati di supporto, pianificazioni, simulazioni, rilevazioni di reparto e analisi industriali.

Questi dati non devono essere forzati dentro AdHoc se non appartengono al suo dominio.

`DB_FARMFLOW` esiste per custodire ciò che è proprio di FactoryFlow.

Non deve diventare un secondo archivio articoli. Non deve diventare un secondo magazzino. Non deve diventare una copia delle distinte o dei documenti.

Deve essere un database pulito, essenziale e coerente, costruito per contenere solo ciò che serve alla piattaforma MES.

## Non Duplicare I Dati ERP

Uno dei principi più importanti del progetto è semplice: non duplicare dati già governati da AdHoc.

Duplicare sembra comodo all'inizio. Permette di andare veloci, evitare domande e costruire schermate rapidamente.

Ma nel tempo diventa una fragilità.

Un articolo cambia descrizione. Una distinta viene aggiornata. Una causale viene modificata. Un lotto viene movimentato. Se FactoryFlow conserva copie di questi dati senza una ragione precisa, il sistema inizia a raccontare versioni diverse della stessa azienda.

Questo non deve accadere.

FactoryFlow può conservare riferimenti. Può conservare snapshot quando servono per audit o spiegazione storica. Può salvare ciò che l'operatore ha visto e scelto in un determinato momento.

Ma non deve duplicare la verità gestionale.

La verità gestionale resta in AdHoc.

## Progettare Prima Di Sviluppare

FactoryFlow è pensato per crescere negli anni.

Per questo la velocità non può essere l'unico criterio.

Una funzione scritta in fretta può sembrare utile oggi e diventare un ostacolo domani. Una tabella creata senza una vera motivazione può trasformarsi in debito architetturale. Un campo aggiunto per comodità può creare ambiguità nel dominio.

Per questo preferiamo progettare prima di sviluppare.

Prima di creare una tabella, dobbiamo chiederci perché esiste.

Prima di salvare un campo, dobbiamo chiederci a chi appartiene quel dato.

Prima di duplicare un'informazione, dobbiamo chiederci se stiamo costruendo valore o confusione.

Questa disciplina non rallenta il progetto. Lo protegge.

## Il Ruolo Della Documentazione

La documentazione non è un allegato.

È parte integrante del software.

Ogni decisione importante deve essere spiegata. Non basta sapere cosa è stato fatto; bisogna poter capire perché è stato fatto.

Il codice può cambiare. L'architettura può evolvere. Le tecnologie possono essere sostituite. Ma la filosofia del progetto deve rimanere riconoscibile.

Una buona documentazione permette a chi entra nel progetto dopo mesi o anni di non ripartire da zero. Permette di distinguere una scelta intenzionale da un errore. Permette di mantenere coerenza anche quando il prodotto cresce.

FactoryFlow deve essere documentato perché deve essere mantenibile.

E deve essere mantenibile perché è pensato per durare.

## Ogni Scelta Deve Essere Motivata

In FactoryFlow non basta dire "serve una tabella".

Bisogna spiegare perché serve.

Non basta dire "serve un campo".

Bisogna spiegare quale informazione rappresenta, chi la governa e cosa succede se cambia.

Non basta aggiungere una funzionalità perché è tecnicamente possibile.

Bisogna capire se migliora davvero il lavoro, se rispetta il dominio e se non crea duplicazioni inutili.

Questa regola vale per tutti: analisti, consulenti, sviluppatori e responsabili del progetto.

La qualità di FactoryFlow dipenderà dalla qualità delle sue decisioni.

## Guardando Al Futuro

FactoryFlow nasce oggi dalla gestione della produzione, ma è progettato per diventare progressivamente una piattaforma completa per la gestione della fabbrica.

Produzione.

Pianificazione.

MRP.

MES.

Capacità produttiva.

Monitoraggio.

Dashboard.

Intelligenza Artificiale.

Tutto questo potrà entrare nel prodotto, ma dovrà farlo mantenendo la stessa filosofia.

Ogni nuovo modulo dovrà rispettare AdHoc come fonte ufficiale quando il dato appartiene all'ERP.

Ogni nuovo dato salvato in FactoryFlow dovrà avere una ragione chiara.

Ogni nuova funzionalità dovrà migliorare il lavoro delle persone, non solo aggiungere possibilità tecniche.

La crescita del prodotto non dovrà sacrificare la pulizia del dominio.

## Un Messaggio A Chi Svilupperà FactoryFlow

Se stai entrando in questo progetto, il tuo compito non è semplicemente scrivere codice.

Il tuo compito è mantenere coerente una visione.

Ogni riga che scrivi, ogni tabella che proponi, ogni campo che aggiungi e ogni scorciatoia che scegli avrà un effetto sulla vita futura del prodotto.

FactoryFlow deve poter essere capito, modificato e migliorato anche fra dieci anni.

Questo richiede attenzione. Richiede rispetto per il dominio. Richiede la capacità di fermarsi quando una richiesta sembra utile ma rischia di sporcare l'architettura.

Il codice è importante, ma viene dopo.

Prima viene la comprensione.

Prima viene la coerenza.

Prima viene il progetto.

FactoryFlow sarà un buon prodotto solo se chi lo costruisce saprà proteggere questa visione.
