# FactoryFlow Language

## Premessa

FactoryFlow non descrive software.

FactoryFlow descrive una fabbrica.

Le tabelle, le API, il codice, il database e le interfacce sono soltanto strumenti. Sono importanti, ma non sono il cuore del progetto.

La vera piattaforma e' il linguaggio condiviso.

Ogni parola usata in FactoryFlow deve avere un significato unico, preciso e riconoscibile. Se una parola cambia significato a seconda di chi la usa, il progetto diventa fragile. Se lo stesso concetto viene chiamato in modi diversi, il software comincia a duplicare idee, non solo dati.

Questo documento definisce il linguaggio ufficiale di FactoryFlow. Deve essere leggibile da imprenditori, responsabili produzione, consulenti, analisti, sviluppatori e futuri manutentori.

FactoryFlow nasce per aiutare una fabbrica a comprendere se stessa, organizzare il lavoro e prendere decisioni migliori. Per farlo, prima ancora di scrivere codice, deve sapere nominare correttamente le cose.

## Fabbrica

### Definizione

La fabbrica e' l'insieme organizzato di persone, risorse, materiali, regole, tempi, vincoli e decisioni che trasformano input in prodotti finiti.

### Perche' esiste

Esiste per dare un contesto unitario a tutto cio' che FactoryFlow osserva e coordina. Una produzione, una linea, una macchina o un lotto hanno senso solo dentro il sistema piu' grande chiamato fabbrica.

### Cosa NON significa

Non significa solo edificio fisico.

Non significa solo stabilimento.

Non significa solo reparto produttivo.

Non e' una tabella anagrafica.

### Relazioni con gli altri concetti

La fabbrica contiene reparti, linee, macchine, operatori, calendari, capacita', attivita' produttive, costi, ordini e decisioni.

FactoryFlow descrive la fabbrica collegando questi concetti tra loro.

### Esempi pratici

Una fabbrica puo' avere piu' reparti.

Una fabbrica puo' usare AdHoc come ERP ufficiale e FactoryFlow come piattaforma MES.

Una fabbrica puo' pianificare oggi produzioni che verranno confermate domani.

### In FactoryFlow diciamo...

NON diciamo:

"Il software gestisce dati di produzione."

Diciamo:

"FactoryFlow descrive come la fabbrica organizza e conferma il lavoro produttivo."

## Reparto

### Definizione

Il reparto e' una parte organizzativa della fabbrica con una funzione produttiva o operativa riconoscibile.

### Perche' esiste

Esiste per raggruppare linee, macchine, operatori e attivita' secondo una logica aziendale comprensibile.

### Cosa NON significa

Non e' necessariamente una stanza.

Non e' una linea di produzione.

Non e' una macchina.

Non e' un centro di costo, anche se puo' essere collegato a logiche di costo.

### Relazioni con gli altri concetti

Un reparto puo' contenere piu' linee di produzione.

Un reparto puo' avere una capacita' produttiva complessiva.

Un reparto puo' essere coinvolto nella pianificazione e nell'analisi dei costi.

### Esempi pratici

Reparto confezionamento.

Reparto tostatura.

Reparto assemblaggio.

### In FactoryFlow diciamo...

NON diciamo:

"Questa macchina e' un reparto."

Diciamo:

"Questa macchina appartiene a un reparto."

## Linea di produzione

### Definizione

La linea di produzione e' un insieme operativo su cui possono essere svolte attivita' produttive per uno o piu' articoli.

### Perche' esiste

Esiste per collegare il prodotto da realizzare alla risorsa produttiva concreta su cui l'operatore lavora.

### Cosa NON significa

Non e' un articolo.

Non e' una macchina singola, anche se puo' coincidere con una macchina in impianti semplici.

Non e' una dichiarazione di produzione.

Non deve essere cancellata quando viene dismessa.

### Relazioni con gli altri concetti

Una linea puo' essere associata a molti prodotti finiti.

Una linea puo' contenere macchine.

Una linea puo' avere capacita', calendario, storico produzioni e rendimento.

Una dichiarazione di produzione puo' essere collegata a una linea.

### Esempi pratici

Linea confezionamento 1.

Linea blister.

Linea miscelazione.

### In FactoryFlow diciamo...

NON diciamo:

"Cancello la linea vecchia."

Diciamo:

"Disattivo la linea, mantenendo lo storico delle produzioni collegate."

## Macchina

### Definizione

