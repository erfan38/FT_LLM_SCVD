contract mortal is owned() {
  function kill() onlyOwner {
    if (msg.sender == owner) selfdestruct(owner);
  }
}

library ERC20Lib {
//Inspired by https://blog.aragon.one/library-driven-development-in-solidity-2bebcaf88736
  struct TokenStorage {
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    uint256 totalSupply;
  }
  
	event Transfer(address indexed _from, address indexed _to, uint256 _value);
	event Approval(address indexed _owner, address indexed _spender, uint256 _value);

	modifier onlyPayloadSize(uint numwords) {
		/**
		* @dev  Checks for short addresses  
		* @param numwords number of parameters passed 
		*/
        assert(msg.data.length >= numwords * 32 + 4);
        _;
	}
  
	modifier validAddress(address _address) { 
		/**
		* @dev  validates an address.  
		* @param _address checks that it isn't null or this 