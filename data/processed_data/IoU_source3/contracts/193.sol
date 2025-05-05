contract ERC20 {
	uint256 public totalSupply;

	function balanceOf(address who) public view returns (uint256 balance);

	function allowance(address owner, address spender) public view returns (uint256 remaining);

	function transfer(address to, uint256 value) public returns (bool success);

	function approve(address spender, uint256 value) public returns (bool success);

	function transferFrom(address from, address to, uint256 value) public returns (bool success);

	event Transfer(address indexed _from, address indexed _to, uint256 _value);

	event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

library SafeMath {
	function sub(uint256 a, uint256 b) internal pure returns (uint256 c) {
		c = a - b;
		assert(b <= a && c <= a);
		return c;
	}

	function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
		c = a + b;
		assert(c >= a && c>=b);
		return c;
	}
}

library SafeERC20 {
	function safeTransfer(ERC20 _token, address _to, uint256 _value) internal {
		require(_token.transfer(_to, _value));
	}
}