La macchina e' una risorsa fisica o tecnica usata per eseguire una parte del processo produttivo.

### Perche' esiste

Esiste per descrivere vincoli, capacita', prestazioni, tempi, fermi, setup, energia e rendimento a livello piu' preciso della linea.

### Cosa NON significa

Non e' sempre sinonimo di linea.

Non e' un operatore.

Non e' un'attivita' produttiva.

Non e' un documento ERP.

### Relazioni con gli altri concetti

Una macchina puo' appartenere a una linea.

Una macchina consuma tempo, energia e capacita'.

Una macchina puo' influenzare costi industriali, pianificazione e decisioni.

### Esempi pratici

Confezionatrice.

Miscelatore.

Etichettatrice.

Forno.

### In FactoryFlow diciamo...

NON diciamo:

"La macchina ha prodotto un ordine."

Diciamo:

"L'attivita' produttiva e' stata eseguita sulla macchina indicata."

## Risorsa

### Definizione

Una risorsa e' qualsiasi elemento limitato che la fabbrica usa per produrre: linea, macchina, operatore, tempo, capacita', energia o attrezzatura.

### Perche' esiste

Esiste per ragionare sui vincoli. Una fabbrica decide bene solo se conosce quali risorse sono disponibili, occupate, insufficienti o critiche.

### Cosa NON significa

Non significa solo macchina.

Non significa solo persona.

Non e' necessariamente un bene fisico.

Non e' un articolo di magazzino.

### Relazioni con gli altri concetti

Le risorse vengono usate dalle attivita' produttive.

Le risorse determinano capacita', pianificazione, tempi e costi.

### Esempi pratici

Una linea libera oggi.

Un operatore specializzato.

Un turno disponibile.

Una macchina in manutenzione.

### In FactoryFlow diciamo...

NON diciamo:

"Ho risorse infinite per produrre."

Diciamo:

"La produzione deve rispettare la disponibilita' delle risorse."

## Attivita' produttiva

### Definizione

L'attivita' produttiva e' il lavoro pianificato o eseguito per trasformare materiali e risorse in un risultato produttivo.

### Perche' esiste

Esiste per distinguere il lavoro da svolgere dalla registrazione finale del lavoro svolto.

### Cosa NON significa

Non e' necessariamente gia' una produzione confermata.

Non e' un documento ERP.

Non e' solo una riga di calendario.

### Relazioni con gli altri concetti

Un'attivita' produttiva puo' essere pianificata nel calendario.

Puo' diventare dichiarazione di produzione.

Consuma componenti, tempo, capacita' ed energia.

### Esempi pratici

Domani mattina confezionare 500 pezzi dell'articolo X.

Oggi miscelare 100 kg di prodotto Y.

### In FactoryFlow diciamo...

NON diciamo:

"Ho fatto una produzione" quando e' solo pianificata.

Diciamo:

"Ho pianificato un'attivita' produttiva."

## Produzione

### Definizione

La produzione e' il risultato operativo della trasformazione di componenti, risorse e lavoro in prodotto finito.

### Perche' esiste

Esiste per rappresentare un fatto produttivo rilevante per la fabbrica.

### Cosa NON significa

Non significa sempre documento ERP.

Non significa sempre dichiarazione confermata.

Non significa previsione.

### Relazioni con gli altri concetti

La produzione puo' nascere da un'attivita' produttiva pianificata.

La produzione viene registrata tramite una dichiarazione di produzione.

Quando confermata, genera documenti ERP.

### Esempi pratici

Produzione di 100 pezzi di prodotto finito.

Produzione confermata con consumo componenti.

### In FactoryFlow diciamo...

NON diciamo:

"La produzione futura ha gia' scaricato i componenti."

Diciamo:

"La produzione futura e' una previsione finche' non viene confermata."

## Dichiarazione di produzione

### Definizione

La dichiarazione di produzione e' l'atto con cui l'operatore registra o conferma cio' che e' stato prodotto e quali componenti sono stati consumati.

### Perche' esiste

Esiste per collegare il lavoro reale della fabbrica ai documenti ufficiali dell'ERP.

### Cosa NON significa

Non e' sempre una registrazione AdHoc.

Non e' sempre confermata.

Non e' una semplice nota operativa.

### Relazioni con gli altri concetti

La dichiarazione puo' essere `PREVISTA`, `CONFERMATA` o `ANNULLATA`.

Se confermata, genera documenti ERP.

Contiene prodotto finito, quantita', lotti, componenti e linea.

