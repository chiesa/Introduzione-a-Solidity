# Introduzione a Solidity

## Contesto
Nella seconda metà del mese di febbraio ho iniziato a studiare solidity. In questo ambito ho iniziato a studiare semplici codici, a scrivere qualche piccolo script e a modificare i codici di esempio forniti dalla libreria stessa.
I programmi sono:
1) note.sol
2) atleti.sol
3) votazione.sol (partito da esempi della libreria solidity)
4) asta.sol (partito da esempi della libreria solidity)
5) OffertaScatolaChiusa.sol (partito da esempi della libreria solidity)
6) vendita: singlePuchase e Purchese (partito da esempi della libreria solidity)

## Note.sol
Semplice programma che permette di salvare, modificare e stampare delle note. 
Questo programma ha l'idea di essere una base per una checklist di attività da fare o sviluppi simili.
## Atleti.sol
Permette la registrazione di atleti con il loro punteggio, modificare il punteggio e ritornare la classifica degli atleti.
## Votazione.sol 
### Funzionamento
Viene creato il contratto "Votazione" per gestire un sistema di votazione nel quale:
 - constructor: il creatore, colui che chiama il contratto, crea una lista delle persone candidabili per la votazione;
 - dareDirittoVoto: il creatore può dare il diritto di voto agli indirizzi della rete;
 - deleteDirittoVoto: il creatore può rimuovere il diritto di voto agli indirizza a cui è stato assegnato;
 - delega: gli utenti possono delegare il voto;
 - deleteDelega: cancellare la delaga;
 - voto: permette di votare;
 - deleteVoto: viene eliminato il voto assegnato;
 - changeDelega: permette di cambiare la delega fatta;
 - changeVoto: permette di cambiare il voto fatto; 
 - classificaTop5: permette di sapere i primi 5 classificati;
 - vincitore: il creato può definire il vincitore. Al momento non chiude la votazione ma è uno degli sviluppi più plausibili.
### Test effettuato 
1) andiamo a: 
 - definire 5 candidati (sono stati effettuati test anche con piu e meno di 5 candidati, questi test non sono stati approfonditi):
		["0x1000000000000000000000000000000000000000000000000000000000000000",
		"0x2000000000000000000000000000000000000000000000000000000000000000",
		"0x3000000000000000000000000000000000000000000000000000000000000000",
		"0x4000000000000000000000000000000000000000000000000000000000000000",
		"0x5000000000000000000000000000000000000000000000000000000000000000"]
 - dare diritto di voto a 5 indirizzi (test sempre con numeri minori): <br/>
	0x5B38Da6a701c568545dCfcB03FcB875f56beddC4 (creatore -> errore perchè inizializzato in partenza) <br/>
	0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2 <br/>
	0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db <br/>
	0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB <br/>
	0x617F2E2fD72FD9D5503197092aC168c91465E7f2 <br/>
2) si delega il primo al secondo 
     - il secondo al primo (andrà in errore)
3) si delega il secondo al terzo
4) si vota con il terzo il primo candito
6) con il quarto indirizzo si delega il primo
5) si elimina la delega del primo votante
7) il primo indirizzo vota il secondo candidato
8) si chiede la classifica (primo 2 voti, secondo 2 voti)
9) si chiama il vincitore ci sarà un pareggio (andrà in errore)
10) cambio la delega del secondo dal terzo al primo
11) cambio voto del primo indirizzo voterà il terzo candidato
12) si elimina diritto di voto del secondo 
13) rimuovere diretto di voto al quinto indirizzo e provare a farlo votare (errore)
14) riassegnare diritto di voto al quinto indirizzo e farlo votare il secondo candidato
15) classifica finale dei primi 5 candidati: primo 1 voti, secondo 1 voto e terzo 2 voto
16) chiamare il vincitore che sarà il terzo candidato
Non sono stati effettuati ulteriori test

## Asta.sol
### Funzionamento
Il programma asta si prefigge l'obiettivo di creare una semplice asta. 
Con il seguente algoritmo un indirizzo può creare un asta, gli altri indirizzo possono fare offerte maggiori.
Per far questo creiamo:
 - Costruttore: 
	1) il beneficario
	2) l'offerta minama
	3) il tempo di scadenza di un asta
	4) incremento minimo 
 - funzione offerta(uint amount) return tempo rimante:
	in questa funzione si controlla inanzitutto se il tempo per effettuare offerte è scaduto, in tal caso si andrà in errore (revert nome errore)\*
	si controlla che tu non sia il migliorOffertent
	si controlla se l'offerta (msg.value) non è sufficiente per superare la precedente offerta e in tal caso si manda in errore 
	si rimandano al vecchio offerente i suoi soldi (chiamando funzione withdraw) 
	si cambiano i dati del miglior offerente
	si manda un messaggio con la nuova offerta (chiamato con emit)
 - funzione fineAsta():
 	si richiede che il tempo sia scaduto;
	si chiama evento fine asta in cui si riporta il portafoglio del vincitore e l'amount(chiamato con emit)
	si mandano i soldi al beneficario

