# FactoryFlow - Decision Model

## Scopo Del Documento

FactoryFlow non è progettato per registrare dati.

FactoryFlow è progettato per aiutare imprenditori, responsabili produzione e pianificatori a prendere decisioni migliori.

Ogni funzionalità del sistema deve quindi essere riconducibile a una decisione aziendale.

Registrare una produzione, leggere una distinta, mostrare una disponibilità o calcolare un costo non sono obiettivi finali. Sono passaggi necessari per rispondere a domande operative:

- posso produrre?
- cosa rischio di non consegnare?
- quale vincolo mi blocca?
- dove conviene produrre?
- quale scelta costa meno?
- quale alternativa è più sicura?

Questo documento descrive il modello decisionale della piattaforma.

## Principio Guida

Un dato ha valore solo se aiuta a decidere.

Una schermata ha valore solo se riduce incertezza.

Una funzione ha valore solo se porta l'utente più vicino a un'azione corretta.

FactoryFlow deve trasformare dati dispersi in risposte operative comprensibili.

## 1. Posso Produrre Oggi?

### Domanda Che L'utente Si Pone

Ho tutto ciò che serve per produrre oggi questo articolo?

### Informazioni Necessarie

- Produzione prevista;
- prodotto finito;
- distinta;
- componenti;
- disponibilità;
- lotti;
- calendario;
- capacità;
- linea;
- macchina;
- storico anomalie.

### Da Dove Provengono I Dati

AdHoc fornisce articoli, distinte, lotti, disponibilità e documenti.

FactoryFlow fornisce calendario operativo, capacità, risorse produttive e storico operativo.

### Moduli Coinvolti

- Produzione;
- disponibilità;
- distinta;
- lotti;
- calendario;
- capacità;
- pianificazione;
- MRP.

### Risposta

FactoryFlow deve rispondere:

- SÌ, la produzione è sostenibile;
- NO, mancano materiali o risorse;
- RISCHIO, la produzione è possibile ma con vincoli;
- ALTERNATIVA, esiste una soluzione migliore.

### Azione Consigliata

- Produrre subito;
- cambiare lotto;
- spostare linea;
- ripianificare;
- anticipare acquisto;
- ridurre quantità;
- attendere disponibilità futura.

## 2. Quale Linea Produttiva È Più Adatta?

### Domanda Che L'utente Si Pone

Su quale linea conviene produrre questo articolo?

### Informazioni Necessarie

- Prodotto finito;
- associazione linea-articolo;
- calendario;
- capacità;
- storico produzioni;
- tempi;
- setup;
- disponibilità risorse;
- qualità del rendimento.

### Da Dove Provengono I Dati

AdHoc fornisce articolo, distinta e dati ufficiali collegati al prodotto.

FactoryFlow fornisce linee operative, capacità, calendario, storico e rilevazioni.

### Moduli Coinvolti

- Linee;
- capacità;
- calendario;
- pianificazione;
- storico produzione;
- tempi;
- costi.

### Risposta

FactoryFlow deve indicare:

- linea consigliata;
- linee alternative;
- linee non utilizzabili;
- motivazione della scelta.

### Azione Consigliata

- Assegnare produzione alla linea migliore;
- spostare linea;
- usare linea alternativa;
- posticipare se la linea corretta non è disponibile.

## 3. Quale Macchina Conviene Utilizzare?

### Domanda Che L'utente Si Pone

Quale macchina mi permette di produrre meglio, prima o con minore costo?

### Informazioni Necessarie

- Macchine disponibili;
- stato operativo;
- capacità;
- tempi storici;
- setup;
- consumi energia;
- costi;
- calendario;
- produzione prevista.

### Da Dove Provengono I Dati

FactoryFlow fornisce dati operativi macchina, calendario, capacità e rilevazioni.

AdHoc fornisce il contesto ufficiale di articolo, distinta e documenti.

### Moduli Coinvolti