### Esempi pratici

Dichiarazione prevista per domani.

Dichiarazione confermata oggi con seriali AdHoc.

### In FactoryFlow diciamo...

NON diciamo:

"La dichiarazione futura ha gia' generato AdHoc."

Diciamo:

"La dichiarazione futura e' PREVISTA e non ha seriali AdHoc."

## Documento ERP

### Definizione

Il documento ERP e' la registrazione ufficiale creata nel sistema gestionale AdHoc.

### Perche' esiste

Esiste per rendere ufficiale, contabile e gestionale il movimento di produzione, carico o scarico.

### Cosa NON significa

Non e' una previsione.

Non e' una simulazione.

Non e' un dato interno FactoryFlow.

### Relazioni con gli altri concetti

Una dichiarazione confermata genera documenti ERP.

I documenti ERP aggiornano magazzino, lotti e saldi secondo le regole AdHoc.

### Esempi pratici

Documento di carico prodotto finito.

Documento di scarico componenti.

### In FactoryFlow diciamo...

NON diciamo:

"FactoryFlow sostituisce il documento ERP."

Diciamo:

"FactoryFlow genera il documento ERP quando la produzione viene confermata."

## Distinta base

### Definizione

La distinta base e' la struttura che definisce quali componenti servono per produrre un prodotto finito.

### Perche' esiste

Esiste per calcolare fabbisogni, componenti teorici, consumi previsti e quantita' proposte.

### Cosa NON significa

Non e' una produzione.

Non e' una giacenza.

Non e' una disponibilita'.

Non deve essere duplicata in DB_FARMFLOW se gia' gestita da AdHoc.

### Relazioni con gli altri concetti

La distinta collega prodotto finito e componenti.

La dichiarazione usa la distinta per proporre i consumi.

MRP e pianificazione usano la distinta per simulare fabbisogni.

### Esempi pratici

Per produrre 1 kg di prodotto A servono 0,3 kg di componente B.

### In FactoryFlow diciamo...

NON diciamo:

"FactoryFlow possiede la distinta."

Diciamo:

"FactoryFlow legge la distinta ufficiale da AdHoc."

## Componente

### Definizione

Il componente e' un articolo consumato per produrre un prodotto finito.

### Perche' esiste

Esiste per descrivere cio' che viene scaricato, consumato o richiesto dalla produzione.

### Cosa NON significa

Non e' il prodotto finito della stessa dichiarazione.

Non e' necessariamente gestito a lotto.

Non e' una riga generica senza significato produttivo.

### Relazioni con gli altri concetti

Il componente appartiene a una distinta.

Il componente puo' avere lotti e disponibilita'.

Il componente viene consumato dalla dichiarazione confermata.

### Esempi pratici

Materia prima.

Imballo.

Semilavorato usato in produzione.

### In FactoryFlow diciamo...

NON diciamo:

"Il componente e' stato prodotto" se nella dichiarazione viene consumato.

Diciamo:

"Il componente e' stato consumato dalla produzione."

## Prodotto finito

### Definizione

Il prodotto finito e' l'articolo risultante dalla produzione.

### Perche' esiste

Esiste per indicare cio' che viene caricato a magazzino al termine della produzione confermata.

### Cosa NON significa

Non e' un componente della stessa dichiarazione.

Non e' sempre disponibile finche' la produzione non viene confermata.

Non e' una distinta.

### Relazioni con gli altri concetti

Il prodotto finito ha una distinta.

Puo' essere gestito a lotto.

Viene caricato tramite documento ERP quando la dichiarazione e' confermata.

### Esempi pratici

Articolo confezionato.

Prodotto pronto alla vendita.

Semilavorato finale di una fase produttiva.

### In FactoryFlow diciamo...

NON diciamo:

"Il prodotto finito e' disponibile perche' e' pianificato."

Diciamo:

"Il prodotto finito diventa disponibilita' dopo la conferma della produzione."

## Lotto

### Definizione

Il lotto e' un identificativo che collega una quantita' di articolo a tracciabilita', disponibilita' e, quando presente, scadenza.

### Perche' esiste

Esiste per garantire tracciabilita' e corretto consumo/carico di articoli gestiti a lotto.

### Cosa NON significa

Non e' una semplice descrizione libera.

Non e' una posizione di magazzino.

Non e' sempre obbligatorio per tutti gli articoli.

### Relazioni con gli altri concetti

