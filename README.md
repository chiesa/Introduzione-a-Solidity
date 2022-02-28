# Introduzione a Solidity

## Contesto
Nella seconda metà del mese di febbraio ho iniziato a studiare solidity. In questo ambito ho iniziato a studiare semplici codici, a scrivere qualche piccolo script e a modificare i codici di esempio forniti dalla libreria stessa.
I programmi sono:
1) note.sol
2) atleti.sol
3) votazione.sol (partito da esempi della libreria solidity)
4) asta.sol (partito da esempi della libreria solidity)

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
 - dare diritto di voto a 5 indirizzi (test sempre con numeri minori):
	0x5B38Da6a701c568545dCfcB03FcB875f56beddC4 (creatore -> errore perchè inizializzato in partenza)
	0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
	0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db
	0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB
	0x617F2E2fD72FD9D5503197092aC168c91465E7f2
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

## Asta
### Funzionamento
Il programma asta si prefigge l'obiettivo di creare una semplice asta. 
Con il seguente algoritmo un indirizzo può creare un asta, gli altri indirizzo possono fare offerte maggiori.
Per far questo creiamo:
 - Costruttore: 
	si definiscono il beneficario
	il tempo di scadenza di un asta 
 - funzione offerta(uint amount):
	in questa funzione si controlla inanzitutto se il tempo per effettuare offerte è scaduto, in tal caso si chiama fineAsta(revert nome error);
	si controlla che l'offerta (msg.value) sia inferiore alla precedente offerta e in tal caso si manda in errore 
	si rimandano al vecchio offerente i suoi soldi (chiamando funzione withdraw) 
	si cambiano i dati del miglior offerente
	si manda un messaggio con la nuova offerta
 - funzione fineAsta():
	si chiama evento fine asta in cui si riporta il portafoglio del vincitore e l'amount(chiamato con emit)
	si mandano i soldi al beneficario
