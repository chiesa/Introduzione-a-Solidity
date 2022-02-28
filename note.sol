pragma solidity 0.5.12;

contract Note{
    
    struct elenco{
        uint id;
        bytes32 note;
        uint timestamp;
        bool complete;
    }
    uint256 public constant maxAmountOfNotes = 100;
    mapping(address => elenco[maxAmountOfNotes]) public _note;
    mapping(address => uint256) public lastIds; 

    modifier onlyOwner(address _owner) {
        require(msg.sender == _owner);
        _;
    }

    function addNote(bytes32 nota) public {
        if(lastIds[msg.sender] <= maxAmountOfNotes){
            elenco memory notaNew = elenco(lastIds[msg.sender], nota, now, false);
            _note[msg.sender][lastIds[msg.sender]] = notaNew;
            lastIds[msg.sender]++;
        } 
    }

    function getNote(uint num) external view returns(bytes32){
        elenco memory notaView = _note[msg.sender][num];
        return (notaView.note); 
    }

    function noteModify(uint num, bytes32 nota) public{
        if(num < lastIds[msg.sender]){
            _note[msg.sender][num].note = nota;
        }
    }
    
    function main()public{
        addNote("pippo");
        getNote(1);
        noteModify(1,"nuovo");
        getNote(1);
    }

}
