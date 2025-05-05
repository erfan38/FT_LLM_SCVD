contract ERC223Token is ERC223, SafeMath {

  mapping(address => uint) balances;
  
  string public name = "NIJIGEN";
  string public symbol = "NIJ";
  uint8 public decimals = 8;
  uint256 public totalSupply = 24e9 * 1e8;
  
  
  // Function to access name of token .
  function name() public view returns (string _name) {
      return name;
  }
  // Function to access symbol of token .
  function symbol() public view returns (string _symbol) {
      return symbol;
  }
  // Function to access decimals of token .
  function decimals() public view returns (uint8 _decimals) {
      return decimals;
  }
  // Function to access total supply of tokens .
  function totalSupply() public view returns (uint256 _totalSupply) {
      return totalSupply;
  }
  
  
  // Function that is called when a user or another 