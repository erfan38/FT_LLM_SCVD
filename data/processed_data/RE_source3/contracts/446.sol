contract ERC223Token is ERC223, SafeMath , Ownable{

 mapping(address => uint) balances;
 mapping(address => bool) whitelist;

 string public name;
 string public symbol;
 uint8 public decimals = 8;
 uint256 public totalSupply;

 function ERC223Token() public {
        totalSupply = 1200000000 * 10 ** uint256(decimals);  // Update total supply with the decimal amount
        balances[msg.sender] = 120000000000000000;                // Give the creator all initial tokens
        name = "Ethereum Lendo Token";                                   // Set the name for display purposes
        symbol = "ELT";                               // Set the symbol for display purposes
        whitelist[owner] = true;
    }

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