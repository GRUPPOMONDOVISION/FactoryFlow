# FactoryFlow - Knowledge Model

## Scopo Del Documento

FactoryFlow non deve essere progettato come un insieme di tabelle.

FactoryFlow deve essere progettato come un sistema di conoscenza.

Le tabelle sono solo uno strumento. Il vero valore nasce dal modo in cui le informazioni vengono collegate, interpretate e rese utili alle persone che devono prendere decisioni.

Questo documento descrive le principali entità di conoscenza del dominio FactoryFlow.

Per ogni entità vengono chiariti:

- cosa rappresenta;
- cosa sa;
- chi la usa;
- da dove arrivano i dati;
- dove vengono salvati;
- con quali altre entità è collegata;
- quali decisioni abilita.

## Produzione

### Cosa Rappresenta

La produzione rappresenta l'evento centrale del sistema: qualcosa è stato prodotto, in una certa quantità, in una certa data, con determinati componenti, lotti e condizioni operative.

### Cosa Sa

Sa quale prodotto finito è stato realizzato, in quale quantità, quando, con quali componenti, con quali lotti e con quale esito documentale.

Può sapere anche chi l'ha registrata, da quale dispositivo e con quali eventuali variazioni rispetto alla distinta teorica.

### Chi La Usa

Operatori, responsabili produzione, consulenti, amministrazione, controllo di gestione e futuri moduli di pianificazione o analisi.

### Da Dove Arrivano I Dati

I dati ufficiali di articolo, distinta, lotti e magazzino arrivano da AdHoc.

I dati operativi della registrazione arrivano da FactoryFlow.

### Dove Vengono Salvati

Il documento ufficiale viene salvato in AdHoc.

Lo storico applicativo, gli input e gli esiti FactoryFlow possono essere salvati in `DB_FARMFLOW`.

### Collegamenti

È collegata a prodotto finito, componenti, distinta, lotti, disponibilità, operatore, linea, macchina, costo, tempo, setup ed energia.

### Decisioni Che Abilita

Permette di capire cosa è stato prodotto, quali materiali sono stati consumati, quali lotti sono stati coinvolti, quali differenze esistono tra teoria e pratica e quali produzioni richiedono attenzione.

## Prodotto Finito

### Cosa Rappresenta

Il prodotto finito è l'articolo realizzato dalla produzione.

### Cosa Sa

Sa il proprio codice, la propria descrizione, l'unità di misura, la distinta collegata e l'eventuale gestione a lotti.

### Chi Lo Usa

Operatori, pianificatori, responsabili produzione, magazzino e controllo industriale.

### Da Dove Arrivano I Dati

I dati ufficiali arrivano da AdHoc.

FactoryFlow può usare il codice articolo come riferimento, ma non deve duplicare l'anagrafica.

### Dove Vengono Salvati

L'anagrafica resta in AdHoc.

FactoryFlow può salvare solo riferimenti, preferenze operative o snapshot necessari per audit.

### Collegamenti

È collegato a produzione, distinta, componenti, lotti, disponibilità, linee, macchine, ordini, costi e simulazioni.

### Decisioni Che Abilita

Permette di decidere cosa produrre, dove produrlo, con quali componenti, con quali vincoli di lotto e con quale impatto su disponibilità e capacità.

## Componente

### Cosa Rappresenta

Il componente è un materiale o semilavorato usato per produrre un prodotto finito.

### Cosa Sa

Sa codice, descrizione, unità di misura, gestione lotti e quantità prevista dalla distinta.

Nel contesto di FactoryFlow può sapere anche la quantità effettiva da scaricare e il lotto scelto dall'operatore.

### Chi Lo Usa

Operatori, magazzino, responsabili produzione, controllo materiali e MRP.

### Da Dove Arrivano I Dati

L'anagrafica e la distinta arrivano da AdHoc.

La quantità effettiva e il lotto selezionato arrivano dall'operatività FactoryFlow.

### Dove Vengono Salvati

Il componente come articolo resta in AdHoc.

Lo snapshot della scelta operativa può essere salvato in `DB_FARMFLOW`.

### Collegamenti

È collegato a distinta, produzione, lotto, disponibilità, ordine fornitore, MRP, costo e simulazione.

### Decisioni Che Abilita

Permette di capire se i materiali sono sufficienti, quali lotti usare, dove esistono criticità e quanto il consumo reale differisce dal teorico.

## Distinta