- Macchine;
- capacità;
- calendario;
- tempi;
- setup;
- energia;
- costi industriali;
- pianificazione.

### Risposta

FactoryFlow deve indicare:

- macchina consigliata;
- macchina alternativa;
- rischio di inefficienza;
- indisponibilità o saturazione.

### Azione Consigliata

- Utilizzare la macchina consigliata;
- cambiare macchina;
- attendere disponibilità;
- modificare sequenza produttiva;
- pianificare setup.

## 4. Quale Lotto Conviene Consumare?

### Domanda Che L'utente Si Pone

Quale lotto devo usare per consumare correttamente il materiale?

### Informazioni Necessarie

- Componenti;
- lotti disponibili;
- disponibilità lotto;
- scadenze;
- magazzino;
- quantità richiesta;
- storico problemi;
- vincoli qualità.

### Da Dove Provengono I Dati

AdHoc fornisce lotti, saldi, scadenze e magazzino.

FactoryFlow può fornire storico operativo e scelte precedenti.

### Moduli Coinvolti

- Produzione;
- lotti;
- disponibilità;
- distinta;
- qualità futura;
- storico.

### Risposta

FactoryFlow deve indicare:

- lotto consigliato;
- lotto sufficiente;
- lotto insufficiente;
- lotto a rischio scadenza;
- alternativa disponibile.

### Azione Consigliata

- Consumare lotto consigliato;
- cambiare lotto;
- dividere il consumo su più lotti;
- segnalare mancanza materiale;
- anticipare approvvigionamento.

## 5. Quale Ordine Cliente Rischia Di Arrivare In Ritardo?

### Domanda Che L'utente Si Pone

Quale consegna cliente è a rischio?

### Informazioni Necessarie

- Ordini clienti;
- date richieste;
- prodotti finiti;
- disponibilità materiali;
- pianificazione;
- capacità;
- avanzamento produzione;
- storico ritardi.

### Da Dove Provengono I Dati

AdHoc fornisce ordini clienti, articoli e disponibilità ufficiali.

FactoryFlow fornisce piano, capacità, avanzamento e storico operativo.

### Moduli Coinvolti

- Ordini clienti;
- pianificazione;
- MRP;
- disponibilità;
- capacità;
- produzione;
- dashboard.

### Risposta

FactoryFlow deve classificare:

- ordine puntuale;
- ordine a rischio;
- ordine in ritardo;
- ordine recuperabile con alternativa.

### Azione Consigliata

- Anticipare produzione;
- cambiare priorità;
- spostare linea;
- anticipare acquisto;
- proporre nuova data;
- avvisare il cliente.

## 6. Quale Componente Bloccherà Per Primo La Produzione?

### Domanda Che L'utente Si Pone

Qual è il primo materiale che impedirà di rispettare il piano?

### Informazioni Necessarie

- Distinte;
- componenti;
- disponibilità;
- lotti;
- ordini fornitori;
- consumi previsti;
- piano produzione;
- scadenze consegna.

### Da Dove Provengono I Dati

AdHoc fornisce distinte, giacenze, lotti e ordini fornitori.

FactoryFlow fornisce piano, simulazioni e priorità operative.

### Moduli Coinvolti

- MRP;
- distinta;
- disponibilità;
- ordini fornitori;
- pianificazione;
- simulazione.

### Risposta

FactoryFlow deve indicare:

- componente bloccante;
- data prevista del blocco;
- produzioni impattate;
- alternative possibili.

### Azione Consigliata

- Generare proposta acquisto;
- anticipare ordine fornitore;
- cambiare sequenza produzione;
- ridurre quantità;
- usare lotto o materiale alternativo se ammesso.

## 7. Qual È Il Costo Industriale Reale Di Questa Produzione?

### Domanda Che L'utente Si Pone

Quanto è costato davvero produrre questo articolo?

### Informazioni Necessarie