Il lotto e' collegato ad articolo, magazzino, disponibilita' e dichiarazione.

La dichiarazione confermata aggiorna i saldi lotto.

### Esempi pratici

Lotto prodotto finito.

Lotto componente consumato.

Lotto con scadenza.

### In FactoryFlow diciamo...

NON diciamo:

"Inserisco un lotto anche se l'articolo non e' lottizzato."

Diciamo:

"Il lotto e' richiesto solo per articoli gestiti a lotto."

## Disponibilita'

### Definizione

La disponibilita' e' la quantita' utilizzabile o visibile di un articolo, eventualmente distinta per lotto e magazzino.

### Perche' esiste

Esiste per aiutare l'operatore e il pianificatore a capire se una produzione puo' essere eseguita.

### Cosa NON significa

Non e' sempre un blocco operativo.

Non e' una promessa assoluta.

Non e' una previsione di acquisto.

### Relazioni con gli altri concetti

La disponibilita' riguarda componenti, lotti, magazzini e pianificazione.

FactoryFlow la mostra all'operatore senza necessariamente bloccare la registrazione.

### Esempi pratici

Lotto con disponibilita' sufficiente.

Lotto con disponibilita' positiva ma inferiore al consumo richiesto.

Lotto a disponibilita' zero.

### In FactoryFlow diciamo...

NON diciamo:

"La disponibilita' insufficiente impedisce sempre la produzione."

Diciamo:

"FactoryFlow mostra la disponibilita' e lascia visibile il rischio operativo."

## Scorta

### Definizione

La scorta e' la quantita' di materiale presente o desiderata in magazzino per sostenere produzione, vendita o sicurezza operativa.

### Perche' esiste

Esiste per ragionare su continuita' produttiva, fabbisogni e rischio di fermo.

### Cosa NON significa

Non e' sempre disponibilita' immediata.

Non e' sempre libera da vincoli.

Non e' una distinta.

### Relazioni con gli altri concetti

La scorta influenza MRP, pianificazione, ordini fornitore e decisioni.

### Esempi pratici

Scorta minima di componente critico.

Scorta insufficiente per la produzione prevista.

### In FactoryFlow diciamo...

NON diciamo:

"Ho scorta, quindi posso produrre sempre."

Diciamo:

"La scorta va confrontata con fabbisogni, lotti, date e vincoli."

## Capacita' produttiva

### Definizione

La capacita' produttiva e' la quantita' di lavoro che una risorsa, linea, macchina o reparto puo' sostenere in un certo periodo.

### Perche' esiste

Esiste per capire se il piano e' realistico.

### Cosa NON significa

Non e' produzione gia' fatta.

Non e' disponibilita' di materiale.

Non e' solo velocita' teorica.

### Relazioni con gli altri concetti

La capacita' collega calendario, risorse, tempo, setup e pianificazione.

### Esempi pratici

Linea disponibile per 6 ore.

Macchina capace di produrre 1.000 pezzi per turno.

### In FactoryFlow diciamo...

NON diciamo:

"La capacita' e' infinita se ho materiale."

Diciamo:

"La produzione richiede materiale e capacita' disponibili."

## Calendario

### Definizione

Il calendario e' la rappresentazione temporale delle attivita', dichiarazioni, previsioni e conferme produttive.

### Perche' esiste

Esiste per dare alla fabbrica una vista ordinata del tempo operativo.

### Cosa NON significa

Non e' solo uno storico.

Non e' solo un'agenda grafica.

Non e' una pianificazione completa da solo.

### Relazioni con gli altri concetti

Il calendario mostra attivita' previste, dichiarazioni confermate, stati e carichi di lavoro.

### Esempi pratici

Giorno con tre dichiarazioni.

Giorno futuro con produzioni previste.

### In FactoryFlow diciamo...

NON diciamo:

"Vado nello storico."

Diciamo:

"Apro il Calendario dichiarazioni."

## Pianificazione

### Definizione

La pianificazione e' l'organizzazione delle attivita' produttive nel tempo, tenendo conto di materiali, capacita', priorita' e vincoli.

### Perche' esiste

Esiste per decidere cosa produrre, quando produrlo e con quali risorse.

### Cosa NON significa

Non e' ancora produzione confermata.

Non e' documento ERP.

Non e' solo calendario.

### Relazioni con gli altri concetti

La pianificazione usa ordini, disponibilita', capacita', calendario, MRP e simulazioni.

### Esempi pratici

Anticipare una produzione.