### Cosa Rappresenta

La distinta rappresenta la struttura tecnica del prodotto: quali componenti servono per realizzarlo e in quali quantità.

### Cosa Sa

Sa il legame tra prodotto finito e componenti, quantità teoriche e regole tecniche ufficiali.

### Chi La Usa

Operatori, pianificazione, MRP, responsabili produzione e controllo industriale.

### Da Dove Arrivano I Dati

La distinta ufficiale arriva da AdHoc.

FactoryFlow la legge e la usa per proporre i componenti.

### Dove Vengono Salvati

La distinta resta in AdHoc.

FactoryFlow non deve creare una distinta parallela.

### Collegamenti

È collegata a prodotto finito, componenti, produzione, MRP, simulazioni e costi.

### Decisioni Che Abilita

Permette di calcolare fabbisogni, proporre consumi, stimare costi e confrontare consumo teorico con consumo effettivo.

## Lotto

### Cosa Rappresenta

Il lotto rappresenta una specifica identificazione di materiale o prodotto, necessaria per tracciabilità, scadenze e saldi.

### Cosa Sa

Sa codice lotto, articolo, magazzino, disponibilità, scadenza e movimenti collegati.

### Chi Lo Usa

Operatori, magazzino, qualità, responsabili produzione e controllo tracciabilità.

### Da Dove Arrivano I Dati

I lotti ufficiali e i saldi arrivano da AdHoc.

FactoryFlow può mostrare disponibilità e scadenze all'operatore.

### Dove Vengono Salvati

Lotto e saldo ufficiale restano in AdHoc.

FactoryFlow può salvare il lotto scelto come snapshot della registrazione.

### Collegamenti

È collegato a prodotto finito, componenti, produzione, disponibilità, magazzino, scadenze e documenti AdHoc.

### Decisioni Che Abilita

Permette di scegliere quale lotto consumare o caricare, verificare disponibilità, rispettare scadenze e ricostruire tracciabilità.

## Linea

### Cosa Rappresenta

La linea rappresenta una risorsa produttiva operativa: un luogo logico o fisico in cui avviene la produzione.

### Cosa Sa

Sa codice operativo, descrizione interna, stato, eventuale riferimento a centri o cicli AdHoc, articoli producibili e capacità operativa.

### Chi La Usa

Responsabili produzione, pianificatori, operatori e moduli di capacità.

### Da Dove Arrivano I Dati

Se esistono centri o cicli ufficiali, il riferimento arriva da AdHoc.

Le informazioni operative della linea appartengono a FactoryFlow.

### Dove Vengono Salvati

Le regole operative della linea possono essere salvate in `DB_FARMFLOW`.

Eventuali dati ufficiali AdHoc restano in AdHoc.

### Collegamenti

È collegata a macchine, prodotti, produzioni, calendario, capacità, pianificazione, tempi, setup ed energia.

### Decisioni Che Abilita

Permette di decidere dove produrre, valutare saturazione, assegnare lavori e individuare colli di bottiglia.

## Macchina

### Cosa Rappresenta

La macchina rappresenta una risorsa operativa più specifica della linea.

### Cosa Sa

Sa codice operativo, stato, eventuale linea associata, eventuale riferimento AdHoc, capacità, tempi, setup e rilevazioni operative.

### Chi La Usa

Operatori, manutenzione, responsabili produzione, pianificatori e controllo industriale.

### Da Dove Arrivano I Dati

Eventuali riferimenti ufficiali possono arrivare da AdHoc o da sistemi aziendali esterni.

Gli stati e le rilevazioni operative appartengono a FactoryFlow.

### Dove Vengono Salvati

I dati operativi possono essere salvati in `DB_FARMFLOW`.

I dati ufficiali contabili o cespiti non devono essere duplicati.

### Collegamenti

È collegata a linea, produzione, calendario, capacità, tempo, setup, energia, costo e simulazione.

### Decisioni Che Abilita

Permette di capire quale macchina usare, quanto è disponibile, quanto costa produrre su di essa e dove si generano inefficienze.

## Operatore

### Cosa Rappresenta

L'operatore rappresenta la persona che usa FactoryFlow o partecipa a un'attività produttiva.

### Cosa Sa

Sa chi ha eseguito una registrazione, confermato una produzione, modificato dati operativi o generato una rilevazione.

### Chi Lo Usa

Responsabili produzione, qualità, audit, consulenti e analisi operative.

