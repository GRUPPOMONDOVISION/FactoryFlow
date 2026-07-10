# FactoryFlow - Process Model

## Premessa

FactoryFlow non deve essere descritto come un insieme di moduli software.

FactoryFlow deve essere descritto come un insieme di processi aziendali.

Una fabbrica non lavora per schermate, tabelle o API. Una fabbrica lavora trasformando domanda in decisioni, decisioni in piani, piani in attivita', attivita' in produzione, produzione in documenti ufficiali, documenti in conoscenza e conoscenza in miglioramento.

Il compito di FactoryFlow e' rendere leggibile, governabile e migliorabile questo ciclo.

Il ciclo completo della fabbrica viene descritto cosi':

Domanda

↓

Decisione

↓

Pianificazione

↓

Preparazione

↓

Attivita' produttiva

↓

Produzione

↓

Conferma

↓

Documento ERP

↓

Analisi

↓

Miglioramento

Ogni fase ha un significato preciso. Alcune informazioni appartengono ad AdHoc, altre a FactoryFlow. Alcune non devono essere salvate, ma solo calcolate o visualizzate.

## 1. Domanda

### Obiettivo

Comprendere che cosa l'azienda deve produrre, per chi, entro quando e con quali priorita'.

La domanda e' il punto di partenza del processo produttivo. Senza domanda non esiste pianificazione utile, ma solo occupazione di capacita'.

### Input

- Ordini cliente.
- Previsioni commerciali.
- Scorte minime.
- Fabbisogni interni.
- Richieste di reintegro.
- Storico vendite.
- Urgenze operative.

### Output

- Elenco dei fabbisogni produttivi.
- Priorita' iniziali.
- Articoli da valutare per la produzione.
- Date richieste o desiderate.
- Quantita' richieste.

### Attori coinvolti

- Imprenditore.
- Responsabile commerciale.
- Responsabile produzione.
- Pianificatore.
- Ufficio acquisti.
- Magazzino.

### Decisioni

- Quali richieste devono diventare produzione.
- Quali richieste sono urgenti.
- Quali richieste possono essere posticipate.
- Quali articoli devono essere prodotti per scorta.
- Quali ordini cliente sono a rischio.

### Dati AdHoc

- Ordini cliente.
- Anagrafiche articoli.
- Giacenze.
- Lotti.
- Ordini fornitori.
- Eventuali ordini produzione gia' presenti.
- Listini e condizioni commerciali, se utili all'analisi.

### Dati FactoryFlow

- Priorita' operative proprie.
- Note operative di pianificazione.
- Associazioni linea-articolo.
- Storico dichiarazioni FactoryFlow.
- Eventuali previsioni non ancora confermate.
- Calendario operativo.

### Errori possibili

- Confondere domanda commerciale con produzione gia' decisa.
- Pianificare senza verificare materiali e capacita'.
- Usare scorte non realmente disponibili.
- Ignorare ordini cliente con data critica.
- Duplicare in FactoryFlow dati gia' ufficiali in AdHoc.

### Indicatori di qualita'

- Percentuale ordini cliente coperti da pianificazione.
- Numero ordini a rischio ritardo.
- Fabbisogni non coperti da materiale.
- Accuratezza delle previsioni.
- Tempo medio tra domanda e decisione produttiva.

## 2. Decisione

### Obiettivo

Trasformare la domanda in una scelta operativa consapevole.

La decisione risponde a domande come: possiamo produrre? Quando conviene produrre? Su quale linea? Con quali materiali? Quale ordine deve avere priorita'?

### Input

- Domanda raccolta.
- Disponibilita' materiali.
- Capacita' produttiva.
- Calendario.
- Distinte base.
- Vincoli di lotto.
- Ordini fornitore in arrivo.
- Costi e tempi stimati.
- Storico produzioni.

### Output

- Scelta di produrre, rimandare o simulare.
- Priorita' produttive.
- Linea o risorsa suggerita.
- Lotto o strategia di consumo suggerita.
- Rischi evidenziati.
- Alternative operative.

### Attori coinvolti

- Imprenditore.
- Responsabile produzione.
- Pianificatore.
- Responsabile acquisti.
- Responsabile magazzino.

### Decisioni

- Produrre subito.
- Posticipare produzione.
- Anticipare produzione.
- Cambiare linea.
- Cambiare lotto.
- Generare richiesta di acquisto.
- Accettare una disponibilita' insufficiente come rischio operativo.

### Dati AdHoc

