contract Reentrance {
    mapping (address => uint) userBalance;
   
    function getBalance(address u) constant returns(uint){
        return userBalance[u];
    }

    function addToBalance() payable{
        userBalance[msg.sender] += msg.value;
    }

    function withdrawBalance_fixed(){

        uint amount = userBalance[msg.sender];
        userBalance[msg.sender] = 0;
        if(!(msg.sender.call.value(amount)())){ throw; }
    }
   
}