- Produzione;
- componenti consumati;
- costi standard;
- tempi;
- setup;
- energia;
- macchina;
- linea;
- quantità prodotta;
- storico rilevazioni.

### Da Dove Provengono I Dati

AdHoc fornisce documenti, componenti e costi ufficiali.

FactoryFlow fornisce tempi, setup, energia, risorse e fotografie di costo industriale.

### Moduli Coinvolti

- Produzione;
- costi industriali;
- tempi;
- setup;
- energia;
- linee;
- macchine.

### Risposta

FactoryFlow deve produrre:

- costo totale;
- costo per unità;
- principali componenti del costo;
- scostamento rispetto al teorico;
- cause probabili dello scostamento.

### Azione Consigliata

- Analizzare scostamento;
- cambiare linea o macchina;
- ridurre setup;
- verificare consumo componenti;
- rivedere parametri industriali.

## 8. Conviene Anticipare Una Produzione?

### Domanda Che L'utente Si Pone

È utile produrre prima del previsto?

### Informazioni Necessarie

- Ordini clienti;
- disponibilità materiali;
- capacità libera;
- calendario;
- scadenze lotti;
- setup;
- costi;
- priorità commerciali;
- piano attuale.

### Da Dove Provengono I Dati

AdHoc fornisce ordini, materiali e lotti.

FactoryFlow fornisce capacità, calendario, piani, costi e simulazioni.

### Moduli Coinvolti

- Pianificazione;
- MRP;
- capacità;
- calendario;
- costi;
- simulazione;
- ordini clienti.

### Risposta

FactoryFlow deve indicare:

- conviene anticipare;
- non conviene;
- anticipare genera rischio;
- anticipare è possibile solo cambiando sequenza.

### Azione Consigliata

- Anticipare produzione;
- mantenere piano;
- cambiare priorità;
- usare finestra libera;
- verificare acquisti.

## 9. Conviene Posticiparla?

### Domanda Che L'utente Si Pone

Posso spostare questa produzione più avanti senza creare problemi?

### Informazioni Necessarie

- Ordini clienti;
- scadenze;
- disponibilità materiali;
- capacità futura;
- calendario;
- urgenze;
- costi di cambio piano;
- storico ritardi.

### Da Dove Provengono I Dati

AdHoc fornisce domanda cliente e dati ufficiali.

FactoryFlow fornisce piano, capacità, simulazioni e storico.

### Moduli Coinvolti

- Pianificazione;
- ordini clienti;
- capacità;
- calendario;
- MRP;
- simulazione.

### Risposta

FactoryFlow deve indicare:

- posticipo sicuro;
- posticipo rischioso;
- posticipo non possibile;
- alternativa consigliata.

### Azione Consigliata

- Posticipare ordine;
- mantenere data;
- anticipare altro articolo;
- informare responsabile;
- ricalcolare piano.

## 10. Quale Produzione Dovrebbe Iniziare Domani Mattina?

### Domanda Che L'utente Si Pone

Qual è la migliore produzione da avviare per prima?

### Informazioni Necessarie

- Piano produzione;
- ordini clienti;
- priorità;
- disponibilità componenti;
- lotti;
- capacità;
- calendario;
- setup;
- linee e macchine disponibili.

### Da Dove Provengono I Dati

AdHoc fornisce domanda, materiali e lotti.

FactoryFlow fornisce piano, capacità, risorse, calendario e simulazioni.

### Moduli Coinvolti

- Pianificazione;
- MRP;
- disponibilità;
- calendario;
- capacità;
- linee;
- macchine;
- simulazione.

### Risposta

FactoryFlow deve indicare:

- produzione consigliata;
- produzioni alternative;
- motivazione della priorità;
- rischi se si sceglie diversamente.

### Azione Consigliata

- Avviare produzione consigliata;
- preparare materiali;
- riservare linea;
- predisporre setup;
- aggiornare piano.

