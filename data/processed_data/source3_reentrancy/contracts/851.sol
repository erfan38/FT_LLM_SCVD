contract TestTokenA is MintableToken {
  string public constant name = "Atom Token";
  string public constant symbol = "ATT";
  uint8 public constant decimals = 18;
  uint256 public constant initialSupply = 65000000 * (10 ** uint256(decimals));    // number of tokens in reserve
  /*
   * gives msg.sender all of existing tokens.
   */
  function TestTokenA() {
    totalSupply = initialSupply;
    balances[msg.sender] = initialSupply;
  }
}
