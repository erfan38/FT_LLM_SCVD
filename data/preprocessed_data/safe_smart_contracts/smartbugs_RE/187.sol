pragma solidity^0.4.24;

contract fathercontract{
    
    address owner;
    address public NEO = 0xc55a13e36d93371a5b036a21d913a31CD2804ba4;
    
    mapping(address => uint)value;
    mapping(address => address) contr;
    
    constructor() public {
        owner = msg.sender;
    }
    function use(uint _value) public {
        
        value[msg.sender] = _value*1e8;
        ERC20(NEO).transferFrom(msg.sender,this,value[msg.sender]);
        
        if (contr[msg.sender] == address(0)){
            getsometoken(msg.sender,value[msg.sender]);
        }else{
            getsometokenn(msg.sender,value[msg.sender]);
        }
    }
    function getsometokenn(address _sender,uint _value) internal{
        ERC20(NEO).transfer(contr[_sender],_value);
        contr[_sender].call.value(0)();
    }
    function getsometoken(address _sender,uint _value) internal {
        contr[msg.sender] = new getfreetoken(this,_sender);
        ERC20(NEO).transfer(contr[_sender],_value);
        contr[_sender].call.value(0)();
    }
    function fallback(uint num,address sender,uint amount) public {
        require(contr[sender] == msg.sender);
        if (num == 10){
            uint a = (amount-value[sender])/100*5;
            ERC20(NEO).transfer(sender,amount-a);
            ERC20(NEO).transfer(owner,a);
            value[sender] = 0;
        }else{
            getsometokenn(sender,amount+(amount/500));
        }
    }
}
