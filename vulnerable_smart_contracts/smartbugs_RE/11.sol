pragma solidity ^0.4.25;






contract Blocker {
    bool private stop = true;
    address private owner = msg.sender;
    
    function () public payable {
        if(msg.value > 0) {
            require(!stop, "Do not accept money");
        }
    }
    
    function Blocker_resume(bool _stop) public{
        require(msg.sender == owner);
        stop = _stop;
    }
    
    function Blocker_send(address to) public payable {
        address buggycontract = to;
        require(buggycontract.call.value(msg.value).gas(gasleft())());
    }
    
    function Blocker_destroy() public {
        require(msg.sender == owner);
        selfdestruct(owner);
    }
}