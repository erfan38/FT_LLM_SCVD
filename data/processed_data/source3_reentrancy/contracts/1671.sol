contract ERC223 is ERC20 {
	//ERC223 token standard https://github.com/Dexaran/ERC223-token-standard
	
	function transfer(address _to, uint256 _value, bytes _data) public returns (bool success);
	function transfer(address _to, uint256 _value, bytes _data, string _customFallback) public returns (bool success);
	
	event Transfer(address indexed _from, address indexed _to, uint256 _value, bytes _data);
}

