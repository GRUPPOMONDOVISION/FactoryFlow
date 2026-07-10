# FactoryFlow - Calendario Dichiarazioni E Agenda Produzione

## Decisione Di Dominio

FactoryFlow non usa un solo calendario per tutti i casi.

Da questo punto il prodotto espone due esperienze distinte:

- Calendario Dichiarazioni;
- Agenda Produzione.

La distinzione e' intenzionale. Le aziende non hanno tutte lo stesso livello di maturita produttiva e FactoryFlow deve accompagnarle senza forzarle.

## Livello 1 - Calendario Dichiarazioni

Il Calendario Dichiarazioni mantiene il comportamento dell'MVP.

Serve alle aziende che vogliono registrare correttamente cio' che e' stato prodotto, senza configurare processi produttivi strutturati.

Il flusso resta diretto:

1. scelta articolo prodotto;
2. quantita prodotta;
3. lotto prodotto;
4. macchina o risorsa usata;
5. team/operatori;
6. orari di produzione e tempi operatori;
7. componenti e lotti letti da distinta AdHoc;
8. conferma;
9. generazione documenti AdHoc.

Questa esperienza non richiede un processo configurato.

Concettualmente puo' essere interpretata come un processo tecnico minimale, composto da una sola fase con effetto ERP, ma questa complessita non deve essere mostrata all'utente operativo.

## Livello 2 - Agenda Produzione

L'Agenda Produzione e' la gestione process-centric.

Serve alle aziende che vogliono governare:

- processo produttivo;
- versione processo;
- articolo o prodotto da ottenere;
- fasi previste;
- attivita pianificate;
- chiusure fase;
- scostamenti;
- performance;
- costi industriali.

Il flusso dell'Agenda e' diverso dal calendario dichiarazioni:

1. si inserisce il prodotto/articolo da ottenere;
2. si indica quantita prevista e data prevista;
3. FactoryFlow propone, quando configurato, il processo applicabile;
4. l'utente conferma o cambia processo;
5. l'Agenda mostra le fasi previste;
6. ogni fase viene chiusa singolarmente;
7. solo le fasi che lo prevedono generano effetto ERP;
8. le chiusure alimentano consuntivo, costi, tempi e scostamenti.

## Relazione Articolo E Processo

Il processo produttivo non appartiene all'articolo.

La relazione corretta e':

```text
Articolo AdHoc
puo' usare
Processo Produttivo
```

Per questo motivo il modello deve prevedere una relazione di applicabilita, non un campo proprietario dentro il processo.

Tabella prevista in evoluzione additiva:

- `FF_PROCESSI_ARTICOLI`;
- `IdProcesso`;
- `CodArticoloAdHoc`;
- `DefaultProcesso`;
- `ValidoDal`;
- `ValidoAl`;
- `Note`.

Regole:

- nessuna foreign key verso AdHoc;
- `CodArticoloAdHoc` e' un riferimento esterno;
- un articolo puo' avere piu processi applicabili;
- un processo puo' essere applicabile a piu articoli;
- puo' esistere un solo processo default valido per articolo nello stesso periodo;
- la validita temporale e' obbligatoria;
- non usare un semplice flag attivo/disattivo per relazioni che incidono su scelte operative e costi.

## Regole Di Modifica Attivita Agenda

Prima della chiusura di una fase, l'attivita puo' essere corretta:

- articolo;
- processo;
- versione;
- quantita prevista;
- linea prevista;
- note.

Dopo la chiusura di almeno una fase, le modifiche distruttive non devono essere consentite.

In quel caso FactoryFlow deve proporre:

- annullamento controllato dell'attivita;
- creazione di una nuova attivita;
- oppure rettifica con audit, quando sara' prevista.

## Chiusura Fase

La chiusura fase richiede dati in base ai requisiti della fase:

- macchina usata;
- team/operatori;
- orari fase;
- tempi operatori;
- setup;
- articolo prodotto, se richiesto;
- quantita prodotta;
- lotto prodotto;
- componenti e lotti consumati;
- qualita;
- note;
- effetto ERP se previsto.

Una fase puo' non generare ERP.

Una fase puo' generare ERP chiamando la stored ufficiale AdHoc gia validata.

## Compatibilita MVP

Il Calendario Dichiarazioni non viene cancellato e non viene trasformato in Agenda.

Rimane la porta semplice per le aziende che vogliono solo dichiarare produzione.

L'Agenda Produzione e' una seconda porta, piu matura, dedicata al governo del processo produttivo.

## Regola Da Proteggere

Non fondere le due esperienze.

- Calendario Dichiarazioni = registrazione diretta.
- Agenda Produzione = governo del processo.

Condividono articoli, distinta, lotti, operatori, macchine, costi, audit e stored AdHoc dove serve.

Ma non hanno lo stesso significato.
