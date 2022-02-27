// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

/*
TEST EFFETTUATI: 
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
*/

/*
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
NOTARE INOLTRE: 
 c'è un bag: 
	- in caso un utente ha delegato una persona, che ha sua volta a delegato qualcuno e a quest'ultimo viene tolto il diritto di voto
	 verrà persa la delega fatta dalla prima persona
	- in caso un utente ha delegato una persona, che ha sua volta a delegato qualcuno e l'utente "di mezzo" cambia la sua delega
	 il primo utente delegherà l'ultimo e viene persa la relazione di mezzo
*/ 
contract Votazione{
	/* la struttura Str_votante è una struttura che contiene i dati relativi ad ogni elettore:
	 - votato: se ha votato; 
	 - capacita: quanti voti ha a disposizione l'elettore (1 + numero di persone che lo hanno delegato);
	 - delegato: soggetto delegato dall'elettore;
	 - nomeVotato: chi ha votato;
	 - Deleganti: lista delle persone che hanno delegato lui al voto */
    struct Str_votante{
        bool votato;
        uint capacita;
        address delegato;
        bytes32 nomeVotato;
        Deleganti[] deleganti;
    }
	// Deleganti: sono colore che lo hanno delegato con relativo indirizzo e capacita
    struct Deleganti{
        address mittente;
        uint capacita;
    }
	//votante è un correlazione tra l'indirizzo e la struttura Str_votante
    mapping(address=>Str_votante) public votante;
    address creatore;
	
	/*
	Candidato è il nome e il numero di voti che ha ricevuto. 
	Per la gestione dei candidati facciamo un array e una mappatura tra il nome e l'indice nell'array
    */
	struct Candidato{
        bytes32 nome;
        uint nVoti;
    }
    mapping(bytes32=>uint) public indexCand;
    Candidato[] candidati;

	/* il costruttore provvede a:
	 - definire il creatore
	 - dare la possibilità di voto al creatore 
	 - ad inizializzare i candidati
	*/
    constructor (bytes32[] memory nomi){
        creatore = msg.sender;
        votante[creatore].capacita = 1;

        for(uint i=0; i<nomi.length; i++){
            candidati.push(Candidato(nomi[i],0));
            indexCand[nomi[i]] = i;
        }
    }
	
	// vengono definiti qui un elenco di requisti che verranno richiamati dalle funzioni 
	// per garantire il corretto funzionamento del programma
    modifier creatoreOnly() {
        require(creatore == msg.sender, "non hai i permessi per chiamare la funzione");
        _;
    }
    modifier condVoto() {
        require(!votante[msg.sender].votato, "hai gia' votato");
        require(votante[msg.sender].capacita!=0, "non hai diritto di voto");
        _;
    }

    // la funzione permette di dare diritto di voto agli indirizza (incrementa capacita per l'indirizzo)
	function dareDirittoVoto(address addVoto) public creatoreOnly{
        require(!votante[addVoto].votato, "hai gia' votato");
        require(votante[addVoto].capacita==0, "hai gia' diritto di voto");

        votante[addVoto].capacita += 1;

    }

	// passando un indirizzo si riporta l'indice nell'arrey Candidati della persona votata
    function indexR(address del) private view returns (uint i){
        require(votante[del].votato, "non si ha ancora votato");
		while(votante[del].delegato != address(0)){
			del = votante[del].delegato;
		}
		i = indexCand[votante[del].nomeVotato];
    }

    //il creatore può eliminare i diritti di voto
    function deleteDirittoVoto(address remVoto) public creatoreOnly{
        Str_votante memory rVotante = votante[remVoto];
        // si controlla se la persona a cui si sta togliendo il diritto di voto ha già votato 
        if(rVotante.votato){
            // se ha votato si controlla se ha delegato qualcuno, si sale alla radice della delegazione
			// si modifica la capacita delle persona delegata
			// se la persona delegata ha gia votato e in caso di toglie il voto al candidato
            if(rVotante.delegato != address(0)){
                address del = rVotante.delegato;
                rVotante.delegato = address(0);
                while(votante[del].delegato != address(0)){
                    del = votante[del].delegato;
                }
                if(votante[del].votato){
                    uint index = indexR(del);
                    candidati[index].nVoti -= votante[remVoto].capacita;
                }
                votante[del].capacita = 0;
            }else{
                uint index = indexR(remVoto);
                candidati[index].nVoti -= votante[remVoto].capacita;
            }
        }
        // si aggiorna la tabella delle persone che hanno delegato la persona a cui viene tolto il voto
		// le persone che inprecedenza la avevano votato, tornano in diritto di votare
        for(uint i = 0; i<rVotante.deleganti.length; i++){
            address ripVoti = (rVotante.deleganti)[i].mittente;
            uint nVoti = (rVotante.deleganti)[i].capacita;
            votante[ripVoti].capacita = nVoti;
            votante[ripVoti].votato = false;
        }
		// si annulla possibilità di votare e il fatto che si il soggetto abbia votato
        votante[remVoto].capacita = 0;
        votante[remVoto].votato = false;
    }

	
   	// la funzione da la possibilità di delegare altri indirizzi
    function delega(address to) public condVoto{
        require(msg.sender!=to, "non e' possibile autodelegarsi");
        require(votante[to].capacita!=0, "delegato non ha diritto di voto");
        Str_votante memory rVotante = votante[msg.sender];
   		// si aggiunge alla persona che sta chiamando la funzione chi sta delegando
        votante[msg.sender].delegato = to;
   		// si aggiorna la lista delle persone che stanno delegando il delegato (aggiungendo la persona che sta chiamando la funzione)
        (votante[to].deleganti).push(Deleganti(msg.sender,rVotante.capacita));
        // si aggiorna a true il fatto di aver votato
        votante[msg.sender].votato = true;
        // si verifica se l'indirizzo che si sta delegando ha, a sua volta, delegato qualcun altro e si punta questo indirizzo
        // andando a modificare la capacita di voto del delegato
        votante[to].capacita += rVotante.capacita;
        while(votante[to].delegato != address(0)){
            to = votante[to].delegato;
            votante[to].capacita += rVotante.capacita;
            require(to != msg.sender, "Loop: non e' possibile autodelegarsi");
        }
		// se la persona delegata ha già votato allora si aumenta i voti ricevuti dalla candidato votato dal delegato
        if(votante[to].votato){
            uint index = indexR(to);
            candidati[index].nVoti += rVotante.capacita;
        }
    }

	/* 
	è possibile eliminare la delega effettuata. 
	 Per fa ciò dopo aver verificato il fatto di aver delegato qualcuno,
	 viene tolto (se assegnato) il voto assegnato al candidato perdestinato.
	 viene diminuita la capacita di voto della persona delegata,
	 viene eliminato dall'array delle persone che hanno delegato il vecchio soggetto a cui era stata data la delega,
	 si annulla il fatto di aver votato (vorato = false) e si cambia il riferimento della persona delegata a NULL (address(0))
    */
    function deleteDelega() public{
        Str_votante memory rVotante = votante[msg.sender];
        address exDel = rVotante.delegato;
        require(exDel != address(0), "non si ha delegato nessuno");
        
        uint capacitaRemVot = rVotante.capacita;

        //delete element array 
        Deleganti[] storage elencoDeleganti = votante[exDel].deleganti;
        uint index1 = 0;
        while(elencoDeleganti[index1].mittente != msg.sender){
            index1 += 1;
        }
        for (uint i = index1; i<elencoDeleganti.length-1; i++){
            elencoDeleganti[i] = elencoDeleganti[i+1];
        }
        delete elencoDeleganti[elencoDeleganti.length-1];
        votante[exDel].deleganti = elencoDeleganti;

		// aggiorno lo stato di chi sta eliminando la delega
        votante[msg.sender].votato = false;
        votante[msg.sender].delegato = address(0);
        votante[exDel].capacita -= capacitaRemVot;
		// diminuisco la capacita delle persone delegate a cascata
        while(votante[exDel].delegato != address(0)){
            exDel = votante[exDel].delegato;
            votante[exDel].capacita -= capacitaRemVot;
        }
        
        if(votante[exDel].votato){
            uint index = indexR(exDel);
            candidati[index].nVoti -= capacitaRemVot;
        }
    }


	// La funzione permette di votare -> implementa il numeri dei voti ricevuti dal candidato prescelto 
	// della capacità di voto dell'elttore  
    function voto(bytes32 to) public condVoto{
        votante[msg.sender].nomeVotato = to;
        votante[msg.sender].votato = true;
        candidati[indexCand[to]].nVoti += votante[msg.sender].capacita;
    }

	// la funzione permette di eliminare il voto, dopo aver fatto le valutazioni di sorta, 
	// setta a FALSE il fatto di aver votato
	// si decrementano i voti ricevuti dal candidato 
    function deleteVoto() public{
        require(votante[msg.sender].votato, "non si ha ancora voto");
        require(votante[msg.sender].nomeVotato.length > 0, "il voto precedendemente dato e' NULL");
        require(votante[msg.sender].delegato == address(0), "impossibile togliere voto, provare a togliere delega");
        candidati[indexR(msg.sender)].nVoti -= votante[msg.sender].capacita;
        votante[msg.sender].votato = false;
        votante[msg.sender].nomeVotato = "";
    }

	// le seguenti funzioni permetto di cambiare il voto e la delega assegnati precedentementi
    function changeVoto(bytes32 newVoto) public{
        deleteVoto();
        voto(newVoto);
    }
    function changeDelega(address newDelega) public{
        deleteDelega();
        delega(newDelega);
    }

	// la seguente funzione permette di recuperare la classifica delle prime 5 persone per voto
    function classificaTop5() public view returns(Candidato[5] memory _classifica){
		// con due cicli for si definisce la posizione in classifica di ogni candidato
        for(uint i=0; i<candidati.length; i++){
            uint poss = 0;
            for(uint j=0; j<candidati.length; j++){
                if(candidati[i].nVoti<candidati[j].nVoti){
                    poss+=1;
                }
            }
			// il ciclo while va a risolvere il problema di diversi candidati con il medesimo punteggio
            while(_classifica[poss].nome != ""){
                poss+=1;
				// se non si è nelle prime 5 posizioni l'array andrebbe in overflow quindi si esce dal ciclo 
                if(poss>=5){
                    break;
                }
            }
			// se posizione è minore di 5 allora si inserisce il candidato nella posizione di riferimento in classifica
            if(poss<5){
                _classifica[poss] = candidati[i];         
            }
        }
    }

	// si recupera i primi 5 classificati, si recupera il primo e lo si fa tornare
	// in caso di pareggio la funzione andrà in errore
    function vincitore() public view creatoreOnly returns (Candidato memory _classifica){
        Candidato[5] memory supClass = classificaTop5();
        require(supClass[0].nVoti != supClass[1].nVoti, "Pareggio");
        return supClass[0];
    }
}
