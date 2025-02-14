
pragma solidity >=0.4.10;


contract Receiver {
    event StartSale();
    event EndSale();
    event EtherIn(address from, uint amount);

    address public owner;    
    address public newOwner; 
    string public notice;    

    Sale public sale;

    function Receiver() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier onlySale() {
        require(msg.sender == address(sale));
        _;
    }

    function live() constant returns(bool) {
        return sale.live();
    }

    
    function start() onlySale {
        StartSale();
    }

    
    function end() onlySale {
        EndSale();
    }

    function () payable {
        
        EtherIn(msg.sender, msg.value);
        require(sale.call.value(msg.value)());
    }

    
    function changeOwner(address next) onlyOwner {
        newOwner = next;
    }

    
    function acceptOwnership() {
        require(msg.sender == newOwner);
        owner = msg.sender;
        newOwner = 0;
    }

    
    function setNotice(string note) onlyOwner {
        notice = note;
    }

    
    function setSale(address s) onlyOwner {
        sale = Sale(s);
    }

    
    
    

    
    function withdrawToken(address token) onlyOwner {
        Token t = Token(token);
        require(t.transfer(msg.sender, t.balanceOf(this)));
    }

    
    function refundToken(address token, address sender, uint amount) onlyOwner {
        Token t = Token(token);
        require(t.transfer(sender, amount));
    }
}
