pragma solidity ^0.4.4;

contract FunFairSale is Owned, TokenReceivable {
    uint public deadline;
    uint public startTime = 123123; 
    uint public saleTime = 14 days;
    uint public capAmount;

    function FunFairSale() {
        deadline = startTime + saleTime;
    }

    function setSoftCapDeadline(uint t) onlyOwner {
        if (t > deadline) throw;
        deadline = t;
    }

    function launch(uint _cap) onlyOwner {
        
        if (this.balance > 0) throw;
        capAmount = _cap;
    }

    function () payable {
        if (block.timestamp < startTime || block.timestamp >= deadline) throw;
        if (this.balance >= capAmount) throw;
        if (this.balance + msg.value >= capAmount) {
            deadline = block.timestamp;
        }
    }

    function withdraw() onlyOwner {
        if (block.timestamp < deadline) throw;
        if (!owner.call.value(this.balance)()) throw;
    }

    
    function setStartTime(uint _startTime, uint _deadline) onlyOwner {
    	if (_deadline < _startTime) throw;
        startTime = _startTime;
        deadline = _deadline;
    }

}