\*NOTA BENE: 
l'intenzione iniziale era quella di far chiamare la funzione fineAsta alla prima offerta dopo che il tempo scadeva ma l'esecuzione in concomitanza della funzione fineAsta e dell'errore non è stata possibile.
Togliendo i commenti dalle righe commentate nel codice la prima volta in cui si chiama offerta() dopo il termine tempo verrà chiameta fineAsta() e solo dalla seconda volta la funzione andrà in errore. 
Chiaramente a livello logico, questo problema verrà risolto a livello applicativo: quando scadrà il tempo l'applicazione chiamerà fineAsta()

### Test effettuato
- Si crea un contratto in cui il beneficario è 0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB, l'offerta è 10, la durata è 180 secondi, incremento minimo è 0.1: <br/>
	0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB, 10, 180, 2 <br/>
- Si utilizzeranno i seguenti portafoglio per la fase di test: <br/>
	0x5B38Da6a701c568545dCfcB03FcB875f56beddC4 (creatore - primo indirizzo) <br/>
	0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2 (secondo indirizzo) <br/>
	0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db (terzo indirizzo) <br/>
  
1) con il primo portafoglio si va a fare un'offerta pari a 8 (errore sotto soglia);
2) con il primo portafoglio si va a fare un'offerta pari a 15;
3) con il primo portafoglio si va a fare un'offerta pari a 17 (errore perchè si è già il miglior offerente);
4) con il secondo portafoglio si va ad offrire 110 (errore più dei soldi a disposizione);
5) con il secondo si andrà ad offrire 12, errore perchè minore della miglior offerta;
6) con il secondo si offrirà 16, errore perchè non si incrementa almeno di 2;
7) con il secondo si offrirà 17;
8) con il terzo si offrirà 20;
9) nell'ultimo minuto con il primo si offrirà 30 -> incremeterà il tempo di offerta di 1 minuto 
10) aspettiamo alcuni secondi e secondo si offrirà 35;
11) aspettiamo circa 30 secondi e il terzo offrirà 37;
12) dopo almeno 1 minuto, il primo offrirà 40 -> errore asta finità e i soldi verranno mandati al beneficario.
Non sono stati effettuati ulteriori test

## OffertaScatolaChiusa
### FUNZIONAMENTO:
Variabili:
 - address[] partecipanti
 - mapping offerente(address => offerte)
 - struttura offerte{
		bytes32 cifraOfferta da cifrare
		uint soldiInviati
   }
 - address beneficiario
 - uint offerenteMinima
 - uint scadenzaAsta
 - address creatore

Costruttore:
 - tempo scadenza asta
 - beneficiario
 - offerta minima
 - creatore
 
Offerta(uint cifra): 
 - cifra > offerta minima (required)
 - cifra < soldi inviati (msg.value)
 - now < tempo scadenza asta
 - se sender non è presente trai partecipanti 
		viene aggiunto indizzo ai partecipanti
   altrimenti
		viene chiamata la funzione annullaOfferta
 - salvare il valore dei soldi inviati = msg.value e dei soldi realmente offerti (cifra) DA CIFRARE
NOTA BENE: il sistema di cifratura va rivisto perchè è facilmente recuperabile la massima offerta

annullaOfferta():
 - required sender in partecipanti
 - soldi inviati > 0
 - invio soldi inviati;
 - soldi offerti = bytes32(0); 
 - soldi inviati = 0
 
vincitore() return(addr, amount):
 - required:
	solo creatore può chiamare la funzione
	tempo dell'asta deve essere scaduto
 - si notifica chiusura asta
 - required: array partecipanti non sia nullo
 - ciclo for sui partecipanti. 
	si cerca l'offerta massima (utilizzare variabile di supporto uint offMass). Per fare questo bisogna decifrare il valore
	si salva la posizione dell'indirizzo con offerta più alta (utilizzare var di supporto uint poss)
 - si verifica che l'offerta massima non sia 0 => errore.
 - si inviano i soldi al beneficiario
 - si inviano i soldi in più al offerente
 - nell'array partecipanti si sostituisce l'offerente in posizione 0 con quello con offerta massima (e viceversa) 
		-> NOTA: nella funzione ritorno soldi partiamo da 1 
 - si chiama la funzione ritornoSoldi()
 - return valori 
 
ritornoSoldi():
 - ciclo for sugli indirizzi partendo con i=1 (NON 0)
	se soldi>0: si rinvia i soldi ricevuti

### TEST EFFETTUATI: 
- andiamo a utilizzare 4 indirizzi:
	0x5B38Da6a701c568545dCfcB03FcB875f56beddC4 (creatore -> errore perchè inizializzato in partenza) <br/>
	0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2 <br/>
	0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db <br/>
	0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB <br/>
- Si crea un contratto in cui il beneficario è 0x617F2E2fD72FD9D5503197092aC168c91465E7f2, l'offerta è 10, la durata è 180 secondi: <br/>
	0x617F2E2fD72FD9D5503197092aC168c91465E7f2, 10, 180 <br/>
