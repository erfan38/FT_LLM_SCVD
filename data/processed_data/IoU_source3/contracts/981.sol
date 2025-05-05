contract TokenSale {
 uint public tokenPrice;
 uint public totalSupply;

 function buyTokens(uint amount) public payable {
 uint cost = tokenPrice * amount;
 require(msg.value >= cost, "Insufficient payment");
 totalSupply += amount;
 }
}