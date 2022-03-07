// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

import "./singlePuchase.sol";

contract Puchase{
    singlePuchase[] prodotti;
    mapping(string => uint) mapPosizione;

    event venditaAvvenuta(string);

    address creatore;

    //definiamo del creatore e garante
    constructor(){
        creatore = msg.sender;
        prodotti.push(new singlePuchase(string(""),0));
    }

    function propostaVendita(string memory prod, uint i) public payable{
        if(mapPosizione[prod] == 0){
            require(msg.sender!=creatore);
            prodotti.push(new singlePuchase(prod,i));
        } else {
            prodotti[mapPosizione[prod]].modificaVendita(i);
        }
    }

    modifier verificaEsistenzaInArray(string memory prod){
        require(mapPosizione[prod] == 0, "prodotto non in vendita");
        _;
    }

    // si definisce il cliente, si prendono i soldi dal cliente
    // solo quando lo stato è MessaVendita si può accedere a questo stato
    // l'acquirente deve mandare 2 volte il prezzo del prodotto
    // si cambia lo stato in AccettaCliente
    function acquista(string memory prod) payable verificaEsistenzaInArray(prod) public{
        prodotti[mapPosizione[prod]].acquista();
    }

    // il cliente e il venditore possono annullare l'acquisto, questo comporta:
    // lo stato deve essere AccettaCliente 
    // solo uno tra il cliente e il venditore possono annullare
    // si rimandano i soldi all'acquirente e si annulla la variabile "acquirente"
    // si riporta lo stato a MessaVendita
    function annullaAcquisto(string memory prod) public verificaEsistenzaInArray(prod) payable{
        prodotti[mapPosizione[prod]].annullaAcquisto();
    }

    //chiamera funzioni per il refuond
    function annullaVedita(string memory prod) public payable verificaEsistenzaInArray(prod){
        require(msg.sender==prodotti[mapPosizione[prod]].rSender() || msg.sender == creatore);
        prodotti[mapPosizione[prod]].refoundAll();
    }

    // nel momento in cui un venditore accetta un acquirente:
    // lo stato deve essere AccettaCliente
    // solo il venditore può chiamare la funzione
    // il venditore deve mandare 2 volte il prezzo del prodotto 
    // lo stato cambierà in ProdottoInviato
    function accettaAcquirente(string memory prod) public verificaEsistenzaInArray(prod){
        prodotti[mapPosizione[prod]].accettaAcquirente();
    }

    // nel momento in cui un venditore accetta un acquirente:
    // lo stato deve essere ProdottoInviato
    // solo il cliente può chiamare la funzione 
    // lo stato cambierà in ProdottoRicevuto
    function prodottoRicevuto(string memory prod) public verificaEsistenzaInArray(prod){
        prodotti[mapPosizione[prod]].prodottoRicevuto();
        emit venditaAvvenuta(prod);
        // eliminare prod dall'array
        eliminaElArray(mapPosizione[prod]) ;
    }

    // eliminare elemento dall'array
    function eliminaElArray(uint pos) private{
        require(pos-1<prodotti.length);
        delete prodotti[pos-1];
        for(uint i = pos-1; i<prodotti.length-1;i++){
            prodotti[i]=prodotti[i+1];
        }
        prodotti.pop();
    }

    // torna un riepilogo di quanto avventuto
    // funzione chiamabile in qualsiasi stato
    function riepilogo(string memory prod) public view verificaEsistenzaInArray(prod) returns(uint i,string memory nome,uint importo,address venditore,address acquirente, singlePuchase.Stages stage){
        (nome, importo, venditore, acquirente, stage)=prodotti[mapPosizione[prod]].riepilogo();
        i= mapPosizione[prod];
    }
	
	// ritorniamo la lista di tutti i prodotti in vendita
   	function returnProdotti() public view returns(singlePuchase[] memory){return prodotti;}

}
