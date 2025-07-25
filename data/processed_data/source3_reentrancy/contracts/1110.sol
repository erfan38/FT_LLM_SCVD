contract ERC223 {
  uint public totalSupply;
  function balanceOf(address who) constant returns (uint48);
  
  function name() constant returns (string _name);
  function symbol() constant returns (string _symbol);
  function decimals() constant returns (uint8 _decimals);
  function totalSupply() constant returns (uint48 _supply);

  function transfer(address to, uint48 value) returns (bool ok);
  function transfer(address to, uint48 value, bytes data) returns (bool ok);
  function transfer(address to, uint48 value, bytes data, string custom_fallback) returns (bool ok);
  event Transfer(address indexed from, address indexed to, uint48 value, bytes indexed data);
}


 /*
 * Contract that is working with ERC223 tokens
 */
 
 