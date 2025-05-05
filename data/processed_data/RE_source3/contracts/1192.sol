contract SharkProxy is Ownable {

  event Deposit(address indexed sender, uint256 value);
  event Withdrawal(address indexed to, uint256 value, bytes data);

  function SharkProxy() {
    owner = msg.sender;
  }

  function getOwner() constant returns (address) {
    return owner;
  }

  function forward(address _destination, uint256 _value, bytes _data) onlyOwner {
    require(_destination != address(0));
    assert(_destination.call.value(_value)(_data)); // send eth and/or data
    if (_value > 0) {
      Withdrawal(_destination, _value, _data);
    }
  }

  /**
   * Default function; is called when Ether is deposited.
   */
  function() payable {
    Deposit(msg.sender, msg.value);
  }

  /**
   * @dev is called when ERC223 token is deposited.
   */
  function tokenFallback(address _from, uint _value, bytes _data) {
  }

}


