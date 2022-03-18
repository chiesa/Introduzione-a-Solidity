// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Strings.sol";

contract singlePuchase{
    string nome;
    uint importo;
    Stages stage;
    address payable venditore;
    address payable acquirente;

    enum Stages{
        MessaVendita,
        AccettaCliente,
        ProdottoInviato,
        VenditaConclusa
    }

    error FunctionInvalidAtThisStage();
    modifier atStage(Stages _stage) {
        if (stage != _stage)
            revert FunctionInvalidAtThisStage();
        _;
    }

	// funzioni che premettono di ritornare il valore delle singole variabili
	// allo stato attuale dello script l'utilità è dubbia
    function rStage() private view returns(Stages){return stage;}
    function rImporto() public view returns(uint){return importo;}
    function rSender() public view returns(address payable){return venditore;}
    function rBuyer() private view returns(address payable){return acquirente;}

	// si impostano le variabili base quali: nome del prodotto, importo, lo stato iniziale (MessaVendita), chi è il venditore
    constructor(string memory prod, uint i) payable{
        require(msg.value==i*2000000000000000000, string(abi.encodePacked("importo non valido: ", Strings.toString(msg.value)," e ", Strings.toString(i*2000000000000000000))));
        nome = prod;
        importo = i*1000000000000000000;
        stage = Stages.MessaVendita;
        venditore = payable(tx.origin);
    }
	
	// la funzione permette la modifica del prezzo di vendita di un prodotto
	// l'operazione può essere fatta unicamente dal venditore quando lo stato è ancora "MessaVendita"
	// la funzione non modificherà lo stato
    function modificaVendita(uint i) public payable atStage(Stages.MessaVendita){
        require(tx.origin==venditore, "non puoi eseguire l'operazione");
		require(msg.value==i*2000000000000000000, "non si ha inviato il corretto ammontare di soldi");
        venditore.transfer(importo*2);
        importo = i*1000000000000000000;
    }

    // solo quando lo stato è MessaVendita si può chiamare la seguente funzione
	// si definisce il cliente, si prendono i soldi dal cliente
    // l'acquirente deve mandare 2 volte il prezzo del prodotto
    // si cambia lo stato in AccettaCliente
    function acquista() payable public atStage(Stages.MessaVendita){
        require(msg.value==importo*2, string(abi.encodePacked("importo non valido: ", Strings.toString(msg.value)," e ", Strings.toString(importo*2))));
        acquirente = payable(tx.origin);
        stage = Stages.AccettaCliente;
    }

    // il cliente e il venditore possono annullare l'acquisto, questo comporta:
    // lo stato deve essere AccettaCliente 
    // solo uno tra il cliente e il venditore possono annullare
    // si rimandano i soldi all'acquirente e si annulla la variabile "acquirente"
    // si riporta lo stato a MessaVendita
    function annullaAcquisto() public payable atStage(Stages.AccettaCliente){
        require(tx.origin==rSender() || tx.origin==rBuyer(), "non puoi eseguire l'operazione");
        require(acquirente!=address(0),"non e' stato definito un acquirente");
        acquirente.transfer(importo*2);
        acquirente = payable(address(0));
        stage = Stages.MessaVendita;
    }

    // nel momento in cui un venditore accetta un acquirente:
    // lo stato deve essere AccettaCliente
    // solo il venditore può chiamare la funzione
    // lo stato cambierà in ProdottoInviato
    function accettaAcquirente() public atStage(Stages.AccettaCliente){
        require(tx.origin==venditore, "non puoi eseguire l'operazione");
        stage = Stages.ProdottoInviato;
    }

    // nel momento in cui un acquirente dichiara di aver ricevuto un prodotto:
    // lo stato deve essere ProdottoInviato
    // solo il cliente può chiamare la funzione
	// la funzione chiama claim che: invierà i soldi e cambierà lo stato in ProdottoRicevuto
    function prodottoRicevuto() public atStage(Stages.ProdottoInviato){
        require(tx.origin==acquirente, "non puoi eseguire l'operazione");
        claim();importo = 0;
        nome = "";
		venditore = payable(address(0));
        acquirente = payable(address(0));
    }

    // la funzione può essere chiamata solo se la funzione è in stato ProdottoRicevuto e viene chiamata solo da prodottoRicevuto
    // vengono inviati i soldi a tutti (3/4 al venditore e 1/4 al acquirente)
    // lo stato passa in VenditaConclusa
    function claim() private{
        acquirente.transfer(importo);
        venditore.transfer(importo*3);
        stage = Stages.VenditaConclusa;
    }

	// viene rimborsato l'acquirente e lo stato tornerà a quello inziale
    function refuondAcquirente() public payable{
        if(acquirente != payable(address(0))){
            acquirente.transfer(importo*2);
            acquirente = payable(address(0));
        }
		stage = Stages.VenditaConclusa;
    }

	// viene rimborsato il venditore e questo comportà l'eliminazione della vendita 
    function refoundVenditore() public payable{
        venditore.transfer(importo*2);
        importo = 0;
        nome = "";
		venditore = payable(address(0));
    }

	// vengono rimborsati sia il venditore che l'acquirente e verrà chiusa la vendita
    function refoundAll() public payable{
        refuondAcquirente();
        refoundVenditore();
    }

    // torna un riepilogo di quanto avventuto
    // funzione chiamabile in qualsiasi stato
    function riepilogo() public view returns(string memory,uint,address,address,Stages){
        return (nome, importo/1000000000000000000, venditore, acquirente, stage);
    }
}
