contract DividendToken6 {
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
 require(amount > 0 && address(this).balance >= amount, "Insufficient funds");
 creditedPoints[owner] -= amount;
 dividendsCollected += amount;
 owner.transfer(amount);
 return amount;
 }
}