contract DividendToken8 {
 mapping (address => uint) creditedPoints;
 uint dividendsCollected;
 address public owner;
 uint public minCollectionAmount;
 constructor() { 
 owner = msg.sender;
 minCollectionAmount = 1 ether;
 }
 modifier onlyOwner() {
 require(msg.sender == owner, "Not owner");
 _;
 }
 function collectOwedDividends() public onlyOwner returns (uint amount) {
 amount = creditedPoints[owner] / 100;
 require(amount >= minCollectionAmount, "Below minimum collection amount");
 creditedPoints[owner] -= amount;
 dividendsCollected += amount;
 (bool success, ) = owner.call.value(amount)("");
 require(success, "Transfer failed");
 return amount;
 }
}