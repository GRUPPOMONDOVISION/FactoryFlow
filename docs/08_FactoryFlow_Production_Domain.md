# FactoryFlow - Production Domain

## Scopo Del Documento

Questo documento definisce il modello concettuale della produzione industriale su cui deve crescere FactoryFlow.

Non parte dal software.

Non parte da AdHoc.

Non parte dal database.

Parte dalla fabbrica.

FactoryFlow deve poter descrivere una piccola azienda con una sola macchina, una media azienda con piu linee e una grande industria con processi complessi senza cambiare modello. Cambia soltanto il livello di dettaglio configurato.

Una PMI puo usare pochi concetti. Una grande industria puo usarli tutti. Il dominio deve rimanere lo stesso.

## Fonti Concettuali

FactoryFlow si ispira ai concetti consolidati di manufacturing, Lean Manufacturing, MES, ISA-95, operations management e production engineering.

Queste discipline indicano alcuni principi comuni:

- la produzione non e solo registrazione di quantita;
- il reparto produttivo lavora attraverso risorse, persone, tempi, materiali, qualita e vincoli;
- l'ERP governa le informazioni aziendali ufficiali;
- il MES governa l'esecuzione, il contesto operativo e la conoscenza prodotta dalla fabbrica;
- il valore non nasce dal dato isolato, ma dalla relazione tra dato, processo e decisione.

FactoryFlow non deve copiare uno standard. Deve interpretare questi principi dentro la propria filosofia: estendere AdHoc senza duplicarlo, modellare il processo reale e rendere migliori le decisioni operative.

## Principio Centrale

Il concetto centrale del dominio produttivo non e la macchina.

Non e la linea.

Non e la distinta.

Non e il documento ERP.

Il concetto centrale e il Processo Produttivo.

Il Processo Produttivo descrive come una fabbrica trasforma materiali, tempo, energia, lavoro e capacita in un risultato industriale.

La linea, la macchina, il team, il setup e la distinta partecipano al processo. Non lo sostituiscono.

Questa scelta e fondamentale perche il costo industriale, la capacita, la qualita e la produttivita non appartengono mai a un singolo elemento isolato. Nascono dall'interazione tra piu elementi dentro un processo.

## Processo Produttivo

### Definizione

Il Processo Produttivo e il modello stabile che descrive un percorso operativo della fabbrica. Non appartiene obbligatoriamente a un prodotto finito o a un articolo AdHoc.

Indica quali fasi sono necessarie, quali risorse possono essere usate, quali materiali vengono consumati, quali tempi sono attesi, quali setup sono richiesti e quali risultati devono essere ottenuti.

### Perche Esiste

Esiste per separare il percorso operativo dalla singola esecuzione avvenuta in un determinato giorno. Se una fase produce un articolo, l'articolo viene dichiarato nella chiusura di quella fase, non imposto come proprieta obbligatoria del processo.

Senza questo concetto, FactoryFlow rischierebbe di confondere:

- la ricetta produttiva;
- la linea usata oggi;
- la macchina disponibile oggi;
- la dichiarazione registrata oggi;
- il documento ERP generato oggi.

Sono cose diverse.

### Cosa Non Rappresenta

Non e una distinta base.

Non e una macchina.

Non e una linea.

Non e un documento.

Non e una dichiarazione.

Non e necessariamente un ciclo AdHoc, anche se puo usare un ciclo AdHoc come riferimento o fonte compatibile.

### Concetti Che Utilizza

Utilizza fasi, risorse produttive, linee, macchine, team operativo, setup, tempi, energia, qualita e regole di costo. Puo utilizzare prodotto finito, materiali e lotti solo nelle fasi che li richiedono.

### Concetti Che Dipendono Da Esso

Dipendono dal processo produttivo la pianificazione, la capacita, il costo industriale, la simulazione, il confronto tra alternative e l'analisi delle prestazioni.

### Ruolo Nel Calcolo Dei Costi

Il Processo Produttivo e il catalizzatore naturale del costo industriale.

Il costo non appartiene solo alla macchina, perche la stessa macchina puo costare diversamente in base al prodotto, al setup, alla durata, al team e alla fase.

Non appartiene solo alla linea, perche una linea puo svolgere processi diversi.

Non appartiene solo alla distinta, perche la distinta descrive i materiali, non il modo operativo con cui vengono trasformati.

Il costo industriale nasce dal processo eseguito in un contesto reale.

### Dominio

Il Processo Produttivo appartiene a FactoryFlow.

AdHoc puo possedere cicli, distinte e dati ERP correlati. FactoryFlow deve poter usare queste informazioni, ma il modello operativo completo del processo appartiene al dominio MES.

## Attivita Produttiva

### Definizione

L'Attivita Produttiva e l'esecuzione programmata o avviata di un processo produttivo in un periodo definito.

