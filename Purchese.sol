// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

contract Puchase{
    address payable venditore;
    address payable acquirente;

    struct prodotto{
        string nome;
        uint importo;
    }

    enum Stages{
        MessaVendita,
        AccettaCliente,
        ProdottoInviato,
        ProdottoRicevuto,
        VenditaConclusa
    }

    //definiamo il prodotto in vendita (string), l'importo (uint) e il venditore
    constructor (){

    }

    // si definisce il cliente, si prendono i soldi dal cliente
    // solo quando lo stato è MessaVendita si può accedere a questo stato
    // l'acquirente deve mandare 2 volte il prezzo del prodotto
    // si cambia lo stato in AccettaCliente
    function acquista() public{

    }

    // il cliente e il venditore possono annullare l'acquisto, questo comporta:
    // lo stato deve essere AccettaCliente 
    // solo uno tra il cliente e il venditore possono annullare
    // si rimandano i soldi all'acquirente e si annulla la variabile "acquirente"
    // si riporta lo stato a MessaVendita
    function annullaAcquisto() public{

    }

    // nel momento in cui un venditore accetta un acquirente:
    // lo stato deve essere AccettaCliente
    // solo il venditore può chiamare la funzione
    // il venditore deve mandare 2 volte il prezzo del prodotto 
    // lo stato cambierà in ProdottoInviato
    function accettaAcquirente() public{
    
    }

    // nel momento in cui un venditore accetta un acquirente:
    // lo stato deve essere ProdottoInviato
    // solo il cliente può chiamare la funzione 
    // lo stato cambierà in ProdottoRicevuto
    function prodottoRicevuto() public{

    }

    // la funzione può essere chiamata solo se la funzione è in stato Prodotto ricevuto
    // vengono inviati i soldi a tutti (3/4 al venditore e 1/4 al acquirente)
    // lo stato passa in VenditaConclusa
    function claim() public{

    }

    // torna un riepilogo di quanto avventuto
    // funzione chiamabile in qualsiasi stato
    function riepilogo() public view returns(prodotto memory prod,address acquir, address vend, Stages stato){

    }
}