Posticipare un ordine produttivo.

Spostare una produzione su un'altra linea.

### In FactoryFlow diciamo...

NON diciamo:

"Ho prodotto perche' ho pianificato."

Diciamo:

"Ho pianificato un'attivita' produttiva."

## MRP

### Definizione

MRP e' il processo che calcola fabbisogni di materiali partendo da domanda, distinte, scorte, ordini e tempi.

### Perche' esiste

Esiste per prevenire mancanze e proporre azioni operative su acquisti e produzione.

### Cosa NON significa

Non e' una semplice lista di componenti.

Non e' una conferma di produzione.

Non e' un documento ERP.

### Relazioni con gli altri concetti

MRP usa distinta, ordini cliente, ordini fornitore, disponibilita', scorta, calendario e pianificazione.

### Esempi pratici

Componente che blocchera' per primo una produzione.

Proposta di acquisto.

Fabbisogno futuro generato da ordini cliente.

### In FactoryFlow diciamo...

NON diciamo:

"L'MRP produce."

Diciamo:

"L'MRP evidenzia fabbisogni e propone azioni."

## Consumo

### Definizione

Il consumo e' la quantita' di componente utilizzata da una produzione confermata.

### Perche' esiste

Esiste per misurare l'utilizzo reale o effettivo dei materiali.

### Cosa NON significa

Non e' la quantita' teorica della distinta.

Non e' sempre uguale alla proposta.

Non avviene in AdHoc per una previsione futura.

### Relazioni con gli altri concetti

Il consumo riguarda componenti, lotti, dichiarazione e documento ERP di scarico.

### Esempi pratici

Quantita' effettiva scaricata di un componente.

Consumo di un lotto specifico.

### In FactoryFlow diciamo...

NON diciamo:

"Ho consumato componenti per una previsione futura."

Diciamo:

"I componenti saranno consumati quando la previsione verra' confermata."

## Costo

### Definizione

Il costo e' il valore economico associato a materiali, tempo, energia, setup, risorse o produzione.

### Perche' esiste

Esiste per trasformare eventi produttivi in informazioni economiche utili.

### Cosa NON significa

Non e' sempre prezzo di vendita.

Non e' sempre costo standard.

Non e' sempre definitivo se deriva da simulazione.

### Relazioni con gli altri concetti

Il costo si collega a componenti, energia, manodopera, setup, tempo e produzione.

### Esempi pratici

Costo materiale consumato.

Costo energia stimato.

Costo orario macchina.

### In FactoryFlow diciamo...

NON diciamo:

"Il costo e' solo il costo articolo."

Diciamo:

"Il costo produttivo nasce dalla combinazione di materiali, tempo, energia e risorse."

## Costo industriale

### Definizione

Il costo industriale e' il costo complessivo di una produzione considerando materiali, risorse, tempi, setup, energia e altri fattori produttivi.

### Perche' esiste

Esiste per capire il costo reale o stimato della produzione e supportare decisioni di margine.

### Cosa NON significa

Non e' solo costo distinta.

Non e' solo costo contabile.

Non e' sempre uguale al costo standard ERP.

### Relazioni con gli altri concetti

Il costo industriale usa costo, tempo, setup, energia, consumo, macchina e linea.

### Esempi pratici

Produzione con costo energetico alto.

Articolo con margine basso per tempi macchina elevati.

### In FactoryFlow diciamo...

NON diciamo:

"Il costo industriale e' solo il costo dei componenti."

Diciamo:

"Il costo industriale racconta quanto e' costato produrre davvero."

## Energia

### Definizione

L'energia e' una risorsa consumata dalla produzione, da una macchina, da una linea o da un processo.

### Perche' esiste

Esiste per misurare impatto economico e operativo dei consumi energetici.

### Cosa NON significa

Non e' sempre un costo fisso.

Non e' sempre uguale per articolo.

Non e' solo dato tecnico.

### Relazioni con gli altri concetti

Energia si collega a macchina, tempo, costo industriale e decisioni.

### Esempi pratici

Articolo che assorbe molta energia.

Linea energivora in una fascia oraria costosa.

### In FactoryFlow diciamo...

NON diciamo:

"L'energia non riguarda la produzione."

Diciamo:

"L'energia e' parte del costo industriale."

## Setup

### Definizione

Il setup e' il tempo o lavoro necessario per preparare una risorsa alla produzione.

### Perche' esiste