## 11. Quale Macchina Sta Producendo Sotto Le Aspettative?

### Domanda Che L'utente Si Pone

Quale macchina rende meno del previsto?

### Informazioni Necessarie

- Produzioni eseguite;
- tempi teorici;
- tempi reali;
- capacità;
- fermi;
- setup;
- scarti futuri;
- storico macchina.

### Da Dove Provengono I Dati

FactoryFlow fornisce rilevazioni operative, tempi e stati macchina.

AdHoc può fornire documenti e riferimenti ufficiali.

### Moduli Coinvolti

- Macchine;
- tempi;
- setup;
- produzione;
- capacità;
- dashboard;
- costi.

### Risposta

FactoryFlow deve indicare:

- macchina sotto target;
- entità dello scostamento;
- possibili cause;
- confronto con altre macchine.

### Azione Consigliata

- Verificare macchina;
- controllare setup;
- analizzare fermi;
- spostare produzione;
- pianificare manutenzione.

## 12. Quale Linea Ha Il Miglior Rendimento?

### Domanda Che L'utente Si Pone

Quale linea produce meglio rispetto alle aspettative?

### Informazioni Necessarie

- Produzioni per linea;
- tempi;
- quantità;
- capacità;
- fermi;
- setup;
- energia;
- costi;
- storico.

### Da Dove Provengono I Dati

FactoryFlow fornisce linee, capacità, tempi e rilevazioni.

AdHoc fornisce documenti e dati ufficiali di produzione.

### Moduli Coinvolti

- Linee;
- produzione;
- tempi;
- capacità;
- energia;
- costi;
- dashboard.

### Risposta

FactoryFlow deve indicare:

- linea con miglior rendimento;
- motivazione;
- confronto tra linee;
- condizioni in cui la linea rende meglio.

### Azione Consigliata

- Assegnare articoli compatibili;
- replicare buone pratiche;
- rivedere pianificazione;
- usare la linea come riferimento.

## 13. Quale Fornitore Sta Creando Il Maggior Numero Di Ritardi?

### Domanda Che L'utente Si Pone

Quale fornitore impatta di più sulla puntualità produttiva?

### Informazioni Necessarie

- Ordini fornitori;
- date previste;
- date effettive;
- componenti;
- produzioni bloccate;
- storico ritardi;
- alternative disponibili.

### Da Dove Provengono I Dati

AdHoc fornisce fornitori, ordini e articoli.

FactoryFlow può collegare ritardi fornitore a piani e produzioni impattate.

### Moduli Coinvolti

- Ordini fornitori;
- MRP;
- disponibilità;
- pianificazione;
- simulazione;
- dashboard.

### Risposta

FactoryFlow deve indicare:

- fornitore più critico;
- componenti coinvolti;
- produzioni impattate;
- ritardo medio o ricorrente.

### Azione Consigliata

- Anticipare acquisto;
- cercare fornitore alternativo;
- aumentare scorta strategica;
- modificare priorità produttive;
- segnalare criticità agli acquisti.

## 14. Quali Articoli Stanno Assorbendo Più Energia?

### Domanda Che L'utente Si Pone

Quali produzioni o articoli consumano più energia?

### Informazioni Necessarie

- Produzioni;
- articoli;
- linee;
- macchine;
- energia rilevata;
- tempi;
- quantità prodotta;
- costo energia;
- storico.

### Da Dove Provengono I Dati

AdHoc fornisce articoli e produzioni ufficiali.

FactoryFlow fornisce energia, tempi, linee, macchine e analisi industriale.

### Moduli Coinvolti

- Produzione;
- energia;
- linee;
- macchine;
- tempi;
- costi;
- dashboard.

### Risposta

FactoryFlow deve indicare:

- articoli più energivori;
- consumo per unità;
- confronto tra linee o macchine;
- andamento storico.

### Azione Consigliata

