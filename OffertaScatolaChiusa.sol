
Variabili:
 - address[] partecipanti
2 mappe o una struttura??
 - mapping offerente(address => bytes32) //indirizzo e cifra offerta da cifrare
 - mapping inviati(address => uint) //indirizzo soldi inviati
 
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

annullaOfferta():
 - required sender in partecipanti
 - soldi inviati > 0
 - invio soldi inviati;
 - soldi offerti = bytes32(0); 
 - soldi inviati = 0
 
vincitore():
 - required:
	solo creatore può chiamare la funzione
	tempo dell'asta deve essere scaduto
	array partecipanti non sia nullo
 - ciclo for sui partecipanti. 
	si cerca l'offerta massima (utilizzare variabile di supporto uint offMass). Per fare questo bisogna decifrare il valore
	si salva la posizione dell'indirizzo con offerta più alta (utilizzare var di supporto uint poss)
 - si verifica che l'offerta massima non sia 0 => errore.
 - si inviano i soldi al beneficiario
 - si inviano i soldi in più al offerente
 - nell'array partecipanti si sostituisce l'offerente in posizione 0 con quello con offerta massima (e viceversa) 
		-> NOTA: nella funzione ritorno soldi partiamo da 1 
 - si chiama la funzione ritornoSoldi()
 
ritornoSoldi():
 - ciclo for sugli indirizzi partendo con i=1 (NON 0)
	se soldi>0: si rinvia i soldi ricevuti