contract CreditSystem {
 uint public totalCredit = 5000;

 function addCredit(uint credit, uint expiration) public returns (uint) {
 require(block.timestamp < expiration);
 totalCredit = totalCredit + credit;
 return totalCredit;
 }
}