Esiste per rappresentare costi e vincoli che non dipendono solo dalla quantita' prodotta.

### Cosa NON significa

Non e' tempo produttivo puro.

Non e' fermo casuale.

Non e' sempre trascurabile.

### Relazioni con gli altri concetti

Setup si collega a macchina, linea, tempo, costo e pianificazione.

### Esempi pratici

Cambio formato.

Pulizia linea.

Preparazione macchina.

### In FactoryFlow diciamo...

NON diciamo:

"Il setup non pesa se produco poco."

Diciamo:

"Il setup incide sul costo e sulla capacita' disponibile."

## Tempo

### Definizione

Il tempo e' la dimensione in cui si pianificano, eseguono e misurano le attivita' produttive.

### Perche' esiste

Esiste per collegare calendario, capacita', ritardi, setup, rendimento e decisioni.

### Cosa NON significa

Non e' solo data documento.

Non e' solo durata teorica.

Non e' una quantita' materiale.

### Relazioni con gli altri concetti

Tempo collega calendario, pianificazione, capacita', macchina, setup, ordine e costo.

### Esempi pratici

Tempo di produzione.

Tempo di setup.

Ritardo su ordine cliente.

### In FactoryFlow diciamo...

NON diciamo:

"Il tempo e' solo una data."

Diciamo:

"Il tempo e' una risorsa produttiva."

## Operatore

### Definizione

L'operatore e' la persona che esegue, controlla o conferma un'attivita' produttiva.

### Perche' esiste

Esiste per collegare la produzione alla responsabilita' operativa e alla realta' del reparto.

### Cosa NON significa

Non e' solo un login.

Non e' una macchina.

Non e' sempre il pianificatore.

### Relazioni con gli altri concetti

L'operatore interagisce con dichiarazioni, linee, macchine, lotti e conferme.

### Esempi pratici

Operatore che conferma una produzione.

Operatore che seleziona i lotti realmente usati.

### In FactoryFlow diciamo...

NON diciamo:

"L'utente ha scritto una riga."

Diciamo:

"L'operatore ha confermato una dichiarazione di produzione."

## Ordine cliente

### Definizione

L'ordine cliente e' la domanda commerciale da soddisfare.

### Perche' esiste

Esiste per collegare la produzione al valore atteso dal cliente e alle scadenze.

### Cosa NON significa

Non e' ordine produzione.

Non e' ordine fornitore.

Non e' una disponibilita'.

### Relazioni con gli altri concetti

Ordine cliente alimenta pianificazione, MRP, priorita' e decisioni.

### Esempi pratici

Ordine in ritardo.

Ordine che richiede produzione urgente.

### In FactoryFlow diciamo...

NON diciamo:

"L'ordine cliente produce materiale."

Diciamo:

"L'ordine cliente genera domanda da pianificare."

## Ordine produzione

### Definizione

L'ordine produzione e' una richiesta organizzata di produrre una quantita' di articolo entro un certo contesto operativo.

### Perche' esiste

Esiste per trasformare domanda e pianificazione in lavoro produttivo gestibile.

### Cosa NON significa

Non e' sempre una dichiarazione.

Non e' sempre gia' confermato.

Non e' un ordine cliente.

### Relazioni con gli altri concetti

Ordine produzione puo' generare attivita' produttive e dichiarazioni.

### Esempi pratici

Ordine produzione pianificato per domani.

Ordine produzione collegato a una linea.

### In FactoryFlow diciamo...

NON diciamo:

"L'ordine produzione e' gia' magazzino."

Diciamo:

"L'ordine produzione organizza cio' che dovra' essere prodotto."

## Ordine fornitore

### Definizione

L'ordine fornitore e' la richiesta di acquisto o approvvigionamento verso un fornitore.

### Perche' esiste

Esiste per coprire fabbisogni materiali e prevenire blocchi produttivi.

### Cosa NON significa

Non e' disponibilita' immediata.

Non e' consumo.

Non e' ordine cliente.

### Relazioni con gli altri concetti

Ordine fornitore influenza MRP, disponibilita' futura e decisioni di pianificazione.

### Esempi pratici

Componente in arrivo domani.

Fornitore in ritardo che blocca produzione.

### In FactoryFlow diciamo...

NON diciamo:

"L'ordine fornitore rende gia' disponibile il materiale."

Diciamo:

"L'ordine fornitore rappresenta disponibilita' futura attesa."

## Evento

### Definizione

