pragma solidity ^0.4.24;








contract ERC1003Caller is Ownable {
    function makeCall(address _target, bytes _data) external payable onlyOwner returns (bool) {
        
        return _target.call.value(msg.value)(_data);
    }
}

