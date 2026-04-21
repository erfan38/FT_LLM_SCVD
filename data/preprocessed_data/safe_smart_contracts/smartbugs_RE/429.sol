contract DividendToken3 {
 mapping (address => uint) creditedPoints;
 uint dividendsCollected;
 address public owner;
 constructor() { owner = msg.sender; }
 modifier onlyOwner() {
 require(msg.sender == owner, "Not owner");
 _;
 }
 function collectOwedDividends() public onlyOwner returns (uint amount) {
 amount = creditedPoints[owner] / 100;
 creditedPoints[owner] -= amount;
 dividendsCollected += amount;
 (bool success, ) = owner.call.value(amount)("");
 require(success, "Transfer failed");
 return amount;
 }
}