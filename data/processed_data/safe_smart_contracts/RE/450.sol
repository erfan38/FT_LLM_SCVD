contract ERC223TokenCompatible is BasicToken {
  using SafeMath for uint256;
  
  event Transfer(address indexed from, address indexed to, uint256 value, bytes indexed data);

  // Function that is called when a user or another 