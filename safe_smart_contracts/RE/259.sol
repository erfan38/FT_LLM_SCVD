contract BasicToken is ERC20Basic, Ownable {
  using SafeMath for uint256;

 mapping (address => bool) public frozenAccount;
 event FrozenFunds(address target, bool frozen);

  uint256 totalSupply_;

  /**
  * @dev total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }
  
   function freezeAccount(address target, bool freeze) onlyOwner external {
         frozenAccount[target] = freeze;
         emit FrozenFunds(target, freeze);
         }

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
      require(!frozenAccount[msg.sender]);
    require(_to != address(0));
    require(_value <= _balanceOf[msg.sender]);

    // SafeMath.sub will throw if there is not enough balance.
    _balanceOf[msg.sender] = _balanceOf[msg.sender].sub(_value);
    _balanceOf[_to] = _balanceOf[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return _balanceOf[_owner];
  }

}
/////////////////////////////////////////////////////////////////////////////////////////////
/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
