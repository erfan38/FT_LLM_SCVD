contract ERC223Basic is StandardToken{
    uint public totalSupply;
    // function balanceOf(address who) constant returns (uint);
    function transfer(address to, uint value);
    function transfer(address to, uint value, bytes data);
    event Transfer(address indexed from, address indexed to, uint value, bytes indexed data);
}
