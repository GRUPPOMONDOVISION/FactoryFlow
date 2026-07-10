# ADR-0005 - Validita Temporale Dei Dati Che Determinano Costi

## Contesto

FactoryFlow calcola costi produttivi usando informazioni operative che possono cambiare nel tempo: composizione dei team, costo orario applicato, regole di setup, costi di linea, costi macchina e parametri articolo-linea.

Queste informazioni non possono essere trattate come semplici dati correnti, perche una modifica fatta oggi non deve cambiare la lettura economica di una produzione confermata ieri.

## Problema

Se una riga di configurazione viene solo modificata o disattivata con un flag, il sistema rischia di perdere il contesto storico che ha generato un costo.

Esempio: un operatore era presente in un team con un costo orario applicato in una certa data. Se domani il costo o la composizione del team cambiano, la produzione gia rendicontata deve continuare a mostrare il costo calcolato con le condizioni valide nel giorno della produzione.

## Decisione

Tutte le informazioni che concorrono al calcolo dei costi devono seguire una di queste due regole:

- validita temporale, con data di inizio e data di fine validita;
- fotografia del valore calcolato al momento della conferma produzione.

Le righe di dettaglio che determinano costi non vengono duplicate quando vengono chiuse. Viene chiusa la loro validita.

Per i team operativi, lo stesso operatore non puo essere presente piu volte nello stesso team con validita aperta.

## Motivazione

FactoryFlow deve produrre rendicontazioni stabili. Il costo storico di una produzione non deve cambiare per effetto di una manutenzione successiva delle configurazioni.

## Alternative Valutate

- Flag Attivo/Disattivo: scartato per i dettagli che determinano costi, perche non conserva correttamente il periodo di validita.
- Cancellazione fisica: scartata, perche cancellerebbe il contesto storico.
- Duplicazione della riga disattivata: scartata, perche introduce ambiguita e duplicati operativi.

## Conseguenze Positive

- Le produzioni gia confermate restano rendicontabili in modo coerente.
- Le modifiche future non alterano i costi storici.
- Il modello resta leggibile: una riga aperta rappresenta la configurazione corrente, una riga chiusa rappresenta una configurazione storica.

## Conseguenze Negative

- Le CRUD diventano leggermente piu complesse.
- Le query devono considerare la data di produzione per scegliere la configurazione corretta.
- Le UI devono parlare di chiusura validita, non di semplice disattivazione.

## Livello Di Stabilita

★★★★★
