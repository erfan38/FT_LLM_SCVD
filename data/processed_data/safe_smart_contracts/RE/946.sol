contract ERC20 {
    uint public totalSupply;

    function balanceOf(address who) constant returns(uint);

    function transfer(address to, uint value);

    function allowance(address owner, address spender) constant returns(uint);

    function transferFrom(address from, address to, uint value);

    function approve(address spender, uint value);

    event Approval(address indexed owner, address indexed spender, uint value);

    event Transfer(address indexed from, address indexed to, uint value);
}

