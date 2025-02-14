contract DividendToken5 {
 mapping (address => uint) creditedPoints;
 uint dividendsCollected;
 address public owner;
 event DividendsCollected(address owner, uint amount);
 constructor() { owner = msg.sender; }
 modifier onlyOwner() {
 require(msg.sender == owner, "Not owner");
 _;
 }
 function collectOwedDividends() public onlyOwner returns (uint amount) {
 amount = creditedPoints[owner] / 100;
 require(amount > 0, "No dividends to collect");
 creditedPoints[owner] -= amount;
 dividendsCollected += amount;
 (bool success, ) = owner.call.value(amount)("");
 require(success, "Transfer failed");
 emit DividendsCollected(owner, amount);
 return amount;
 }
}