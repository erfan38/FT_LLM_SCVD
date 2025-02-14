contract GameCoins {
 uint public totalCoins = 1000000;

 function spendCoins(uint coins) public returns (uint) {
 totalCoins = totalCoins - coins;
 return totalCoins;
 }
}