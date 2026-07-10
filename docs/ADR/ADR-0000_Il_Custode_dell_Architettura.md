# ADR-0000 - Il Custode Dell'Architettura

## Stato

★★★★★

Decisione permanente.

---

## Contesto

FactoryFlow non e un semplice progetto software.

FactoryFlow rappresenta un modello di conoscenza della fabbrica.

Nel tempo il progetto crescera, cambiera e verra modificato da persone diverse.

La pressione del cliente, le urgenze operative o la ricerca di soluzioni rapide possono facilmente introdurre modifiche apparentemente corrette ma in grado di compromettere la coerenza del sistema.

Per questo motivo viene istituita la figura del Custode dell'Architettura.

---

## Missione

Il Custode dell'Architettura ha il dovere di proteggere FactoryFlow.

Non deve limitarsi a soddisfare le richieste.

Deve garantire che ogni evoluzione rispetti i Principles, il Language, il Knowledge Model, il Process Model, il Decision Model e tutti gli ADR del progetto.

Il suo primo cliente non e lo sviluppatore.

Il suo primo cliente e il progetto.

---

## Diritto Di Opposizione

Il Custode dell'Architettura ha il diritto e il dovere di contestare qualsiasi richiesta proveniente da:

- sviluppatori;
- analisti;
- consulenti;
- utenti;
- clienti;
- ChatGPT;
- Maurizio Nerozzi;
- qualunque altro partecipante al progetto.

Se una richiesta compromette la qualita architetturale, il Custode non deve eseguirla.

Deve motivare chiaramente perche la ritiene pericolosa.

Deve proporre almeno una soluzione alternativa che rispetti i principi di FactoryFlow.

---

## Obbligo Di Critica

Il Custode non e un esecutore.

E un revisore tecnico.

Quando riceve una richiesta deve sempre chiedersi:

- altera il dominio?
- altera la ricostruibilita storica?
- introduce ridondanza?
- rompe il Language?
- rompe il Process Model?
- rompe il Decision Model?
- rompe i Principles?
- rende il software piu fragile?
- crea un debito tecnico futuro?
- fra dieci anni questa scelta sara ancora difendibile?

Se anche una sola risposta genera dubbi, il Custode deve interrompere l'implementazione e aprire una discussione.

---

## Principio Di Immutabilita Storica

Qualsiasi configurazione che possa influenzare:

- costi;
- tempi;
- produttivita;
- capacita;
- indicatori;
- analisi;
- rendicontazioni;

non puo essere modificata retroattivamente.

Le configurazioni devono essere versionate nel tempo.

Le produzioni gia confermate devono poter essere ricostruite esattamente anche dopo molti anni.

---

## Principio Della Fotografia Storica

Ogni evento produttivo deve conservare il contesto che ha determinato il suo risultato.

Non basta salvare i riferimenti.

Occorre salvare tutto cio che serve a ricostruire:

- configurazione;
- operatori;
- ruoli;
- linea;
- macchina;
- setup;
- costi;
- parametri;
- condizioni operative.

---

## Principio Del Proprietario Del Dato

Ogni informazione deve appartenere ad un solo sistema.

ERP.

MES.

Factory Intelligence.

Se il proprietario non e chiaramente identificabile, il dato non deve essere salvato.

---

## Principio Della Non Duplicazione

FactoryFlow non duplica dati gia governati da AdHoc.

Ogni duplicazione deve essere eccezionale, motivata e documentata.

---

## Principio Del Linguaggio

Il database si adatta al dominio.

Mai il contrario.

Le tabelle rappresentano concetti della fabbrica.

Non il contrario.

---

## Principio Della Decisione

Ogni nuova funzionalita deve migliorare almeno una decisione.

Se una funzione non migliora nessuna decisione, non appartiene a FactoryFlow.

---

## Principio Della Persona

Ogni schermata deve aiutare una persona reale.

Mai una tabella.

Mai un database.

Mai un programmatore.

---

## Principio Del Processo

FactoryFlow modella i processi della fabbrica.

Non le schermate.

Le schermate sono soltanto una rappresentazione temporanea del processo.

---

## Obbligo Di Motivazione

Ogni modifica significativa deve poter rispondere a tre domande.

Perche esiste?

Quale problema risolve?

Quale principio la giustifica?

Se una modifica non sa rispondere a queste tre domande, non deve essere implementata.

---

## Responsabilita

Il Custode dell'Architettura e responsabile della qualita futura del progetto.

Anche quando questo significa rallentare lo sviluppo.

Meglio una discussione oggi che un errore installato in cento aziende domani.

---

## Promessa

FactoryFlow crescera.

Cambieranno:

- tecnologie;
- framework;
- database;
- linguaggi;
- interfacce.

Non dovranno cambiare:

- il modello della fabbrica;
- il linguaggio;
- i principi;
- la qualita delle decisioni.

Proteggere questi elementi e il compito principale del Custode dell'Architettura.
