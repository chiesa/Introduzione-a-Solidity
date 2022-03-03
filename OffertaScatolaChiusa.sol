/*
FUNZIONAMENTO:
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
*/

/*
TEST EFFETTUATI: 
andiamo a utilizzare 4 indirizzi:
	0x5B38Da6a701c568545dCfcB03FcB875f56beddC4 (creatore -> errore perchè inizializzato in partenza)
	0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
	0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db
	0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB
 Si crea un contratto in cui il beneficario è 0x617F2E2fD72FD9D5503197092aC168c91465E7f2, l'offerta è 10, la durata è 180 secondi, incremento minimo è 0.1;
	0x617F2E2fD72FD9D5503197092aC168c91465E7f2, 10, 180
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
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity  ^0.8.4;

contract offertaScatolaChiusa{
    /* variabili */
    address[] partecipanti;
    struct offerte{
        bytes32 cifraOfferta; //valore da cifrare
        uint soldiInviati;
        bool addressExists; // per controllare l'esistenza dell'indirizzo nell'array partecipanti
    }
    mapping (address => offerte) offerente;
    address payable beneficiario;
    uint offerenteMinima;
    uint scadenzaAsta;
    address creatore;

    modifier soloCreatore{
        require(msg.sender == creatore, "Non sei il creatore");
        _;
    }

    event nuovaOfferta(address);
    event eliminaOfferta(address);
    event fineAsta();
    event vincitoreEv(address, uint);

    error offertaNonValida(string);
    /* Costruttore
        definizione:
         - tempo scadenza asta
         - beneficiario
         - offerta minima
         - creatore
    */
    constructor(address ben, uint offMin, uint temp){
        beneficiario = payable(ben);
        offerenteMinima = offMin;
        scadenzaAsta = block.timestamp + temp;
        creatore = msg.sender;
    }

    /* FUNZIONI */

    // Offerta(uint cifra): 
    function offerta(uint cifra) payable public{
        // cifra > offerta minima
        cifra = cifra*1000000000000000000;
        if(cifra<offerenteMinima){
            revert offertaNonValida("l'offerta non supera la soglia minima");
        }
        //cifra < soldi inviati (msg.value)
        if(cifra > msg.value){
            revert offertaNonValida("i soldi inviati non sono sufficienti a comprire l'offerta proposta");
        }
        // now < tempo scadenza asta
        require(block.timestamp < scadenzaAsta, "il tempo per fare offerte in quest'asta e' finito");
        // se sender è presente trai partecipanti allora viene chiamata la funzione annullaOfferta
        // altrimenti viene aggiunto indizzo ai partecipanti
        address mittente = msg.sender;
        if(offerente[mittente].addressExists){
            annullaOfferta();
        } else {
            partecipanti.push(mittente);
            offerente[mittente].addressExists = true;
        }
        // salvare il valore dei soldi inviati = msg.value e dei soldi realmente offerti (cifra) DA CIFRARE
        offerente[mittente].cifraOfferta = bytes32(cifra);
        offerente[mittente].soldiInviati = msg.value;
        emit nuovaOfferta(mittente);
    }

    // annullaOfferta()
    function annullaOfferta() public{
        address payable mittente = payable(msg.sender);
        //sender in partecipanti
        require(offerente[mittente].addressExists, "impossibile annullare l'offerta in quanto non e' mai stata fatta un'offerta"); 
        // soldi inviati > 0
        if(offerente[mittente].soldiInviati > 0){
            // invio soldi inviati;
            mittente.transfer(offerente[mittente].soldiInviati);
        }
        // soldi offerti = bytes32(0); 
        offerente[mittente].cifraOfferta = bytes32(0);
        // soldi inviati = 0
        offerente[mittente].soldiInviati = 0;
        emit eliminaOfferta(mittente);
    }

    // vincitore() return(addr, amount) soloCreatore:
    function vincitore() public soloCreatore returns(address vinc, uint amount){
        // required:
        //    solo creatore può chiamare la funzione (Fatto con dolo creatore nell'intestazione)
        //    tempo dell'asta deve essere scaduto
        require(block.timestamp > scadenzaAsta, "l'asta e' ancora attiva, non e' possibile definire il vincitore");

        // si notifica chiusura asta
        emit fineAsta();

        // required: array partecipanti non sia nullo
        require(partecipanti.length != 0, "nessuno a partecipato all'asta");

        // ciclo for sui partecipanti. 
        //    si cerca l'offerta massima (utilizzare variabile di supporto uint offMass). Per fare questo bisogna decifrare il valore
        //    si salva la posizione dell'indirizzo con offerta più alta (utilizzare var di supporto uint poss)
        amount = 0;
        uint poss = 0;
        for(uint i=0; i<partecipanti.length; i++){
            if(amount < uint256(offerente[partecipanti[i]].cifraOfferta)){
                amount = uint256(offerente[partecipanti[i]].cifraOfferta);
                poss = i;
            }
        }
        vinc = partecipanti[poss];

        // si verifica che l'offerta massima non sia 0 => errore.
        require(amount>0,"offerta massima non valida");

        // si inviano i soldi al beneficiario
        beneficiario.transfer(amount);
        
        // si inviano i soldi in più al offerente
        payable(partecipanti[poss]).transfer(offerente[vinc].soldiInviati - amount);

        // nell'array partecipanti si sostituisce l'offerente in posizione 0 con quello con offerta massima (e viceversa) 
        //        -> NOTA: nella funzione ritorno soldi partiamo da 1 
        address supporto = partecipanti[0];
        partecipanti[0] = partecipanti[poss];
        partecipanti[poss] = supporto;
        
        // si chiama la funzione ritornoSoldi()
        ritornoSoldi();

        // si notifica il vincitore
        emit vincitoreEv(vinc,amount);
    }


    // ritornoSoldi():
    function ritornoSoldi() private{
        // ciclo for sugli indirizzi partendo con i=1 (NON 0)
        //    se soldi>0: si rinvia i soldi ricevuti
        for(uint i=1; i<partecipanti.length; i++){
            if(offerente[partecipanti[i]].soldiInviati>0){
                payable(partecipanti[i]).transfer(offerente[partecipanti[i]].soldiInviati);
            }
        }
    }
}