- Distinte base.
- Giacenze.
- Lotti e scadenze.
- Ordini cliente.
- Ordini fornitori.
- Articoli.
- Documenti e movimenti storici.

### Dati FactoryFlow

- Linee operative.
- Associazioni linea-articolo.
- Calendario dichiarazioni.
- Previsioni future.
- Storico dichiarazioni.
- Audit eventi.
- Simulazioni future.

### Errori possibili

- Prendere decisioni usando solo la giacenza senza considerare lotti e scadenze.
- Ignorare capacita' produttiva.
- Confondere disponibilita' con materiale effettivamente consumabile.
- Non distinguere una previsione da una produzione confermata.
- Automatizzare una decisione che richiede conferma umana.

### Indicatori di qualita'

- Numero decisioni prese con dati completi.
- Numero produzioni ripianificate.
- Numero blocchi evitati.
- Percentuale decisioni che rispettano poi la produzione reale.
- Tempo necessario per scegliere cosa produrre.

## 3. Pianificazione

### Obiettivo

Collocare le attivita' produttive nel tempo, rispettando priorita', capacita', materiali e vincoli.

La pianificazione non modifica ancora AdHoc come fatto produttivo. Organizza il lavoro futuro.

### Input

- Decisioni operative.
- Calendario produttivo.
- Linee disponibili.
- Macchine disponibili.
- Operatori disponibili.
- Distinte base.
- Disponibilita' componenti.
- Ordini cliente e fornitori.
- Previsioni gia' inserite.

### Output

- Attivita' produttive pianificate.
- Dichiarazioni future in stato `PREVISTA`, quando il processo richiede una registrazione gia' predisposta.
- Calendario aggiornato.
- Elenco rischi o vincoli.
- Carico previsto per linea o reparto.

### Attori coinvolti

- Pianificatore.
- Responsabile produzione.
- Responsabile reparto.
- Magazzino.
- Acquisti.

### Decisioni

- In quale giorno pianificare.
- Su quale linea pianificare.
- Quale quantita' prevedere.
- Se creare una previsione operativa.
- Se lasciare una domanda non pianificata.
- Se anticipare acquisti o spostare priorita'.

### Dati AdHoc

- Articoli.
- Distinte.
- Giacenze.
- Lotti.
- Ordini cliente.
- Ordini fornitore.

### Dati FactoryFlow

- Calendario.
- Linee produzione.
- Associazioni linea-articolo.
- Previsioni.
- Note operative.
- Stato delle dichiarazioni.

### Errori possibili

- Pianificare su linea non abilitata all'articolo.
- Pianificare ignorando componenti critici.
- Trattare una pianificazione come produzione gia' confermata.
- Creare documenti AdHoc per produzioni future.
- Non aggiornare il calendario dopo variazioni operative.

### Indicatori di qualita'

- Saturazione linee.
- Numero previsioni future.
- Numero previsioni convertite in conferme.
- Scostamento tra pianificato e confermato.
- Produzioni spostate o annullate.

## 4. Preparazione

### Obiettivo

Preparare tutto cio' che serve per eseguire l'attivita' produttiva: materiali, lotti, linea, macchina, operatori, attrezzature e informazioni.

La preparazione riduce il rischio che la produzione si blocchi quando arriva il momento di eseguirla.

### Input

- Pianificazione.
- Dichiarazioni previste.
- Distinta base.
- Disponibilita' lotti.
- Magazzini.
- Linea scelta.
- Quantita' previste.
- Vincoli di scadenza.

### Output

- Materiali pronti o segnalati come mancanti.
- Lotti candidati.
- Quantita' effettive da confermare.
- Linea pronta.
- Eventuali anomalie note prima dell'esecuzione.

### Attori coinvolti

- Operatore.
- Responsabile reparto.
- Magazzino.
- Pianificatore.
- Qualita', se coinvolta sui lotti.

### Decisioni

- Quali lotti preparare.
- Se sostituire un lotto.
- Se modificare quantita' prevista.
- Se procedere nonostante disponibilita' insufficiente.
- Se rinviare l'attivita'.

### Dati AdHoc

- Lotti esistenti.
- Scadenze.
- Giacenze e disponibilita'.
- Articoli gestiti a lotto.
- Distinte.

### Dati FactoryFlow

- Dichiarazione prevista.
- Componenti previsti.
- Lotto selezionato dall'operatore.
- Quantita' effettive preparate.
- Linea collegata.
- Audit modifiche.

### Errori possibili

- Selezionare un lotto scaduto.
- Usare lotto non coerente con articolo.
- Non distinguere lotto prodotto finito e lotto componente.
- Non aggiornare quantita' effettive prima della conferma.
- Preparare materiali per una previsione poi annullata.

