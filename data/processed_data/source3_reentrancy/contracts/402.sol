contract ERC20Interface {
	function totalSupply() public constant returns(uint256 totalSupplyReturn);
	function balanceOf(address _owner) public constant returns(uint256 balance);
	function transfer(address _to, uint256 _value) public returns(bool success);
	function transferFrom(address _from, address _to, uint256 _value) public returns(bool success);
	function approve(address _spender, uint256 _value) public returns(bool success);
	function allowance(address _owner, address _spender) public constant returns(uint256 remaining);
	event Transfer(address indexed _from, address indexed _to, uint256 _value);
	event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}


/// @title Multisignature wallet - Allows multiple parties to agree on transactions before execution.
/// @author Stefan George - <[email protected]>