Risponde alla domanda: cosa deve accadere in fabbrica, quando, con quali risorse e con quale obiettivo?

### Perche Esiste

Esiste per collegare il processo teorico al lavoro reale.

Un processo dice come si produce. Un'attivita dice che quel processo viene eseguito oggi, su una certa linea, con certe risorse, per una certa quantita.

### Cosa Non Rappresenta

Non e ancora una produzione confermata.

Non e un documento ERP.

Non e una semplice riga di calendario.

### Concetti Che Utilizza

Utilizza processo produttivo, ordine produzione, ordine cliente, calendario, linea, macchina, team, quantita prevista, materiali e vincoli.

### Concetti Che Dipendono Da Esso

Dipendono dall'attivita la preparazione, la conferma, la dichiarazione, l'analisi del ritardo e il confronto tra previsto e consuntivo.

### Ruolo Nel Calcolo Dei Costi

L'attivita consente di stimare un costo previsto prima della conferma.

Il costo definitivo nasce solo quando l'attivita viene confermata con tempi, quantita, consumi e risorse effettive.

### Dominio

Appartiene a FactoryFlow.

AdHoc puo fornire ordini, articoli e fabbisogni. L'attivita produttiva come oggetto operativo appartiene al MES.

## Fase

### Definizione

La Fase e una parte ordinata del processo produttivo.

Descrive un passaggio significativo della trasformazione: preparazione, miscelazione, confezionamento, controllo, imballo, etichettatura o qualunque altra attivita industriale rilevante.

### Perche Esiste

Esiste per evitare che processi complessi vengano trattati come un unico blocco indistinto.

Una PMI puo avere un processo con una sola fase. Una grande industria puo avere molte fasi, eseguite da risorse diverse.

### Cosa Non Rappresenta

Non e obbligatoriamente una macchina.

Non e obbligatoriamente una riga di ciclo ERP.

Non e una dichiarazione.

### Concetti Che Utilizza

Utilizza risorse produttive, tempi, setup, materiali, controlli qualita e regole operative.

### Concetti Che Dipendono Da Esso

Dipendono dalla fase la capacita di dettaglio, il costo per fase, il controllo di avanzamento e l'analisi dei colli di bottiglia.

### Ruolo Nel Calcolo Dei Costi

La fase permette di attribuire costi e tempi al punto corretto del processo.

Senza fasi, il costo industriale puo essere calcolato solo in modo aggregato.

### Dominio

Appartiene a FactoryFlow quando serve descrivere il processo operativo. Eventuali cicli AdHoc possono essere fonte di riferimento, non proprietari esclusivi del concetto.

## Linea Di Produzione

### Definizione

La Linea di Produzione e un contesto operativo organizzato per eseguire una o piu attivita produttive.

Puo essere composta da una macchina, da piu macchine, da persone, da postazioni manuali o da una combinazione di risorse.

### Perche Esiste

Esiste per rappresentare il luogo logico-operativo in cui la fabbrica produce.

Una linea e cio che il responsabile produzione usa per ragionare su capacita, assegnazioni, disponibilita e responsabilita operative.

### Cosa Non Rappresenta

Non rappresenta sempre una macchina.

Non rappresenta necessariamente un reparto.

Non rappresenta un processo produttivo.

### Concetti Che Utilizza

Utilizza macchine, risorse, team, calendario, capacita e articoli producibili.

### Concetti Che Dipendono Da Esso

Dipendono dalla linea la schedulazione, l'assegnazione degli articoli, il confronto tra linee, la capacita disponibile e parte dell'analisi di rendimento.

### Ruolo Nel Calcolo Dei Costi

La linea partecipa al costo industriale quando possiede costi propri, vincoli di capacita, personale associato o configurazioni operative specifiche.

Non deve pero diventare l'unico proprietario del costo.

### Dominio

Appartiene a FactoryFlow.

AdHoc normalmente non governa il concetto operativo moderno di linea produttiva come lo richiede un MES.

## Macchina

### Definizione

La Macchina e una risorsa fisica utilizzata per eseguire una o piu fasi produttive.

Puo consumare energia, avere capacita nominale, richiedere setup, generare fermi, avere costi orari e caratteristiche tecniche.

### Perche Esiste

Esiste per rappresentare la capacita tecnica reale della fabbrica.

La macchina permette di misurare rendimento, consumo energetico, produttivita, saturazione e impatto economico.

### Cosa Non Rappresenta

Non rappresenta necessariamente una linea.

Non rappresenta un operatore.

Non rappresenta un processo.

Non rappresenta il valore della produzione.

### Concetti Che Utilizza

Utilizza caratteristiche tecniche, costi, energia, setup, tempo, manutenzione, capacita e collegamenti con linee o fasi.

### Concetti Che Dipendono Da Esso