### Indicatori di qualita'

- Numero attivita' preparate senza anomalie.
- Numero cambi lotto prima della conferma.
- Numero disponibilita' insufficienti rilevate.
- Tempo di preparazione medio.
- Produzioni bloccate in preparazione.

## 5. Attivita' produttiva

### Obiettivo

Eseguire il lavoro produttivo pianificato o richiesto.

L'attivita' produttiva e' il momento operativo in cui persone, macchine, linee, materiali e tempo vengono usati per produrre.

### Input

- Materiali preparati.
- Linea o macchina disponibile.
- Operatore disponibile.
- Quantita' da produrre.
- Lotti selezionati.
- Istruzioni operative.
- Eventuale dichiarazione prevista.

### Output

- Prodotto realizzato.
- Componenti effettivamente consumati.
- Quantita' prodotta reale.
- Lotto prodotto finito.
- Eventuali scarti o anomalie.
- Dati pronti per conferma.

### Attori coinvolti

- Operatore.
- Capo reparto.
- Responsabile produzione.
- Qualita'.
- Magazzino.

### Decisioni

- Continuare o fermare la produzione.
- Modificare quantita' effettiva.
- Cambiare lotto componente.
- Segnalare anomalia.
- Confermare parzialmente.

### Dati AdHoc

- Articoli.
- Lotti.
- Magazzini.
- Distinte ufficiali.

### Dati FactoryFlow

- Dichiarazione in lavorazione.
- Quantita' effettive.
- Lotti scelti.
- Linea utilizzata.
- Stato operativo.
- Eventuali eventi di reparto.

### Errori possibili

- Produrre su linea non prevista.
- Consumare lotto diverso senza aggiornare la dichiarazione.
- Confermare quantita' teoriche invece di effettive.
- Non registrare anomalie importanti.
- Procedere con dati incompleti.

### Indicatori di qualita'

- Scostamento quantita' proposta/effettiva.
- Numero cambi lotto durante produzione.
- Produzioni completate senza correzioni.
- Tempo effettivo rispetto al previsto.
- Eventi anomali per linea o articolo.

## 6. Produzione

### Obiettivo

Rappresentare il risultato reale dell'attivita' produttiva: cosa e' stato prodotto e con quali consumi.

La produzione e' il fatto industriale. Non e' ancora necessariamente documento ERP finche' non viene confermata.

### Input

- Attivita' eseguita.
- Quantita' prodotta.
- Lotto prodotto finito.
- Componenti consumati.
- Lotti componenti.
- Linea usata.
- Magazzini.

### Output

- Produzione pronta per conferma.
- Dati completi per generare documenti ERP.
- Eventuale differenza tra previsto ed effettivo.

### Attori coinvolti

- Operatore.
- Responsabile reparto.
- Responsabile produzione.

### Decisioni

- Confermare la produzione.
- Correggere quantita'.
- Correggere lotto.
- Annullare una registrazione errata.
- Rimandare la conferma se mancano dati.

### Dati AdHoc

- Nessun nuovo documento finche' la produzione non viene confermata.
- Dati ufficiali da usare come riferimento: articoli, lotti, magazzini, distinte.

### Dati FactoryFlow

- Dichiarazione di produzione.
- Stato della dichiarazione.
- Quantita' prodotta.
- Componenti effettivi.
- Lotto prodotto.
- Linea.

### Errori possibili

- Confondere produzione eseguita con documento ERP gia' creato.
- Confermare dati incompleti.
- Non valorizzare lotti obbligatori.
- Lasciare una produzione in stato incoerente.

### Indicatori di qualita'

- Produzioni confermate al primo tentativo.
- Produzioni con dati completi.
- Produzioni con scostamenti rilevanti.
- Produzioni annullate.
- Produzioni previste convertite in confermate.

## 7. Conferma

### Obiettivo

Trasformare una produzione o una previsione operativa in registrazione ufficiale, validata dall'operatore.

La conferma e' il punto di passaggio tra FactoryFlow e AdHoc.

### Input

- Dichiarazione completa.
- Quantita' effettive.
- Lotti validi.
- Magazzini.
- Linea.
- Configurazione attiva.
- Causali documentali.

### Output

- Stato dichiarazione `CONFERMATA`.
- Seriali AdHoc valorizzati.
- Documento carico prodotto finito.
- Documento scarico componenti.
- Audit di conferma.

### Attori coinvolti

