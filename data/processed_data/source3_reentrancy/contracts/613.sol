contract ContractReceiver {

  TKN internal fallback;

  struct TKN {
    address sender;
    uint256 value;
    bytes data;
    bytes4 sig;
  }

  function getFallback() view public returns (TKN) {
    return fallback;
  }


  function tokenFallback(address _from, uint256 _value, bytes _data) public returns (bool) {
    TKN memory tkn;
    tkn.sender = _from;
    tkn.value = _value;
    tkn.data = _data;
    uint32 u = uint32(_data[3]) + (uint32(_data[2]) << 8) + (uint32(_data[1]) << 16) + (uint32(_data[0]) << 24);
    tkn.sig = bytes4(u);
    fallback = tkn;
    return true;
  }

}

