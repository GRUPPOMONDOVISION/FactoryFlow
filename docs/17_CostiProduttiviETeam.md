# Costi Produttivi E Team Operativo

FactoryFlow evolve introducendo due informazioni che AdHoc, come ERP, non governa con il livello operativo necessario a un MES: il costo reale del processo produttivo e il contesto umano dell'attivita produttiva.

AdHoc resta la fonte ufficiale per articoli, distinte, documenti, lotti, giacenze, causali e progressivi. FactoryFlow non duplica questi dati. Li usa come base e aggiunge conoscenza operativa: tempi effettivi, linea, macchina, setup, energia, manodopera, rendimento, team e fotografia economica della produzione.

## Perche I Cicli Semplificati AdHoc Non Bastano

I cicli AdHoc possono essere utili come riferimento o compatibilita, ma spesso descrivono un modello standard amministrativo o tecnico. FactoryFlow deve rappresentare quello che succede davvero in reparto.

Una produzione reale puo dipendere da linea utilizzata, macchina specifica, setup standard, setup specifico articolo-linea, durata effettiva, quantita prodotta, numero e ruolo delle persone coinvolte, costo energia, costo macchina, costo manodopera e condizioni operative del giorno.

Per questo FactoryFlow non deve affidarsi ciecamente ai cicli AdHoc. Li puo leggere, confrontare o usare come valore iniziale, ma il modello industriale operativo appartiene a DB_FARMFLOW.

## Costi Produttivi

Il costo industriale FactoryFlow e composto da elementi separati, perche separarli permette decisioni migliori.

### Costo fisso di linea o macchina

Rappresenta il costo orario di disponibilita della linea o della macchina. Non dipende direttamente dalla quantita prodotta. Serve a capire quanto costa tenere impegnata una risorsa produttiva.

### Setup macchina standard

Rappresenta il tempo o costo normalmente necessario per preparare una macchina. E una regola di base della risorsa, indipendente dall'articolo.

### Setup specifico articolo-linea

Rappresenta un costo o tempo di preparazione che esiste solo per una certa combinazione articolo, linea e, se necessario, macchina. Deve stare in FactoryFlow perche e una conoscenza operativa del reparto.

### Costo variabile a quantita

Cresce al crescere della quantita prodotta. Puo rappresentare consumi, materiali ausiliari o costi operativi proporzionali al pezzo.

### Costo variabile a tempo

Cresce al crescere della durata effettiva. Serve quando la produzione assorbe risorse per il tempo in cui rimane in lavorazione.

### Costo energia

Puo essere espresso a ora, a unita o in futuro derivato da rilevazioni reali. Non sostituisce la contabilita energetica, ma permette analisi industriale.

### Costo manodopera

Rappresenta il costo del tempo operativo coinvolto nel processo. Non serve a giudicare le persone. Serve a capire il costo del processo in determinate condizioni.

### Costo macchina

Rappresenta l'assorbimento economico della macchina. Deve rimanere separato dal costo linea, per permettere analisi quando una linea contiene piu macchine o quando una macchina e condivisa.

### Costo industriale totale

E la fotografia del costo calcolato al momento della conferma. Deve essere salvato anche se in futuro cambiano listini, regole o configurazioni. Se i dati non sono sufficienti, FactoryFlow salva il costo come incompleto e non blocca la produzione.

## Tabelle DB_FARMFLOW Proposte

### FF_MACCHINE

Rappresenta macchine operative FactoryFlow quando non sono gia governate in modo sufficiente da AdHoc. Sta in DB_FARMFLOW perche descrive risorse MES usate per capacita, costi e analisi di reparto.

### FF_SETUP_TIPI

Classifica i tipi di setup. Sta in DB_FARMFLOW perche e una tassonomia operativa FactoryFlow, non un dato ERP.

### FF_SETUP_REGOLE

Contiene regole di setup standard o specifiche per linea, macchina e articolo. I codici articolo restano riferimenti esterni AdHoc, senza foreign key fisiche.

### FF_COSTI_LINEA

Contiene costi validi per periodo legati a linea o macchina: fisso, macchina, manodopera, energia. Sta in DB_FARMFLOW perche serve per analisi industriale e decisioni operative.

### FF_COSTI_ARTICOLO_LINEA

Contiene costi variabili o tempi standard specifici per articolo e linea. Non duplica l'articolo AdHoc: salva solo la regola operativa associata al codice articolo.

### FF_METRICHE_PRODUZIONE

Fotografa metriche derivate dalla dichiarazione: minuti produzione, quantita/minuto, numero operatori, setup, energia stimata. Sta in DB_FARMFLOW perche nasce dal processo reale.

### FF_COSTI_PRODUZIONE

Fotografa il costo industriale calcolato al momento della dichiarazione. Se il calcolo non e completo, conserva il motivo. La produzione non deve essere bloccata da dati economici incompleti.

## Team Operativo

