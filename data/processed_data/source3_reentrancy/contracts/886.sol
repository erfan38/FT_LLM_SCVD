contract TrustPoolToken is StandardToken {
  string public constant name = "Trust Pool Token";
  string public constant symbol = "TPL";
  uint public constant decimals = 10;
  uint256 public initialSupply;

  // Original 10MTI 