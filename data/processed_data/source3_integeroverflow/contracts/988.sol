contract TokenExchange {
 function exchange(uint amount, uint rate) public pure returns (uint) {
 return amount * rate;
 }
}