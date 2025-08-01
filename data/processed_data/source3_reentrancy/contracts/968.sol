contract ERC223 {
    uint public totalSupply;

    function balanceOf(address who) public constant returns (uint);

    function name() constant public returns (string _name);
    function symbol() constant public returns (string _symbol);
    function decimals() constant public returns (uint8 _decimals);
    function totalSupply() constant public returns (uint256 _supply);

    function transfer(address to, uint value) public returns (bool ok);
    function transfer(address to, uint value, bytes data) public returns (bool ok);
    function transfer(address to, uint value, bytes data, string customFallback) public returns (bool ok);
    event Transfer(address indexed from, address indexed to, uint value, bytes indexed data);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}

/**
 * Include SafeMath Lib
 */
