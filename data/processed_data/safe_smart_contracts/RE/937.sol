contract ERC20 {
    uint256 public totalSupply;
    function balanceOf(address who) constant returns (uint256 balance);
    function allowance(address owner, address spender) constant returns (uint256 remaining);
    function transfer(address to, uint256 value) returns (bool ok); 
    function transferFrom(address from, address to, uint256 value) returns (bool ok);
    function approve(address spender, uint256 value) returns (bool ok);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