- Operatore.
- Responsabile produzione.
- Sistema FactoryFlow.
- Sistema AdHoc.

### Decisioni

- Confermare ora.
- Correggere prima di confermare.
- Annullare.
- Non procedere se mancano dati obbligatori.

### Dati AdHoc

- Stored procedure ufficiale.
- Progressivi.
- DOC_MAST.
- DOC_DETT.
- SALDILOT.
- LOTTIART.
- Tabelle documentali e di magazzino.

### Dati FactoryFlow

- Dichiarazione.
- Componenti dichiarazione.
- Stato.
- Seriali AdHoc restituiti.
- Audit evento.

### Errori possibili

- Confermare una previsione in giorno diverso da quello previsto.
- Confermare senza lotti obbligatori.
- Fallimento stored procedure.
- Progressivi mancanti.
- Configurazione causali errata.
- Interruzione transazione.

### Indicatori di qualita'

- Conferme riuscite.
- Conferme fallite.
- Tempo medio di conferma.
- Errori per causale o lotto.
- Dichiarazioni previste non confermate nel giorno previsto.

## 8. Documento ERP

### Obiettivo

Registrare ufficialmente in AdHoc il carico del prodotto finito e lo scarico dei componenti.

Il documento ERP e' la verita' ufficiale per magazzino e lotti.

### Input

- Conferma FactoryFlow.
- Parametri documentali da configurazione e AdHoc.
- Componenti in JSON.
- Lotti e quantita'.
- Progressivi AdHoc.

### Output

- Documento carico prodotto finito.
- Documento scarico componenti.
- Righe documentali.
- Saldi lotto aggiornati.
- Seriali e numeri documento.

### Attori coinvolti

- Backend FactoryFlow.
- Stored procedure SQL.
- Database AdHoc.
- Operatore, come origine della conferma.

### Decisioni

- Nessuna decisione manuale in questa fase: la decisione e' gia' stata presa in conferma.
- Il sistema deve eseguire in modo transazionale.

### Dati AdHoc

- DOC_MAST.
- DOC_DETT.
- SALDILOT.
- LOTTIART.
- cpwarn.
- TIP_DOCU.
- Articoli e magazzini.

### Dati FactoryFlow

- Seriale carico.
- Numero carico.
- Seriale scarico.
- Numero scarico.
- Stato `CONFERMATA`.
- Audit.

### Errori possibili

- Stored non installata.
- Compatibility level non adeguato.
- Progressivo mancante.
- Causale errata.
- Lotto non coerente.
- Errore transazionale.
- SALDILOT non aggiornato.

### Indicatori di qualita'

- Documenti creati correttamente.
- Coerenza tra FactoryFlow e AdHoc.
- Saldi lotto aggiornati.
- Documenti apribili in AdHoc.
- Zero registrazioni parziali grazie alla transazione.

## 9. Analisi

### Obiettivo

Trasformare registrazioni e documenti in conoscenza utile.

L'analisi risponde a cosa e' successo, quanto e' costato, dove ci sono stati scostamenti e quali rischi emergono.

### Input

- Dichiarazioni FactoryFlow.
- Documenti AdHoc.
- Consumi effettivi.
- Lotti.
- Tempi.
- Linee.
- Eventi.
- Audit.
- Costi.

### Output

- Indicatori produttivi.
- Scostamenti previsto/effettivo.
- Analisi consumi.
- Analisi lotti.
- Analisi linee.
- Base conoscitiva per decisioni future.

### Attori coinvolti

- Imprenditore.
- Responsabile produzione.
- Controller.
- Pianificatore.
- Consulente.

### Decisioni

- Quale linea rende meglio.
- Quale articolo ha piu' scostamenti.
- Quale componente crea problemi.
- Quale produzione costa troppo.
- Dove intervenire per migliorare.

### Dati AdHoc

- Documenti ufficiali.
- Movimenti.
- Saldi.
- Costi standard o contabili, se disponibili.
- Ordini e anagrafiche.

### Dati FactoryFlow

- Storico dichiarazioni.
- Stato dichiarazioni.
- Previsioni e conferme.
- Linee operative.
- Audit.
- Eventuali costi calcolati o snapshot.

### Errori possibili

- Analizzare solo AdHoc perdendo il contesto operativo FactoryFlow.
- Analizzare solo FactoryFlow ignorando la verita' documentale AdHoc.
- Confondere previsione e conferma.
- Usare dati incompleti o non riconciliati.

### Indicatori di qualita'