Un evento e' qualcosa che accade nel sistema o nella fabbrica e che puo' essere rilevante per storia, analisi o decisione.

### Perche' esiste

Esiste per non perdere il significato temporale delle azioni.

### Cosa NON significa

Non e' sempre un errore.

Non e' sempre una registrazione ERP.

Non e' necessariamente una modifica dati.

### Relazioni con gli altri concetti

Evento si collega ad audit, dichiarazioni, operatori, macchine e decisioni.

### Esempi pratici

Creazione previsione.

Conferma produzione.

Annullamento dichiarazione.

### In FactoryFlow diciamo...

NON diciamo:

"E' solo un log tecnico."

Diciamo:

"E' un evento rilevante della storia produttiva."

## Audit

### Definizione

L'audit e' la traccia strutturata degli eventi importanti del sistema.

### Perche' esiste

Esiste per spiegare cosa e' successo, quando, da chi e perche'.

### Cosa NON significa

Non e' solo debug.

Non e' solo log applicativo.

Non e' opzionale per processi critici.

### Relazioni con gli altri concetti

Audit registra eventi su dichiarazioni, conferme, modifiche e cancellazioni.

### Esempi pratici

Audit di creazione previsione.

Audit di conferma dichiarazione.

Audit di annullamento.

### In FactoryFlow diciamo...

NON diciamo:

"Non importa chi ha modificato."

Diciamo:

"L'audit conserva la storia delle decisioni e delle azioni."

## Previsione

### Definizione

La previsione e' una registrazione futura non ancora trasformata in documento ERP.

### Perche' esiste

Esiste per permettere alla fabbrica di organizzare lavoro futuro senza alterare magazzino, documenti e saldi ufficiali.

### Cosa NON significa

Non e' produzione confermata.

Non e' documento AdHoc.

Non aggiorna SALDILOT.

Non consuma componenti.

### Relazioni con gli altri concetti

La previsione puo' diventare dichiarazione confermata nel giorno previsto.

La previsione vive in DB_FARMFLOW.

La previsione non ha seriali AdHoc.

### Esempi pratici

Produzione prevista per domani.

Dichiarazione futura in stato `PREVISTA`.

### In FactoryFlow diciamo...

NON diciamo:

"Ho registrato una produzione futura in AdHoc."

Diciamo:

"Ho salvato una previsione in FactoryFlow."

## Simulazione

### Definizione

La simulazione e' una valutazione ipotetica di uno scenario produttivo prima che diventi decisione o azione.

### Perche' esiste

Esiste per confrontare alternative senza modificare dati ufficiali.

### Cosa NON significa

Non e' una produzione.

Non e' una previsione confermata.

Non e' un documento ERP.

### Relazioni con gli altri concetti

La simulazione usa disponibilita', capacita', costi, tempi, ordini e MRP.

### Esempi pratici

Simulare anticipo produzione.

Simulare spostamento su altra linea.

Simulare effetto di un ritardo fornitore.

### In FactoryFlow diciamo...

NON diciamo:

"La simulazione ha cambiato il magazzino."

Diciamo:

"La simulazione valuta uno scenario senza modificare i dati ufficiali."

## Decisione

### Definizione

La decisione e' la scelta operativa o gestionale presa usando le informazioni disponibili.

### Perche' esiste

Esiste perche' FactoryFlow non registra dati per se stesso: li collega per aiutare l'azienda a scegliere.

### Cosa NON significa

Non e' una semplice informazione.

Non e' solo report.

Non e' sempre automatica.

### Relazioni con gli altri concetti

La decisione nasce da conoscenza, simulazione, disponibilita', costi, tempo, capacita' e priorita'.

### Esempi pratici

Produrre oggi o domani.

Cambiare lotto.

Spostare linea.

Anticipare acquisto.

### In FactoryFlow diciamo...

NON diciamo:

"FactoryFlow mostra solo dati."

Diciamo:

"FactoryFlow rende possibili decisioni migliori."

## Conoscenza

### Definizione

La conoscenza e' il valore che nasce collegando dati, eventi, relazioni e contesto.

### Perche' esiste

Esiste per trasformare registrazioni isolate in comprensione della fabbrica.

### Cosa NON significa

Non e' semplice dato.

Non e' solo archivio.

Non e' solo reportistica.

### Relazioni con gli altri concetti

La conoscenza nasce dalla relazione tra produzione, materiali, tempi, costi, risorse, ordini ed eventi.

### Esempi pratici

