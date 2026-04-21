contract DividendToken7 {
 mapping (address => uint) creditedPoints;
 uint dividendsCollected;
 address public owner;
 uint public lastCollectionTime;
 constructor() { owner = msg.sender; }
 modifier onlyOwner() {
 require(msg.sender == owner, "Not owner");
 _;
 }
 function collectOwedDividends() public onlyOwner returns (uint amount) {
 require(block.timestamp >= lastCollectionTime + 1 days, "Can only collect once per day");
 amount = creditedPoints[owner] / 100;
 creditedPoints[owner] -= amount;
 dividendsCollected += amount;
 lastCollectionTime = block.timestamp;
 require(owner.send(amount), "Transfer failed");
 return amount;
 }
}