- Scostamento consumo teorico/effettivo.
- Produzioni confermate rispetto a previste.
- Annullamenti.
- Errori di conferma.
- Rendimento linea.
- Costo industriale.
- Puntualita' produzione.

## 10. Miglioramento

### Obiettivo

Usare l'analisi per rendere la fabbrica piu' efficace, prevedibile e consapevole.

Il miglioramento e' la fase in cui la conoscenza produce cambiamento.

### Input

- Indicatori.
- Storico.
- Errori ricorrenti.
- Scostamenti.
- Ritardi.
- Costi industriali.
- Feedback operatori.
- Simulazioni.

### Output

- Nuove regole operative.
- Migliore pianificazione.
- Nuove soglie di attenzione.
- Azioni su linee, macchine o fornitori.
- Miglioramento dei dati di base.
- Decisioni piu' rapide.

### Attori coinvolti

- Imprenditore.
- Responsabile produzione.
- Responsabile qualita'.
- Controller.
- Pianificatore.
- Consulenti.
- Sviluppatori, se il miglioramento richiede evoluzione software.

### Decisioni

- Cambiare sequenza produttiva.
- Migliorare anagrafiche o distinte.
- Aggiornare regole di pianificazione.
- Intervenire su fornitori critici.
- Ridurre setup.
- Spostare produzioni su linee piu' adatte.
- Introdurre nuove misurazioni.

### Dati AdHoc

- Dati ufficiali storici.
- Documenti.
- Ordini.
- Articoli.
- Distinte.
- Costi ufficiali.

### Dati FactoryFlow

- Conoscenza operativa.
- Previsioni confrontate con conferme.
- Storico eventi.
- Audit.
- Linee e associazioni operative.
- Simulazioni.
- Indicatori MES.

### Errori possibili

- Migliorare il software senza migliorare il processo.
- Aggiungere moduli senza capire il problema aziendale.
- Salvare nuovi dati senza uno scopo decisionale.
- Duplicare dati AdHoc invece di valorizzarli.
- Confondere automazione con miglioramento.

### Indicatori di qualita'

- Riduzione ritardi.
- Riduzione errori di conferma.
- Riduzione scostamenti consumo.
- Miglioramento rendimento linee.
- Riduzione tempi di setup.
- Migliore puntualita' ordini.
- Migliore qualita' delle decisioni.

## Il ciclo come rete di conoscenza

Il processo non e' una sequenza rigida. Ogni fase produce conoscenza che puo' influenzare le altre.

Una conferma errata migliora la preparazione futura.

Uno scostamento di consumo migliora la distinta o la formazione operatore.

Un ritardo fornitore migliora l'MRP.

Una previsione non confermata migliora la pianificazione.

Un costo industriale anomalo migliora la scelta della linea.

FactoryFlow deve rendere visibile questa rete di relazioni.

## Confine tra AdHoc e FactoryFlow nel processo

AdHoc resta la fonte ufficiale per dati ERP:

- articoli;
- distinte;
- documenti;
- magazzino;
- lotti;
- saldi;
- ordini;
- progressivi;
- causali.

FactoryFlow gestisce il processo operativo moderno:

- calendario;
- linee;
- associazioni operative;
- dichiarazioni previste;
- conferme operative;
- audit;
- analisi;
- conoscenza;
- decisioni.

Il confine e' fondamentale.

Quando la fabbrica sta organizzando il futuro, FactoryFlow puo' registrare una previsione.

Quando la fabbrica conferma un fatto produttivo, FactoryFlow deve generare il documento ERP ufficiale in AdHoc.

## Chiusura

FactoryFlow non e' costruito attorno ai moduli software.

FactoryFlow e' costruito attorno ai processi reali della fabbrica.

I moduli possono cambiare.

Le schermate possono cambiare.

Le API possono cambiare.

Il processo resta: domanda, decisione, pianificazione, preparazione, attivita' produttiva, produzione, conferma, documento ERP, analisi e miglioramento.

FactoryFlow esiste per rendere questo ciclo piu' chiaro, piu' controllabile e piu' intelligente.

## Estensione Processo: Costi E Team

Nel passaggio da attivita produttiva a conferma, FactoryFlow raccoglie anche il contesto operativo: team coinvolto, ruoli, tempi e note. Dopo la conferma, quando i dati sono sufficienti, calcola una fotografia dei costi industriali: setup, tempo, quantita, energia, manodopera, macchina e costo totale.

Se i dati di costo sono incompleti, la produzione non viene bloccata. Il processo produttivo resta prioritario; l'analisi economica viene marcata come incompleta e potra essere raffinata.