Dipendono dalla macchina il benchmark produttivo, il consumo energetico atteso, il costo macchina, il confronto tra risorse alternative e parte dell'analisi di efficienza.

### Ruolo Nel Calcolo Dei Costi

La macchina contribuisce al costo industriale attraverso costo orario, tempo effettivo, energia, setup, ammortamento o costi indiretti attribuiti.

Il costo macchina e un componente del costo industriale, non il costo industriale completo.

### Dominio

Appartiene a FactoryFlow se AdHoc non possiede una anagrafica macchina sufficiente al modello operativo. Se in futuro esiste una fonte esterna ufficiale, FactoryFlow dovra integrarla senza duplicarla inutilmente.

## Risorsa Produttiva

### Definizione

La Risorsa Produttiva e qualunque elemento limitato che partecipa alla produzione: macchina, linea, postazione, stampo, attrezzatura, persona o gruppo di persone.

### Perche Esiste

Esiste per modellare la capacita senza vincolarsi subito al tipo fisico di risorsa.

Questo consente al modello di funzionare sia per produzioni automatiche sia per produzioni manuali.

### Cosa Non Rappresenta

Non e necessariamente una macchina.

Non e necessariamente una persona.

Non e un documento ERP.

### Concetti Che Utilizza

Utilizza calendario, capacita, disponibilita, costo, competenze e vincoli.

### Concetti Che Dipendono Da Esso

Dipendono dalle risorse la pianificazione, la simulazione, il calcolo della capacita, la saturazione e la scelta dell'alternativa produttiva.

### Ruolo Nel Calcolo Dei Costi

Ogni risorsa puo contribuire al costo in modo diverso: tempo, quantita, energia, presenza, setup o disponibilita.

### Dominio

Appartiene a FactoryFlow come concetto operativo MES.

## Team Operativo

### Definizione

Il Team Operativo e l'insieme delle persone coinvolte in una attivita produttiva, con ruoli, tempi di presenza e responsabilita operative.

### Perche Esiste

Esiste perche una produzione puo coinvolgere piu persone e non puo essere ridotta a un solo operatore.

### Cosa Non Rappresenta

Non rappresenta il valore della persona.

Non e uno strumento di giudizio individuale.

Non e una semplice lista di nomi.

### Concetti Che Utilizza

Utilizza operatori, ruoli operativi, orari, costo orario fotografato, note e competenze.

### Concetti Che Dipendono Da Esso

Dipendono dal team il costo manodopera, la ricostruzione storica dell'attivita, la comprensione delle condizioni operative e l'analisi del processo.

### Ruolo Nel Calcolo Dei Costi

Il team contribuisce al costo industriale tramite il tempo effettivo delle persone e il costo orario valido al momento dell'attivita.

Le modifiche future all'anagrafica delle persone non devono alterare i costi storici.

### Dominio

Appartiene a FactoryFlow, salvo esistenza di una fonte HR ufficiale da integrare. Anche in quel caso, FactoryFlow deve conservare la fotografia operativa della produzione.

## Operatore

### Definizione

L'Operatore e una persona che partecipa al processo produttivo con un ruolo operativo.

### Perche Esiste

Esiste per collegare l'attivita produttiva alle persone realmente coinvolte, nel rispetto del principio etico FactoryFlow: misurare il processo, non giudicare le persone.

### Cosa Non Rappresenta

Non rappresenta una metrica di valore umano.

Non e un costo astratto.

Non e un semplice campo descrittivo libero se il sistema deve ricostruire correttamente l'attivita.

### Concetti Che Utilizza

Utilizza ruoli, competenze, presenza, costo orario valido nel tempo e partecipazione alle attivita.

### Concetti Che Dipendono Da Esso

Dipendono dall'operatore il team operativo, la tracciabilita, il costo manodopera e la gestione futura delle competenze.

### Ruolo Nel Calcolo Dei Costi

L'operatore contribuisce al costo attraverso la sua presenza effettiva e il costo orario fotografato nel periodo valido.

### Dominio

Appartiene a FactoryFlow se non esiste una fonte HR ufficiale. Se esiste una fonte esterna, FactoryFlow deve referenziarla e fotografare i dati necessari al consuntivo.

## Setup

### Definizione

Il Setup e l'insieme delle attivita necessarie per preparare una risorsa produttiva a eseguire una produzione.

Puo essere standard della macchina, specifico dell'articolo, specifico della linea o dipendente dal cambio tra prodotto precedente e prodotto successivo.

### Perche Esiste

Esiste perche il tempo di preparazione e spesso uno dei fattori piu importanti nel costo industriale e nella capacita produttiva.

### Cosa Non Rappresenta

Non rappresenta produzione utile.

Non e sempre uguale per tutti gli articoli.

Non e sempre legato solo alla macchina.

