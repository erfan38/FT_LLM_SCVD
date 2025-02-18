pragma solidity ^0.4.24;








contract ERC1003Caller is Ownable {
    function makeCall(address target, bytes data) external payable onlyOwner returns (bool) {
        
        return target.call.value(msg.value)(data);
    }
}

