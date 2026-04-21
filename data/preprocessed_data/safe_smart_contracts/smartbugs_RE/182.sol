
















pragma solidity ^0.4.0;

contract Base
{


    string constant VERSION = "Base 0.1.1 \n";



    bool mutex;
    address public owner;



    event Log(string message);
    event ChangedOwner(address indexed oldOwner, address indexed newOwner);



    
    modifier onlyOwner() {
        if (msg.sender != owner) throw;
        _;
    }

    
    
    
    
    
    
    modifier preventReentry() {
        if (mutex) throw;
        else mutex = true;
        _;
        delete mutex;
        return;
    }

    
    
    
    modifier noReentry() {
        if (mutex) throw;
        _;
    }

    
    modifier canEnter() {
        if (mutex) throw;
        _;
    }
    


    function Base() { owner = msg.sender; }

    function version() public constant returns (string) {
        return VERSION;
    }

    function contractBalance() public constant returns(uint) {
        return this.balance;
    }

    
    function changeOwner(address _newOwner)
        public onlyOwner returns (bool)
    {
        owner = _newOwner;
        ChangedOwner(msg.sender, owner);
        return true;
    }
    
    function safeSend(address _recipient, uint _ether)
        internal
        preventReentry()
        returns (bool success_)
    {
        if(!_recipient.call.value(_ether)()) throw;
        success_ = true;
    }
}



















pragma solidity ^0.4.0;