### Concetti Che Utilizza

Utilizza macchina, linea, articolo, fase, tempo, team, energia e regole operative.

### Concetti Che Dipendono Da Esso

Dipendono dal setup la pianificazione, il costo, la capacita disponibile, il confronto tra sequenze produttive e le decisioni di anticipo o posticipo.

### Ruolo Nel Calcolo Dei Costi

Il setup e un costo specifico del processo. Deve essere separato dal tempo produttivo perche non cresce necessariamente con la quantita prodotta.

### Dominio

Appartiene a FactoryFlow.

AdHoc puo avere informazioni semplificate di ciclo, ma il setup operativo completo appartiene al MES.

## Distinta Base

### Definizione

La Distinta Base descrive quali materiali sono necessari per ottenere un prodotto finito e in quali quantita teoriche.

### Perche Esiste

Esiste per definire la composizione materiale del prodotto.

### Cosa Non Rappresenta

Non rappresenta il processo completo.

Non rappresenta la macchina.

Non rappresenta il tempo.

Non rappresenta il setup.

Non rappresenta il costo industriale completo.

### Concetti Che Utilizza

Utilizza prodotto finito, componenti, unita di misura e quantita.

### Concetti Che Dipendono Da Esso

Dipendono dalla distinta il fabbisogno materiali, lo scarico componenti, la simulazione disponibilita e parte del costo materiali.

### Ruolo Nel Calcolo Dei Costi

La distinta contribuisce al costo materiali. Non basta per calcolare il costo industriale.

### Dominio

Appartiene ad AdHoc.

FactoryFlow la legge, la interpreta e ne usa i risultati operativi senza duplicarla.

## Materiale

### Definizione

Il Materiale e un articolo consumato o trasformato durante la produzione.

### Perche Esiste

Esiste per rappresentare cio che entra nel processo produttivo.

### Cosa Non Rappresenta

Non rappresenta una risorsa produttiva.

Non rappresenta un processo.

Non rappresenta una disponibilita se non e collegato a magazzino e lotti.

### Concetti Che Utilizza

Utilizza articolo, lotto, disponibilita, scorta, magazzino e unita di misura.

### Concetti Che Dipendono Da Esso

Dipendono dai materiali il consumo, il costo materiali, la tracciabilita, la disponibilita produttiva e l'MRP.

### Ruolo Nel Calcolo Dei Costi

Il materiale contribuisce al costo industriale attraverso quantita consumata, valorizzazione, scarti e differenze rispetto alla distinta teorica.

### Dominio

L'anagrafica materiale appartiene ad AdHoc. Il consumo operativo e la fotografia della produzione appartengono a FactoryFlow e ai documenti ERP generati.

## Prodotto Finito

### Definizione

Il Prodotto Finito e l'articolo ottenuto dal processo produttivo.

### Perche Esiste

Esiste come risultato industriale ed economico della produzione.

### Cosa Non Rappresenta

Non rappresenta il processo con cui e stato realizzato.

Non rappresenta automaticamente una linea.

Non rappresenta automaticamente un costo.

### Concetti Che Utilizza

Utilizza articolo, distinta, processo produttivo, lotto, qualita e documento ERP.

### Concetti Che Dipendono Da Esso

Dipendono dal prodotto finito le dichiarazioni, il carico di magazzino, la tracciabilita e l'analisi di marginalita.

### Ruolo Nel Calcolo Dei Costi

Il prodotto finito riceve il costo industriale risultante dal processo eseguito.

### Dominio

L'articolo prodotto appartiene ad AdHoc. La sua esecuzione produttiva appartiene a FactoryFlow.

## Calendario

### Definizione

Il Calendario descrive quando la fabbrica puo, deve o ha effettivamente prodotto.

### Perche Esiste

Esiste per collegare tempo, capacita, attivita e decisioni.

### Cosa Non Rappresenta

Non e solo una vista grafica.

Non e solo una data documento.

Non e un elenco storico.

### Concetti Che Utilizza

Utilizza giornate, turni, disponibilita risorse, attivita previste, attivita confermate e vincoli.

### Concetti Che Dipendono Da Esso

Dipendono dal calendario pianificazione, capacita, previsioni, conferme e analisi ritardi.

### Ruolo Nel Calcolo Dei Costi

Il calendario influenza costi di tempo, straordinari, turni, disponibilita risorse e confronto previsto/consuntivo.

### Dominio

Appartiene a FactoryFlow per la parte operativa MES. Le date documento appartengono anche ad AdHoc quando vengono generati documenti ERP.

## Capacita

### Definizione

La Capacita e la quantita di lavoro che una risorsa, linea, macchina o processo puo sostenere in un periodo.

### Perche Esiste

Esiste per rispondere a una domanda essenziale: possiamo produrre cio che vogliamo produrre nel tempo disponibile?

