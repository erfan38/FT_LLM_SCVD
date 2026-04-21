contract Registrar {

	// Patron token ERC20 public variables
	string public constant symbol = "ART";
	string public constant name = "Patron - Ethart Network Token";
	uint8 public constant decimals = 18;
	uint256 _totalPatronSupply;

	event Transfer(address indexed _from, address _to, uint256 _value);
	event Approval(address indexed _owner, address _spender, uint256 _value);
	event Burn(address indexed _owner, uint256 _amount);

    // Patron token balances for each account
	mapping(address => uint256) public balances;						// Patron token balances

	event NewArtwork(address _contract, bytes32 _SHA256Hash, uint256 _editionSize, string _title, string _fileLink, uint256 _ownerCommission, address _artist, bool _indexed, bool _ouroboros);


 	// Owner of account approves the transfer of an amount of Patron tokens to another account
 	mapping(address => mapping (address => uint256)) allowed;			// Patron token allowances
	
	// BEGIN ERC20 functions (c) BokkyPooBah 2017. The MIT Licence.

    function totalSupply() constant returns (uint256 totalPatronSupply) {
		totalPatronSupply = _totalPatronSupply;
		}

	// What is the balance of a particular account?
	function balanceOf(address _owner) constant returns (uint256 balance) {
 		return balances[_owner];
		}

	// Transfer the balance from owner's account to another account
	function transfer(address _to, uint256 _amount) returns (bool success) {
		if (balances[msg.sender] >= _amount 
			&& _amount > 0
 		   	&& balances[_to] + _amount > balances[_to]
			&& _to != 0x0)										// use burn() instead
			{
			balances[msg.sender] -= _amount;
			balances[_to] += _amount;
			Transfer(msg.sender, _to, _amount);
 		   	return true;
			}
			else { return false;}
 		 }

	// Send _value amount of tokens from address _from to address _to
	// The transferFrom method is used for a withdraw workflow, allowing contracts to send
 	// tokens on your behalf, for example to "deposit" to a 