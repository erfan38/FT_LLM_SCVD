contract ContractReceiver {
    function tokenFallback(address _from, uint256 _value, bytes _data){
      _from = _from;
      _value = _value;
      _data = _data;
      // Incoming transaction code here
    }
}
 
 /* New ERC23 