### Cosa Non Rappresenta

Non e una giacenza.

Non e una quantita prodotta.

Non e una promessa commerciale.

### Concetti Che Utilizza

Utilizza calendario, tempi, risorse, rendimento, setup e disponibilita.

### Concetti Che Dipendono Da Esso

Dipendono dalla capacita la pianificazione, l'MRP evoluto, la scelta linea, la simulazione e il controllo dei colli di bottiglia.

### Ruolo Nel Calcolo Dei Costi

La capacita influenza il costo perche risorse sature, setup frequenti o rendimenti bassi aumentano il costo industriale effettivo.

### Dominio

Appartiene a FactoryFlow.

## Tempo

### Definizione

Il Tempo e la dimensione che permette di misurare durata, attesa, setup, produzione effettiva, fermo e presenza.

### Perche Esiste

Esiste perche senza tempo non esiste capacita, produttivita, costo orario o confronto tra previsto e consuntivo.

### Cosa Non Rappresenta

Non e solo la data.

Non e solo l'ora documento.

Non e sempre tempo produttivo utile.

### Concetti Che Utilizza

Utilizza attivita, risorse, operatori, setup, calendario e fasi.

### Concetti Che Dipendono Da Esso

Dipendono dal tempo produttivita, costo macchina, costo manodopera, energia, rendimento e capacita.

### Ruolo Nel Calcolo Dei Costi

Il tempo e uno dei driver principali del costo industriale: trasforma costi orari in costi effettivi.

### Dominio

Appartiene a FactoryFlow per il contesto operativo. AdHoc puo conservare date documento, ma non governa il tempo produttivo reale.

## Costo

### Definizione

Il Costo e il valore economico attribuito a un elemento che partecipa alla produzione.

### Perche Esiste

Esiste per misurare l'impatto economico di materiali, tempo, risorse, energia, setup e persone.

### Cosa Non Rappresenta

Non rappresenta da solo il costo industriale completo.

Non e sempre fisso.

Non e sempre variabile.

Non deve essere retroattivamente modificabile se ha contribuito a un consuntivo storico.

### Concetti Che Utilizza

Utilizza validita temporale, driver di calcolo, quantita, tempo, risorsa e fotografia storica.

### Concetti Che Dipendono Da Esso

Dipendono dal costo analisi industriale, marginalita, confronto tra alternative e decisioni operative.

### Ruolo Nel Calcolo Dei Costi

Il costo e un componente elementare. Il costo industriale e la composizione ordinata dei costi elementari.

### Dominio

Il costo standard ERP puo appartenere ad AdHoc. I costi operativi MES, le metriche e la fotografia produttiva appartengono a FactoryFlow.

## Costo Industriale

### Definizione

Il Costo Industriale e la misura economica complessiva della produzione reale o prevista di un prodotto.

Comprende materiali, setup, macchina, energia, personale, tempo, costi indiretti e costi specifici del processo.

### Perche Esiste

Esiste per capire quanto costa davvero produrre.

Non serve solo alla contabilita. Serve a decidere dove produrre, quando produrre, se anticipare, se posticipare, se cambiare sequenza, se migliorare un setup o se intervenire su una risorsa.

### Cosa Non Rappresenta

Non e il solo costo materiali.

Non e il solo costo macchina.

Non e il costo standard ERP.

Non e un valore da ricalcolare alterando il passato.

### Concetti Che Utilizza

Utilizza processo, attivita, materiali, risorse, team, tempi, setup, energia, qualita e costi indiretti.

### Concetti Che Dipendono Da Esso

Dipendono dal costo industriale analisi margini, decisioni produttive, simulazioni, pricing interno e miglioramento continuo.

### Ruolo Nel Calcolo Dei Costi

E il risultato del calcolo.

Deve essere sempre ricostruibile storicamente.

### Dominio

La fotografia e il calcolo operativo appartengono a FactoryFlow. Eventuali costi ufficiali contabili restano in AdHoc.

## Qualita

### Definizione

La Qualita descrive la conformita del risultato produttivo rispetto a requisiti, controlli, standard e aspettative.

### Perche Esiste

Esiste perche produrre una quantita non significa necessariamente produrre bene.

### Cosa Non Rappresenta

Non e solo uno scarto.

Non e solo una nota.

Non e un giudizio generico sull'operatore.

### Concetti Che Utilizza

Utilizza prodotto, lotto, processo, fase, controlli, non conformita e storico.

### Concetti Che Dipendono Da Esso

Dipendono dalla qualita tracciabilita, decisioni di rilavorazione, analisi scarti, costo non qualita e miglioramento processo.

### Ruolo Nel Calcolo Dei Costi

La qualita influenza il costo industriale attraverso scarti, rilavorazioni, fermi, consumi aggiuntivi e perdite di capacita.

