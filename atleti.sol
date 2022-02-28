pragma solidity 0.8.0;

contract Atleti{
    struct atleta{
        string name;
        uint punti;
    }
    atleta[] atleti;
    address owner;

    constructor(){
        owner = msg.sender;
    }

    modifier onlyOwner{
        require(owner==msg.sender, "only the owner can modify");
        _;
    }

    function comp(string memory a, string memory b) internal pure returns(bool){
        return keccak256(bytes(a)) == keccak256(bytes(b));
    }

    function getGiocatore(string memory nome) public view returns(string memory, uint){
        for(uint i=0; i< atleti.length ; i++){
            atleta memory isHim = atleti[i]; 
            if(comp(isHim.name,nome)){
                return (atleti[i].name,atleti[i].punti);
            }
        }
        return ("non trovato",0);
    }

    function setGiocatore(string memory nome, uint256 punteggio) public onlyOwner{
        bool newAtleta = true;
        for(uint i=0; i< atleti.length ; i++){
            atleta memory isHim = atleti[i]; 
            if(comp(isHim.name,nome)){
                isHim.punti = punteggio;
                newAtleta = false;
            }
        }
        if (newAtleta){
            atleta memory nuovo = atleta(nome,punteggio);
            atleti.push(nuovo);
        }
    }

    function setGiocatore(string memory nome) public onlyOwner{
        setGiocatore(nome,0);
    }

    function getFirstPlayer() public view returns(atleta memory){
        atleta memory first = atleti[0];
        for(uint i=0; i<atleti.length; i++){
            if(first.punti<atleti[i].punti){
                first = atleti[i];
            }
        }
        return first;
    }

    function getClassifica() public view returns(atleta[] memory){
        atleta[] memory atletiClassifica = atleti;

        for(uint i=0; i < atleti.length; i++){
            for(uint j=i+1; j < atletiClassifica.length; j++){
                uint256 p1 = atletiClassifica[i].punti;
                uint256 p2 = atletiClassifica[j].punti;
                if( p1 < p2 ){
                    atleta memory temp = atletiClassifica[i];
                    atletiClassifica[i]=atletiClassifica[j];
                    atletiClassifica[j]=temp;
                }
            }
        }
        return atletiClassifica;
    }
}
