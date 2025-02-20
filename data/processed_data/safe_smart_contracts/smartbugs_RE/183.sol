pragma solidity ^0.4.24;

interface tokenRecipient { 
    function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external; 
}

contract Interacting {
    address private owner = msg.sender;
    
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    
    function sendEther(address _to) external payable onlyOwner {
        require(_to.call.value(msg.value)(''));
    }
    
    function callMethod(address _contract, bytes _extraData) external payable onlyOwner {
        require(_contract.call.value(msg.value)(_extraData));
    }
    
    function withdrawEther(address _to) external onlyOwner {
        _to.transfer(address(this).balance);
    }
    
    function () external payable {
        
    }
}
