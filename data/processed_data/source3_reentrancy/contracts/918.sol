contract ERC20 is ERC20Basic {
  	function allowance(address owner, address spender) constant returns (uint256);
  	function transferFrom(address from, address to, uint256 value) returns (bool);
  	function approve(address spender, uint256 value) returns (bool);
  	event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances. 
 */