### Da Dove Arrivano I Dati

L'identità può arrivare dal sistema applicativo, da integrazioni aziendali o da un futuro modulo di autenticazione.

FactoryFlow conserva il riferimento operativo necessario all'audit.

### Dove Vengono Salvati

FactoryFlow può salvare riferimenti, log e audit in `DB_FARMFLOW`.

Non deve duplicare anagrafiche ufficiali del personale se già gestite altrove.

### Collegamenti

È collegato a produzione, modifiche, cancellazioni, tempi, setup, rilevazioni e decisioni operative.

### Decisioni Che Abilita

Permette di ricostruire responsabilità operative, individuare necessità formative e analizzare comportamenti di reparto.

## Ordine Cliente

### Cosa Rappresenta

L'ordine cliente rappresenta una domanda commerciale da soddisfare.

### Cosa Sa

Sa cliente, articolo richiesto, quantità, data richiesta e priorità commerciale.

### Chi Lo Usa

Commerciale, pianificazione, produzione, direzione e MRP.

### Da Dove Arrivano I Dati

L'ordine cliente ufficiale arriva da AdHoc.

FactoryFlow può leggerlo per pianificazione e simulazioni.

### Dove Vengono Salvati

Resta in AdHoc.

FactoryFlow può salvare solo riferimenti o risultati di simulazione collegati.

### Collegamenti

È collegato a prodotto finito, ordine produzione, MRP, disponibilità, pianificazione e simulazione.

### Decisioni Che Abilita

Permette di capire cosa deve essere prodotto per soddisfare il mercato, quali scadenze sono critiche e quali priorità produttive derivano dalla domanda cliente.

## Ordine Produzione

### Cosa Rappresenta

L'ordine produzione rappresenta una necessità organizzata di produrre un articolo.

### Cosa Sa

Sa cosa produrre, quanto produrre, entro quando, con quale stato e con quale collegamento a domanda, pianificazione o fabbisogno.

### Chi Lo Usa

Responsabili produzione, pianificatori, operatori e MRP.

### Da Dove Arrivano I Dati

Se l'ordine è ufficiale in AdHoc, arriva da AdHoc.

Se è uno scenario operativo FactoryFlow, nasce in FactoryFlow come piano o simulazione.

### Dove Vengono Salvati

L'ordine ufficiale resta in AdHoc.

Il piano operativo o la simulazione possono essere salvati in `DB_FARMFLOW`.

### Collegamenti

È collegato a prodotto finito, distinta, linea, macchina, calendario, capacità, MRP e produzione.

### Decisioni Che Abilita

Permette di decidere cosa mettere in produzione, quando avviarlo, dove produrlo e come confrontare pianificato e consuntivo.

## Ordine Fornitore

### Cosa Rappresenta

L'ordine fornitore rappresenta l'approvvigionamento di materiali necessari alla produzione.

### Cosa Sa

Sa fornitore, articolo, quantità ordinata, date previste e stato di consegna.

### Chi Lo Usa

Acquisti, magazzino, pianificazione, MRP e responsabili produzione.

### Da Dove Arrivano I Dati

L'ordine fornitore ufficiale arriva da AdHoc.

FactoryFlow lo può usare per valutare disponibilità futura.

### Dove Vengono Salvati

Resta in AdHoc.

FactoryFlow può salvare solo riferimenti o esiti di simulazione.

### Collegamenti

È collegato a componente, disponibilità, MRP, simulazione e pianificazione.

### Decisioni Che Abilita

Permette di capire se un componente mancante arriverà in tempo, se un piano è sostenibile e quali acquisti rischiano di bloccare la produzione.

## Disponibilità

### Cosa Rappresenta

La disponibilità rappresenta la possibilità effettiva o prevista di usare un materiale, un lotto, una linea, una macchina o una capacità.

### Cosa Sa

Sa quantità disponibile, magazzino, lotto, scadenza, risorsa disponibile, periodo e vincoli.

### Chi La Usa

Operatori, pianificazione, MRP, magazzino e responsabili produzione.

### Da Dove Arrivano I Dati

La disponibilità materiale ufficiale arriva da AdHoc.

La disponibilità di risorse operative può arrivare da FactoryFlow.

### Dove Vengono Salvati

I saldi ufficiali restano in AdHoc.

Le disponibilità operative, gli scenari e le capacità possono essere salvati in `DB_FARMFLOW`.