### Dominio

AdHoc puo governare lotti e documenti. FactoryFlow deve governare il contesto operativo di qualita se non coperto da un sistema qualita dedicato.

## Energia

### Definizione

L'Energia e il consumo energetico associato a risorse, macchine, fasi o attivita produttive.

### Perche Esiste

Esiste perche in molte produzioni il costo energetico e una componente industriale rilevante e misurabile.

### Cosa Non Rappresenta

Non e un costo macchina generico.

Non e sempre proporzionale alla quantita prodotta.

Non e sempre uguale tra spunto, regime, attesa e fermo.

### Concetti Che Utilizza

Utilizza macchina, tempo, fase, quantita, profili di consumo e costo energia.

### Concetti Che Dipendono Da Esso

Dipendono dall'energia costo industriale, analisi efficienza e decisioni di sequenza o saturazione.

### Ruolo Nel Calcolo Dei Costi

L'energia contribuisce al costo industriale in base a consumo stimato o misurato e costo unitario valido nel periodo.

### Dominio

Appartiene a FactoryFlow come metrica operativa, salvo integrazione futura con sistemi energetici esterni.

## Ordine Produzione

### Definizione

L'Ordine Produzione e la richiesta di produrre un certo articolo, in una certa quantita, per una certa esigenza.

### Perche Esiste

Esiste per collegare domanda, pianificazione e produzione.

### Cosa Non Rappresenta

Non e la produzione eseguita.

Non e il documento ERP di carico o scarico.

Non e necessariamente una dichiarazione.

### Concetti Che Utilizza

Utilizza articolo, quantita, data richiesta, priorita, ordine cliente, disponibilita e processo produttivo.

### Concetti Che Dipendono Da Esso

Dipendono dall'ordine produzione attivita produttive, pianificazione, avanzamento e confronto tra richiesto e prodotto.

### Ruolo Nel Calcolo Dei Costi

L'ordine produzione consente di stimare costi previsti e confrontarli con costi consuntivi.

### Dominio

Puo appartenere ad AdHoc se l'ERP lo governa ufficialmente. FactoryFlow puo introdurre previsioni o attivita operative collegate senza duplicare l'ordine ERP.

## Ordine Cliente

### Definizione

L'Ordine Cliente rappresenta la domanda commerciale che puo generare fabbisogno produttivo.

### Perche Esiste

Esiste per collegare fabbrica e impegno verso il cliente.

### Cosa Non Rappresenta

Non e una produzione.

Non e una disponibilita.

Non e un processo produttivo.

### Concetti Che Utilizza

Utilizza cliente, articolo, quantita, data consegna, priorita e stato.

### Concetti Che Dipendono Da Esso

Dipendono dall'ordine cliente MRP, priorita, rischio ritardo, pianificazione e decisioni di anticipo.

### Ruolo Nel Calcolo Dei Costi

L'ordine cliente non calcola il costo industriale, ma rende possibile valutare margine, urgenza e convenienza delle scelte produttive.

### Dominio

Appartiene ad AdHoc.

FactoryFlow lo usa come domanda e vincolo decisionale.

## Differenze Fondamentali

### Processo

Il Processo descrive come si puo produrre.

E stabile, riutilizzabile e indipendente dalla singola giornata.

### Attivita

L'Attivita descrive cosa viene programmato o svolto in un momento specifico.

E il processo calato nel calendario e nelle risorse disponibili.

### Produzione

La Produzione e il fatto industriale: la trasformazione reale di materiali e risorse in prodotto.

### Dichiarazione

La Dichiarazione e l'atto con cui FactoryFlow registra o conferma cio che e stato prodotto, con quantita, tempi, lotti, risorse e contesto operativo.

### Documento ERP

Il Documento ERP e l'effetto gestionale ufficiale generato in AdHoc: carico prodotto finito, scarico componenti e aggiornamento delle giacenze.

## Domande Critiche

### Una Linea Di Produzione Coincide Con Una Macchina?

Puo coincidere, ma non deve essere definita come coincidente.

In una PMI con una sola macchina, linea e macchina possono apparire come lo stesso oggetto operativo. Il modello deve permettere questa semplificazione.

In una fabbrica piu strutturata, una linea puo includere piu macchine, postazioni manuali, persone e attrezzature. Una macchina puo essere solo una parte della linea.

Conclusione: linea e macchina devono restare concetti distinti, anche quando nella pratica coincidono.

### Una Macchina Puo Appartenere A Piu Linee?

Si, in alcuni casi.

Una macchina mobile, condivisa, attrezzabile o usata a turnazione puo essere assegnata a linee diverse in periodi diversi.

Se la macchina e fisicamente integrata in una sola linea, l'associazione sara stabile.

Conclusione: il modello deve permettere associazioni temporali tra macchine e linee. Non deve imporre una appartenenza eterna.