Sapere quale componente blocchera' per primo una produzione.

Sapere quale linea rende meglio.

Sapere quale produzione genera piu' margine.

### In FactoryFlow diciamo...

NON diciamo:

"Abbiamo molti dati."

Diciamo:

"Abbiamo relazioni che costruiscono conoscenza."

## Factory Intelligence

### Definizione

Factory Intelligence e' il livello superiore di FactoryFlow: la capacita' della piattaforma di usare conoscenza strutturata per suggerire decisioni operative.

### Perche' esiste

Esiste per aiutare concretamente l'azienda a decidere, non solo a consultare informazioni.

### Cosa NON significa

Non e' una chat generica.

Non e' AI appoggiata su dati disordinati.

Non e' un sostituto dell'esperienza umana.

### Relazioni con gli altri concetti

Factory Intelligence usa conoscenza, decisioni, simulazioni, MRP, costi, disponibilita' e storico.

### Esempi pratici

Suggerire quale produzione iniziare domani.

Segnalare il primo componente critico.

Proporre alternativa di linea.

Evidenziare ordini cliente a rischio.

### In FactoryFlow diciamo...

NON diciamo:

"L'AI risponde a domande generiche."

Diciamo:

"Factory Intelligence aiuta la fabbrica a prendere decisioni operative."

## Le Regole Del Linguaggio

### Una parola deve avere un solo significato

Ogni termine importante deve indicare un solo concetto. Se una parola viene usata per concetti diversi, il sistema diventa ambiguo.

### Lo stesso concetto non deve avere nomi diversi

Se una cosa si chiama `Dichiarazione di produzione`, non deve diventare altrove `movimento`, `registrazione`, `produzione`, `evento` o `documento` senza motivo.

### Il database deve adattarsi al linguaggio

Il modello dati deve rappresentare il dominio della fabbrica. Non deve costringere la fabbrica a parlare come parlano le tabelle.

### Mai il contrario

Non si parte dalla colonna per decidere il concetto. Si parte dal concetto per decidere se serve una colonna.

### Il codice deve parlare il linguaggio del dominio

Classi, metodi, API e schermate devono usare parole comprensibili agli utenti e coerenti con il modello FactoryFlow.

### Non il linguaggio del database

Il database puo' avere vincoli tecnici. Il linguaggio ufficiale del prodotto deve restare quello della fabbrica.

### Le parole devono proteggere l'architettura

Quando una parola e' precisa, impedisce duplicazioni, scorciatoie e confusione tra AdHoc e DB_FARMFLOW.

### AdHoc e FactoryFlow devono restare distinti nel linguaggio

Un documento ERP e' AdHoc.

Una previsione e' FactoryFlow.

Una dichiarazione confermata collega i due mondi.

### Le previsioni non sono produzioni confermate

Una previsione organizza il futuro.

Una produzione confermata modifica la realta' ufficiale della fabbrica.

### Le cancellazioni importanti non cancellano la storia

Quando un dato ha valore storico, deve essere annullato o disattivato, non eliminato fisicamente.

## Chiusura

FactoryFlow non e' stato progettato per descrivere dati.

E' stato progettato per descrivere come pensa una fabbrica.

## Estensione: Costi Produttivi E Team Operativo

### Team operativo

Definizione: insieme delle persone coinvolte in una attivita produttiva, ciascuna con un ruolo operativo.

Perche esiste: una produzione reale non e quasi mai il lavoro isolato di una sola persona. FactoryFlow registra il contesto del processo.

Cosa NON significa: non e una classifica delle persone, non e una valutazione individuale, non e un sistema HR.

In FactoryFlow diciamo: "La dichiarazione e stata registrata con il team operativo coinvolto".

### Costo industriale di produzione

Definizione: fotografia economica della produzione calcolata con dati disponibili al momento della conferma.

Perche esiste: permette di capire quanto costa davvero produrre in certe condizioni operative.

Cosa NON significa: non sostituisce la contabilita AdHoc e non duplica i costi ERP ufficiali.

In FactoryFlow diciamo: "FactoryFlow ha calcolato il costo industriale della dichiarazione".

### Setup operativo

Definizione: tempo o costo necessario a preparare linea o macchina prima della produzione.

Perche esiste: separare setup standard e setup specifico articolo-linea permette decisioni piu precise.

Cosa NON significa: non e una distinta base e non e un documento ERP.

In FactoryFlow diciamo: "Questa produzione richiede un setup specifico".