### Collegamenti

È collegata a lotto, componente, prodotto finito, ordine cliente, ordine fornitore, linea, macchina, calendario, MRP e simulazione.

### Decisioni Che Abilita

Permette di capire se si può produrre, quando si può produrre, cosa manca e quale vincolo limita il piano.

## Calendario

### Cosa Rappresenta

Il calendario rappresenta il tempo disponibile per produrre: giorni lavorativi, turni, chiusure ed eccezioni.

### Cosa Sa

Sa quando una linea o una macchina è disponibile e con quale capacità teorica o operativa.

### Chi Lo Usa

Pianificatori, responsabili produzione, MRP e simulazioni.

### Da Dove Arrivano I Dati

Se esiste un calendario ufficiale utile in AdHoc, FactoryFlow deve leggerlo.

Se serve un calendario operativo di reparto, può essere gestito da FactoryFlow.

### Dove Vengono Salvati

Il calendario operativo può stare in `DB_FARMFLOW`.

Eventuali calendari ufficiali AdHoc restano in AdHoc.

### Collegamenti

È collegato a linea, macchina, capacità, ordine produzione, pianificazione, tempo e simulazione.

### Decisioni Che Abilita

Permette di capire quando una produzione può essere schedulata e se una promessa produttiva è realistica.

## Costo

### Cosa Rappresenta

Il costo rappresenta l'impatto economico-industriale di una produzione o di una scelta operativa.

### Cosa Sa

Sa costo materiali, energia, manodopera, setup, tempi, scostamenti e versione dei parametri usati.

### Chi Lo Usa

Direzione, controllo di gestione, responsabili produzione e analisti.

### Da Dove Arrivano I Dati

I costi standard ufficiali arrivano da AdHoc.

I costi industriali calcolati possono derivare da FactoryFlow usando produzioni, tempi, energia e setup.

### Dove Vengono Salvati

I costi ufficiali restano in AdHoc.

Le fotografie di costo industriale possono essere salvate in `DB_FARMFLOW`.

### Collegamenti

È collegato a produzione, componente, linea, macchina, tempo, setup, energia e simulazione.

### Decisioni Che Abilita

Permette di capire quanto costa produrre, dove nascono gli scostamenti e quali scelte operative hanno maggiore impatto economico.

## Tempo

### Cosa Rappresenta

Il tempo rappresenta la durata delle attività produttive e operative.

### Cosa Sa

Sa inizio, fine, durata, tipo attività, operatore, linea, macchina e produzione collegata.

### Chi Lo Usa

Responsabili produzione, controllo industriale, pianificazione e analisi efficienza.

### Da Dove Arrivano I Dati

Può arrivare da rilevazioni manuali, sistemi di reparto o calcoli FactoryFlow.

Eventuali tempi ciclo ufficiali, se presenti, restano in AdHoc.

### Dove Vengono Salvati

Le rilevazioni operative possono essere salvate in `DB_FARMFLOW`.

I tempi ufficiali di ciclo non devono essere duplicati se governati da AdHoc.

### Collegamenti

È collegato a produzione, linea, macchina, operatore, setup, costo, calendario e capacità.

### Decisioni Che Abilita

Permette di analizzare efficienza, saturazione, ritardi, scostamenti dal piano e costo del lavoro operativo.

## Setup

### Cosa Rappresenta

Il setup rappresenta il tempo e lo sforzo necessari per preparare una linea o macchina alla produzione.

### Cosa Sa

Sa durata, risorsa coinvolta, articolo o cambio produzione, operatore, costo e impatto sul piano.

### Chi Lo Usa

Pianificatori, responsabili produzione, operatori e controllo industriale.

### Da Dove Arrivano I Dati

Se il setup è definito nei cicli AdHoc, FactoryFlow deve leggerlo.

Se viene rilevato operativamente, nasce in FactoryFlow.

### Dove Vengono Salvati

Il setup ufficiale di ciclo resta in AdHoc.

Le rilevazioni o override operativi possono stare in `DB_FARMFLOW`.

### Collegamenti

È collegato a macchina, linea, prodotto finito, tempo, costo, calendario e pianificazione.

### Decisioni Che Abilita

Permette di decidere sequenze produttive migliori, ridurre cambi inutili e stimare correttamente capacità e costi.

## Energia

### Cosa Rappresenta

L'energia rappresenta il consumo energetico collegato a produzione, linea, macchina o periodo.