### Il Processo Produttivo E Proprieta Del Prodotto, Della Linea O Della Macchina?

Il processo produttivo e un concetto indipendente.

E collegato al prodotto perche descrive come realizzarlo.

E collegato alla linea perche una linea puo eseguirlo.

E collegato alla macchina perche una macchina puo parteciparvi.

Ma non appartiene completamente a nessuno di questi tre elementi.

Un prodotto puo avere piu processi alternativi. Una linea puo eseguire piu processi. Una macchina puo partecipare a processi diversi.

Conclusione: il processo produttivo deve essere modellato come entita concettuale autonoma.

### A Chi Appartiene Il Costo Industriale?

Il costo industriale appartiene al processo produttivo eseguito in un contesto reale.

Non appartiene solo alla macchina.

Non appartiene solo alla linea.

Non appartiene solo alla distinta.

Non appartiene solo al prodotto.

Il prodotto riceve il costo. Il processo lo genera. La dichiarazione lo fotografa.

Conclusione: FactoryFlow deve calcolare e conservare il costo industriale come fotografia dell'attivita produttiva confermata.

## Componenti Del Costo Industriale

### Costi Materiali

Derivano dai componenti consumati, dai lotti, dalle quantita effettive, dagli scarti e dalla valorizzazione materiale.

Fonte principale: AdHoc per articoli, lotti, documenti e valorizzazioni ufficiali.

FactoryFlow deve conservare la fotografia operativa del consumo.

### Costi Setup

Derivano dalla preparazione della risorsa produttiva.

Devono essere separati tra setup standard, setup specifico articolo, setup specifico linea e setup da cambio produzione.

Fonte principale: FactoryFlow.

### Costi Macchina

Derivano dal tempo di utilizzo, dal costo orario, dalla capacita, dagli ammortamenti o dai parametri operativi associati alla macchina.

Fonte principale: FactoryFlow, salvo integrazioni esterne.

### Costi Energia

Derivano da consumi a spunto, consumi a regime, durata e costo dell'energia.

Fonte principale: FactoryFlow o sistemi di misura energetica futuri.

### Costi Personale

Derivano dal team operativo, dai ruoli, dalle presenze e dai costi orari validi al momento.

Fonte principale: FactoryFlow o fonte HR esterna integrata.

### Costi Tempo

Derivano dalla durata reale di produzione, attesa, setup, fermo e rilavorazione.

Fonte principale: FactoryFlow.

### Costi Indiretti

Derivano da ripartizioni industriali, struttura, reparto o criteri di controllo di gestione.

Fonte possibile: FactoryFlow o sistemi amministrativi, a seconda della governance aziendale.

### Costi Specifici Del Processo

Derivano da caratteristiche particolari del processo: controlli aggiuntivi, pulizie, sanificazioni, attrezzaggi speciali, collaudi o condizioni operative non riducibili a macchina o materiale.

Fonte principale: FactoryFlow.

## Scalabilita Del Modello

### Caso 1 - PMI Con Una Sola Macchina

La fabbrica puo configurare un solo contesto produttivo.

Linea, macchina e processo possono coincidere operativamente, ma il modello non deve obbligare l'utente a gestire complessita inutile.

FactoryFlow deve consentire una configurazione minima:

- una linea;
- una macchina opzionale o coincidente;
- un processo semplice;
- una dichiarazione con tempi, materiali e quantita.

Il modello resta corretto anche se molti concetti vengono usati in forma semplificata.

### Caso 2 - Media Azienda Con Piu Linee

La fabbrica possiede piu linee, alcune macchine condivise, setup differenti e articoli producibili su risorse alternative.

FactoryFlow deve distinguere:

- linee;
- macchine;
- associazioni temporali;
- setup per articolo/linea;
- team;
- capacita;
- costi per contesto operativo.

Il modello deve supportare il confronto: dove conviene produrre?

### Caso 3 - Grande Industria

Il processo e composto da molte fasi.

Ogni fase puo essere eseguita da risorse differenti.

Il modello deve supportare:

- fasi multiple;
- risorse alternative;
- calendari;
- capacita per fase;
- costi dettagliati;
- qualita;
- energia;
- simulazioni;
- confronto tra previsto e consuntivo.

La struttura concettuale non cambia. Aumenta soltanto il livello di dettaglio.

## Implicazioni Architetturali

### 1. Non Appiattire Il Dominio Sulle Schermate

Una schermata puo mostrare una linea, una macchina o una dichiarazione, ma non deve definire il dominio.

Il dominio deve rimanere piu stabile delle interfacce.

### 2. Non Confondere Configurazione E Consuntivo

Le configurazioni cambiano.

I consuntivi storici devono restare ricostruibili.