- Verificare processo;
- spostare produzione su risorsa più efficiente;
- modificare sequenza;
- analizzare setup;
- rivedere costo industriale.

## 15. Quali Produzioni Generano Più Margine?

### Domanda Che L'utente Si Pone

Quali produzioni contribuiscono maggiormente al risultato industriale?

### Informazioni Necessarie

- Produzioni;
- costi industriali;
- prezzi o valori di riferimento;
- componenti;
- tempi;
- energia;
- setup;
- quantità;
- storico vendite o ordini.

### Da Dove Provengono I Dati

AdHoc fornisce documenti, costi ufficiali e dati commerciali.

FactoryFlow fornisce costi industriali, tempi, energia e rilevazioni operative.

### Moduli Coinvolti

- Produzione;
- costi industriali;
- ordini clienti;
- tempi;
- energia;
- dashboard;
- simulazione.

### Risposta

FactoryFlow deve indicare:

- produzioni più marginali;
- produzioni meno marginali;
- cause principali del margine;
- rischio di erosione del margine.

### Azione Consigliata

- Dare priorità a produzioni ad alto margine;
- analizzare produzioni critiche;
- ridurre costi operativi;
- rivedere sequenze;
- valutare prezzo o condizioni commerciali.

## La Piramide Decisionale FactoryFlow

FactoryFlow cresce per livelli decisionali.

### Livello 1 - Registrazione

Il sistema registra ciò che accade.

Esempio: una produzione viene dichiarata, un lotto viene scelto, un componente viene consumato.

Senza registrazione affidabile non esiste base decisionale.

↓

### Livello 2 - Conoscenza

Il sistema collega i dati registrati con il contesto.

Esempio: la produzione viene collegata a prodotto, distinta, componenti, lotti, linea, macchina, operatore e disponibilità.

La conoscenza nasce dalle relazioni.

↓

### Livello 3 - Analisi

Il sistema interpreta ciò che è successo o ciò che potrebbe succedere.

Esempio: confronta teorico ed effettivo, identifica scostamenti, misura capacità e rileva criticità.

L'analisi trasforma la conoscenza in comprensione.

↓

### Livello 4 - Decisione

Il sistema aiuta l'utente a scegliere.

Esempio: produrre oggi o aspettare, usare una linea o un'altra, anticipare un acquisto o modificare il piano.

La decisione riduce l'incertezza.

↓

### Livello 5 - Suggerimento

Il sistema propone un'azione.

Esempio: anticipare una produzione, cambiare lotto, spostare linea, generare una proposta acquisto.

Il suggerimento deve essere spiegabile e motivato.

↓

### Livello 6 - Factory Intelligence

Factory Intelligence è il livello superiore della conoscenza costruita correttamente.

L'AI non rappresenta il cuore del sistema.

Il cuore del sistema è la qualità dei dati, delle relazioni e delle decisioni che FactoryFlow rende possibili.

L'AI diventa utile solo quando può appoggiarsi a una conoscenza affidabile: registrazioni corrette, dati AdHoc coerenti, storico operativo, capacità, costi, tempi, disponibilità, pianificazione e simulazioni.

In questo contesto l'AI non deve limitarsi a rispondere a domande.

Deve aiutare l'azienda a capire cosa fare, perché farlo e quali conseguenze aspettarsi.

## Riflessione Finale

La qualità di FactoryFlow non sarà misurata dalla quantità di funzioni disponibili.

Sarà misurata dalla qualità delle decisioni che renderà possibili.

## Decisioni Abilitate Da Costi E Team

La nuova estensione rende possibili decisioni piu mature:

- quale assetto operativo rende piu stabile una produzione;
- quale linea o macchina assorbe piu costo reale;
- quanto incide il setup su un articolo;
- quando una produzione e economicamente anomala;
- quali condizioni di processo aiutano le persone a lavorare meglio.

La risposta FactoryFlow non deve giudicare le persone. Deve evidenziare condizioni operative, rischi e alternative.
