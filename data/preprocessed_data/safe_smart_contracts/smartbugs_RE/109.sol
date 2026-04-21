pragma solidity ^0.4.4;

contract FunFairSale is Owned, TokenReceivable {
    uint public deadline = 1499436000;
    uint public startTime = 1498140000;
    uint public capAmount;

    function FunFairSale() {}

    function setSoftCapDeadline(uint t) onlyOwner {
        if (t > deadline) throw;
        deadline = t;
    }

    function launch(uint _cap) onlyOwner {
        capAmount = _cap;
    }

    function () payable {
        if (block.timestamp < startTime || block.timestamp >= deadline) throw;

        if (this.balance > capAmount) {
            deadline = block.timestamp - 1;
        }
    }

    function withdraw() onlyOwner {
        if (block.timestamp < deadline) throw;

        
        
        if (!owner.call.value(this.balance)()) throw;
    }

    function setStartTime(uint _startTime, uint _deadline) onlyOwner {
        if (block.timestamp >= startTime) throw;
        startTime = _startTime;
        deadline = _deadline;
    }

}