Qualunque elemento che influenza costi, tempi, capacita o produttivita deve essere versionato o fotografato.

### 3. Non Usare AdHoc Come Limite Concettuale

AdHoc resta fonte ufficiale ERP.

FactoryFlow non deve duplicarlo, ma nemmeno ridurre il proprio dominio a cio che AdHoc espone.

Se AdHoc possiede la distinta, FactoryFlow la usa.

Se AdHoc non possiede il team operativo, FactoryFlow lo governa.

Se AdHoc possiede documenti, FactoryFlow li genera rispettando le regole ufficiali.

### 4. Il Costo Industriale Richiede Contesto

Un costo senza contesto e pericoloso.

Il costo di una produzione deve sapere:

- cosa e stato prodotto;
- con quale processo;
- su quale linea;
- con quale macchina;
- con quale team;
- con quali tempi;
- con quali materiali;
- con quali lotti;
- con quali setup;
- con quale energia;
- in quale data.

Senza questa fotografia, il costo non e storia industriale. E solo un numero.

## Critica Alle Scelte Gia Emersione Nel Progetto

### Linea E Macchina Non Devono Essere Fuse

Se in alcune schermate la macchina appare come semplice attributo della linea, e accettabile solo come semplificazione UI.

Concettualmente devono restare distinte.

Una futura evoluzione su capacita, setup, energia e costo macchina richiede questa separazione.

### Il Team Non E Un Dettaglio Decorativo

Il team operativo non e un'aggiunta opzionale di interfaccia.

E parte del contesto produttivo.

Se partecipa al costo o alla ricostruzione storica, deve essere trattato con validita temporale e fotografia storica.

### I Costi Non Devono Essere Aggiornati Retroattivamente

Qualunque costo orario, costo macchina, parametro energetico o regola di setup che ha contribuito a una produzione confermata non deve alterare il passato.

La modifica di oggi deve valere da oggi in avanti.

### I Master Senza Dettagli Vanno Giustificati

Se un concetto vive solo attraverso i suoi dettagli, non deve essere salvato incompleto.

Un team senza operatori, una regola setup senza contesto o una configurazione costo priva di driver rischiano di creare dati inutili.

Eccezione: un master puo esistere senza dettaglio solo quando produce valore autonomo.

## Decisione Di Dominio

FactoryFlow deve considerare il Processo Produttivo come concetto ordinatore del dominio industriale.

La Dichiarazione di Produzione non deve essere vista come il centro del sistema, ma come la fotografia consuntiva o previsionale di una attivita produttiva.

Il Documento ERP non deve essere visto come il fatto produttivo, ma come l'effetto gestionale ufficiale prodotto da FactoryFlow in AdHoc.

Questa distinzione protegge il progetto.

Permette di crescere verso pianificazione, MRP, capacita, costi industriali, qualita, energia e Factory Intelligence senza dover rifare il modello.

## Chiusura

FactoryFlow deve descrivere una fabbrica prima di descrivere un software.

Una fabbrica non e fatta solo di articoli e documenti.

E fatta di processi, persone, risorse, vincoli, tempi, materiali, energia, qualita e decisioni.

Il compito di FactoryFlow e collegare questi elementi in un modello unico, semplice quando la fabbrica e semplice, ricco quando la fabbrica e complessa.

Il modello non deve inseguire l'urgenza della singola funzione.

Deve proteggere la comprensione della produzione industriale per molti anni.

## Correzione Dominio 2026-07-06 - Processo, Fasi, Chiusura Fase

Questa sezione prevale su ogni interpretazione precedente che colleghi rigidamente il Processo Produttivo a un Prodotto Finito o a un Articolo AdHoc.

Il Processo Produttivo rappresenta un percorso operativo.

La Versione Processo stabilizza quel percorso nel tempo.

La Fase Processo dichiara quali dati saranno obbligatori alla sua chiusura.

La Chiusura fase registra il consuntivo reale.

Il Documento ERP AdHoc viene generato solo se la fase lo richiede.

Il prodotto finito non e un attributo obbligatorio del processo. Diventa un dato della chiusura fase quando la fase produce un articolo.

Esempi:

- preparazione macchina: richiede macchina, operatori, orari e note; non genera ERP;
- setup: richiede macchina, team, tipo setup, orari e note; normalmente non genera ERP;
- tostatura: puo richiedere macchina, team, orari, quantita, lotto e componenti; puo generare ERP;
- confezionamento: puo richiedere articolo prodotto, quantita, lotto PF, componenti, lotti consumati, macchina e team; puo generare ERP;
- controllo qualita: richiede esito, note ed eventuali non conformita; non necessariamente genera ERP.

La precedente espressione "dichiarazione produzione" resta valida come compatibilita operativa dell'MVP, ma il concetto corretto diventa "chiusura fase produttiva con effetto ERP".