1) il primo fa un offerta di 10 mandando 20 
2) il secondo prova a offire 8 (errore)
3) il secondo offre 15 e manda 30
4) il secondo elimina l'offerta fatta
5) si chiama vincitore (non sarà finita l'asta -> errore)
6) il terzo prova a offri 20 e mandare 15 (errore)
7) il terzo offre 20 e manda 30
8) il terzo offre 25 e manda 30 (cambia offerta)
9) finisce asta, il quarto prova a fare un offerta (errore)
10) il quarto prova a chiamare il vincitore (errore perchè non proprietario)
Non sono stati effettuati ulteriori test

## Vendita
### FUNZIONAMENTO:
Il seguente sistema garantisce che la vendità di un prodotto avvenga in quanto è nell'interesse sia del venditore che dell'acquirente.
Per far questo l'entrambi mettono 2 volte il prezzo del prodotto e una volta conclusa l'operazione il venditore ricevera 3/2 e l'acquirente 1/2.

Per rendere chiaro lo sviluppo è stato deciso di creare 2 classi:
 - singlePuchase: permetta la gestione di una vendita basato su una macchina a stati diniti
 - Purchese: permette la gestione di molteplici vendite. I prodotti saranno istanza del contratto singlePuchase
 
#### singlePuchase
In dettaglio il funzionamento del contratto singlePuchase:
 - si basa su una macchina a stati in cui sono presenti 4 stati: MessaVendita (iniziale), AccettaCliente, ProdottoInviato, VenditaConclusa (finale)
 - sono previsti un venditore, un acquirente
 - sono presenti 4 funzioni per riportare il valore delle variabile, al momento non utilizzate, sostituibili quando utilizzate e di è da definirne l'utilità
 - il costruttore imposta il nome del prodotto, il prezzo, lo stato iniziale della macchina, il venditore e richiede che il creatore abbia inviato 2 volte l'importo a cui vuole vendere il prodotto 
funzioni:
 - modificaVendita(uint i) permette di modificare il prezzo di vendita
 - acquista(): 
		stato: MessaVendita -> AccettaCliente
		si definisce l'acquirente che invierà 2 volte il prezzo del prodotto
 - annullaAcquisto():
		stato: AccettaCliente -> MessaVendita
		sono il venditore o l'acquirente possono chiamare la funzione
		permette di annullare la richiesta di acquista del acquirente ma lascia il prodotto in vendita
 - accettaAcquirente()
		stato: AccettaCliente -> ProdottoInviato
		con questa funzione il venditore accetta il cliente e garantisce l'invio del prodotto
 - prodottoRicevuto()
		stato: ProdottoInviato -> (cambio in claim) VenditaConclusa
		l'acquirente può dichiarare l'arrivo del prodotto e così facendo chiama la funzione claim
 - claim():
		è di supporto a prodottoRicevuto() e serve a mandare i soldi (3/4 al venditore e 1/4 al acquirente)
 - refound: 
		sono 3 funzioni che permetto di ritornare i soldi inviati all'acquirente, al venditore o a entrambi;
 - riepilogo():
		ritorna lo stato della vendita con tutte le informazioni del caso: 
		nome, importo, venditore, acquirente, stage

TEST:
 - si crea una vendita: venditore XXXXXXXX, importo XX:
 - si modificaVendita:

#### Purchese
In dettaglio il funzionamento del contratto singlePuchase:
 - viene creato un array di singlePuchase;
 - nel construttore si definisce il venditore
	si inizializza il primo valore dell'array di prodotti in vendita a null e questo non verrà mai utilizzato
 - propostaVendita(string memory prod, uint i): 
	permette di inizializzare una nuova vendita 
	incaso la vendita sia già inizializzata permetti di cambiare il prezzo
Da qui tutte le funzioni verificheranno l'esistenza del prodotto nell'array dei prodotti in vendita
 - acquista(string memory prod): 
	permette l'acquisto di un prodotto e in dettaglio chiama la funzione acquista() in singlePuchase
 - annullaAcquisto(string memory prod): 
	permette l'annullamento di un acquisto di un prodotto e in dettaglio chiama la funzione annullaAcquisto() in singlePuchase	
 - annullaVedita(string memory prod):
	può essere chiamata solo dal venditore o dal creatore e permette l'annulla della vendita chimando la funzione refoundAll() in singlePuchase
 - accettaAcquirente(string memory prod):
	permette di accettare un acquirente attraverso la funzione accettaAcquirente() in singlePuchase
 - prodottoRicevuto(string memory prod):
	la funzione chiama prodottoRicevuto() in singlePuchase concludendo la vendita e pertanto andando a notificare e eliminare il prodotto dall'array dei prodotti in vendita
 - eliminaElArray(uint pos):
	permette di eliminare un elemento dell'array dei prodotti in vendita
	funzione a supporto di prodottoRicevuto
 - riepilogo(string memory prod):
	riporta un riepilogo del prodotto in vendita quindi: posizione nell'array dei prodotti, nome, importo, venditore, acquirente, stage
 - returnProdotti():
	ritorna la lista dei prodotti in vendita;

### TEST EFFETTUATI: 
