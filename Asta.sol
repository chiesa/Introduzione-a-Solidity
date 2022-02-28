// SPDX-License-Identifier: GPL-3.0
pragma solidity  ^0.8.4;

/*
Il seguente programma di prefigge lobiettivo di creare un sistema di aste. 
Con il seguente algoritmo un indirizzo può creare un asta, gli altri indirizzo possono fare offerte maggiori.

Per far questo creiamo: 
 - Costruttore: 
		si definiscono 
        1) il beneficario
        2) l'offerta minama
		3) il tempo di scadenza di un asta
        4) incremento minimo
 - funzione offerta(uint amount) return tempo rimante:
		in questa funzione si controlla inanzitutto se il tempo per effettuare offerte è scaduto, in tal caso si andrà in errore (revert nome error)*
		se il tempo di fine offerta è minore di 1 min (incrementoTemp) allora l'asta durerà 1 min in più
        si controlla che tu non sia il migliorOffertent
        si controlla se l'offerta (msg.value) non è sufficiente per superare la precedente offerta e in tal caso si manda in errore 
		si rimandano al vecchio offerente i suoi soldi (chiamando funzione withdraw) 
		si cambiano i dati del miglior offerente
		si chiama evento con la nuova offerta (chiamato con emit)
        si ritorna il tempo rimanente
 - funzione fineAsta():
        si richiede che il tempo sia scaduto;
		si chiama evento fine asta in cui si riporta il portafoglio del vincitore e l'amount(chiamato con emit)
		si mandano i soldi al beneficario

*NOTA BENE: 
 l'intenzione iniziale era quella di far chiamare la funzione fineAsta alla prima offerta dopo che il tempo scadeva ma l'esecuzione in concomitanza della funzione fineAsta e dell'errore non è stata possibile.
 Togliendo i commenti dalle righe commentate nel codice la prima volta in cui si chiama offerta() dopo il termine tempo verrà chiameta fineAsta() e solo dalla seconda volta la funzione andrà in errore. 
 Chiaramente a livello logico, questo problema verrà risolto a livello applicativo: quando scadrà il tempo l'applicazione chiamerà fineAsta()
*/

/*
TEST: 
 Si crea un contratto in cui il beneficario è 0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB, l'offerta è 10, la durata è 180 secondi, incremento minimo è 0.1;
	0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB, 10, 180, 2
 Si utilizzeranno i seguenti portafoglio per la fase di test: 
  0x5B38Da6a701c568545dCfcB03FcB875f56beddC4 (creatore - primo indirizzo)
  0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2 (secondo indirizzo)
  0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db (terzo indirizzo)
 1) con il primo portafoglio si va a fare un'offerta pari a 8 (errore sotto soglia);
 1) con il primo portafoglio si va a fare un'offerta pari a 15;
 2) con il primo portafoglio si va a fare un'offerta pari a 17 (errore perchè si è già il miglior offerente);
 3) con il secondo portafoglio si va ad offrire 110 (errore più dei soldi a disposizione);
 4) con il secondo si andrà ad offrire 12, errore perchè minore della miglior offerta;
 5) con il secondo si offrirà 16, errore perchè non si incrementa almeno di 2;
 5) con il secondo si offrirà 17;
 6) con il terzo si offrirà 20;
 7) nell'ultimo minuto con il primo si offrirà 30 -> incremeterà il tempo di offerta di 1 minuto 
 8) aspettiamo alcuni secondi e secondo si offrirà 35;
 9) aspettiamo circa 30 secondi e il terzo offrirà 37;
 10) dopo almeno 1 minuto, il primo offrirà 40 -> errore asta finità e i soldi verranno mandati al beneficario.
*/

contract Asta{
    
    address payable beneficario;
    address payable migliorOff;
    uint maxOffert;
    uint tempFineAsta;
    uint minIncrement;
//    bool finish;

    uint incrementoTemp = 1 minutes;

    event nuovaMaxOffert(address, uint);
    event fineAsta(address, uint);

    error tempOfferteScaduto();
    error offertaNonSufficiente(uint maxOffert);
    error alreadyBestOffert();

    constructor(address ben, uint minOffert, uint durata, uint min){
        beneficario = payable(ben);
        maxOffert = minOffert*1000000000000000000;
        tempFineAsta = block.timestamp + durata;
        minIncrement = min*1000000000000000000;
    }

    function offerta() public payable returns (uint){
        if(tempFineAsta<block.timestamp){
//            if(finish){
                revert tempOfferteScaduto();
//            } else{
//                concludiAsta();
//                finish = false;
//            }
//        } else {
        } // in caso si voglia decommentare il codice è necessario togliere questa parentesi
        if(msg.sender==migliorOff){
            revert alreadyBestOffert();
        }
        if((maxOffert+minIncrement) > msg.value || (maxOffert>msg.value && migliorOff==address(0))){
            revert offertaNonSufficiente((maxOffert+minIncrement)/1000000000000000000);
        }
        if(maxOffert != 0 && migliorOff!= address(0)){
            migliorOff.transfer(maxOffert);
        }
        migliorOff = payable(msg.sender);
        maxOffert = msg.value;
        emit nuovaMaxOffert(msg.sender,msg.value);
        if (tempFineAsta - block.timestamp < incrementoTemp){
            tempFineAsta = block.timestamp + incrementoTemp;
        } 
//        }
        return (time());
    }

    function concludiAsta() public{
        require(block.timestamp>= tempFineAsta, "non e' ancora scaduta l'asta");
        if(maxOffert != 0){
            beneficario.transfer(maxOffert);
        }
        emit fineAsta(migliorOff, maxOffert);
    }

    function time() view public returns (uint){return tempFineAsta-block.timestamp;}
}