### Cosa Sa

Sa quantità consumata, unità di misura, periodo, fonte di rilevazione, costo applicato e risorsa collegata.

### Chi La Usa

Direzione, controllo industriale, responsabili produzione e sostenibilità.

### Da Dove Arrivano I Dati

Può arrivare da rilevazioni manuali, sistemi di misura, import o parametri FactoryFlow.

La contabilità energetica ufficiale resta nei sistemi amministrativi competenti.

### Dove Vengono Salvati

Le rilevazioni operative possono stare in `DB_FARMFLOW`.

I documenti contabili non devono essere duplicati.

### Collegamenti

È collegata a produzione, linea, macchina, costo, tempo e simulazione.

### Decisioni Che Abilita

Permette di valutare l'impatto energetico delle produzioni, confrontare linee o macchine e identificare inefficienze.

## MRP

### Cosa Rappresenta

L'MRP rappresenta la capacità di analizzare fabbisogni, disponibilità e vincoli per capire cosa serve produrre o acquistare.

### Cosa Sa

Sa domanda, giacenze, ordini, distinte, componenti, disponibilità futura, criticità e proposte.

### Chi Lo Usa

Pianificazione, acquisti, produzione, direzione e consulenti.

### Da Dove Arrivano I Dati

Le fonti ufficiali arrivano da AdHoc: articoli, distinte, giacenze, ordini cliente, ordini fornitore e documenti.

FactoryFlow può aggiungere capacità, calendari, scenari e vincoli operativi.

### Dove Vengono Salvati

I dati ufficiali restano in AdHoc.

Scenari, risultati e proposte possono essere salvati in `DB_FARMFLOW`.

### Collegamenti

È collegato a prodotto finito, componente, distinta, disponibilità, ordini, calendario, capacità, simulazione e pianificazione.

### Decisioni Che Abilita

Permette di decidere cosa acquistare, cosa produrre, cosa anticipare, cosa rischia di mancare e quali piani sono sostenibili.

## Simulazione

### Cosa Rappresenta

La simulazione rappresenta un possibile scenario futuro.

Non è la verità ufficiale. È uno strumento per ragionare prima di agire.

### Cosa Sa

Sa ipotesi, parametri, vincoli, dati usati, risultati, criticità e proposte generate.

### Chi La Usa

Responsabili produzione, pianificatori, direzione, consulenti e futuri assistenti intelligenti.

### Da Dove Arrivano I Dati

Usa dati ufficiali AdHoc e dati operativi FactoryFlow.

Può includere ipotesi inserite dall'utente.

### Dove Vengono Salvati

Gli scenari e i risultati possono essere salvati in `DB_FARMFLOW`.

Non devono sostituire ordini, giacenze o fabbisogni ufficiali.

### Collegamenti

È collegata a MRP, disponibilità, calendario, capacità, costo, produzione, ordini, linee e macchine.

### Decisioni Che Abilita

Permette di confrontare alternative, valutare rischi, preparare piani e trasformare dati complessi in scenari comprensibili.

## La Rete Della Conoscenza

FactoryFlow non memorizza semplicemente dati.

FactoryFlow collega informazioni per costruire conoscenza.

Un articolo da solo è un dato.

Una distinta da sola è un dato.

Un lotto da solo è un dato.

Una produzione da sola è un evento.

Ma quando questi elementi vengono collegati, nasce conoscenza.

Si può sapere quale prodotto è stato realizzato, con quali componenti, usando quali lotti, su quale linea, con quale macchina, in quanto tempo, con quale setup, con quale consumo energetico, con quale costo e rispetto a quale piano.

Questa conoscenza permette di rispondere a domande più importanti:

- possiamo produrre in tempo?
- quale componente rischia di bloccarci?
- quale linea è più adatta?
- quale lotto conviene usare?
- quale ordine cliente è a rischio?
- quanto costa davvero produrre?
- quale scenario è più sostenibile?

La conoscenza serve per prendere decisioni.

Più FactoryFlow crescerà, più il suo valore dipenderà dalla qualità dei collegamenti tra le informazioni.

AdHoc continuerà a custodire la verità gestionale.

FactoryFlow dovrà trasformare quella verità, insieme ai dati operativi di fabbrica, in conoscenza utile.

La qualità di FactoryFlow non dipenderà dalla quantità di dati memorizzati.

Dipenderà dalla qualità delle relazioni tra quei dati.
