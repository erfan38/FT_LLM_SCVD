pragma solidity ^0.4.23;






contract ERC827Caller {
  function makeCall(address _target, bytes _data) external payable returns (bool) {
    
    return _target.call.value(msg.value)(_data);
  }
}