FactoryFlow introduce il concetto di Team Operativo perche una produzione raramente dipende da una sola persona.

Una dichiarazione puo coinvolgere operatore principale, supporto linea, capo reparto, manutentore, controllo qualita, addetto setup o altre figure operative.

Il team non e un dato AdHoc. E contesto MES: aiuta a capire come si e svolta l'attivita produttiva.

## Tabelle Team

### FF_OPERATORI

Anagrafica minima FactoryFlow degli operatori, solo se non esiste una fonte esterna affidabile. Se in futuro esiste un sistema HR o presenze, FactoryFlow dovra collegarsi tramite codice esterno senza duplicare tutto.

### FF_RUOLI_OPERATIVI

Descrive il ruolo svolto nel processo, non la qualifica personale. Esempi: conduttore linea, supporto, setup, manutenzione, qualita.

### FF_DICHIARAZIONI_OPERATORI

Collega una dichiarazione al team coinvolto. Salva anche snapshot di nome e ruolo per mantenere leggibile lo storico se l'anagrafica cambia.

### FF_COMPETENZE E FF_OPERATORI_COMPETENZE

Sono previste solo come evoluzione futura. Non vengono rese centrali ora perche la skill matrix avanzata non appartiene all'MVP corrente.

## Principio Etico

FactoryFlow non deve misurare il valore delle persone.

FactoryFlow misura il comportamento del processo: condizioni, tempi, carichi, setup, risorse e contesto. Le informazioni sul team servono a capire quali condizioni permettono alle persone di lavorare meglio, non a classificare le persone.

Un dato sul team deve sempre rispondere a una domanda di processo: con quale assetto produttivo abbiamo lavorato meglio, serviva supporto aggiuntivo, il setup era piu complesso del previsto, la linea era sovraccarica, quali condizioni hanno ridotto errori o ritardi.

Non deve mai diventare una scorciatoia per giudicare individualmente il valore di una persona.

## Regole Implementative

- La stored AdHoc non deve essere modificata per costi e team, salvo necessita futura strettamente documentata.
- La produzione deve rimanere registrabile anche se i costi non sono completi.
- I costi calcolati devono essere salvati come fotografia storica.
- I riferimenti ad AdHoc restano codici esterni.
- Le foreign key fisiche restano interne a DB_FARMFLOW.
- La UI deve restare semplice: prima raccogliere il contesto, poi evolvere verso analisi piu ricche.

## Decisione Architetturale

Costi produttivi e team operativo appartengono a DB_FARMFLOW perche descrivono il comportamento reale della fabbrica. AdHoc resta il sistema ufficiale ERP. FactoryFlow aggiunge conoscenza operativa, non duplica il gestionale.
## Regola Di Registrazione Master-Detail

Quando una informazione singola esiste solo insieme a una o piu informazioni di dettaglio, FactoryFlow deve trattare l'inserimento come un'unica registrazione logica.

Esempi:

- un team operativo esiste perche contiene uno o piu operatori con ruolo e costo applicato;
- un tipo setup e utile solo se puo essere collegato alle sue regole operative;
- una linea produttiva acquisisce valore operativo quando ha articoli assegnati.

Regola:

- il master deve essere modificabile;
- i dettagli devono essere modificabili;
- la UI deve essere master-detail;
- il salvataggio deve evitare record master inutilizzati;
- la cancellazione fisica non e ammessa se il dato e gia collegato a registrazioni operative;
- in quel caso si usa disattivazione logica, preservando lo storico.

Questa regola protegge il modello dati da anagrafiche orfane e mantiene leggibile la storia produttiva.

## Regola Di Stabilita Storica Dei Costi

FactoryFlow non deve mai ricalcolare una produzione storica usando configurazioni modificate dopo la data della produzione.

Tutte le entita che concorrono al costo produttivo devono quindi rispettare una regola inderogabile:

- se il dato e una configurazione variabile nel tempo, deve avere validita temporale;
- se il dato partecipa a una produzione confermata, il valore applicato deve essere fotografato sulla registrazione o sul costo produzione;
- una modifica futura non deve alterare il costo gia rendicontato;
- una chiusura non e una cancellazione fisica e non e una duplicazione: e una data di fine validita.

Questa regola riguarda in particolare:

- operatori associati a un team operativo;
- costo orario applicato alla relazione team-operatore;
- regole di setup;
- costi di linea e macchina;
- costi articolo-linea;
- qualsiasi parametro operativo usato per calcolare costo macchina, manodopera, energia, setup o costo industriale totale.

Nel caso dei team operativi, lo stesso operatore non puo essere inserito due volte nello stesso team con validita aperta. Se la sua partecipazione termina, la riga viene chiusa con una data di obsolescenza. Le produzioni gia confermate mantengono il costo calcolato quando quella riga era valida.

Questa scelta protegge FactoryFlow dal rischio piu grave per un sistema MES: rendicontazioni storiche che cambiano quando vengono aggiornate le impostazioni correnti.
