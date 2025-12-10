contract DividendToken9 {
 mapping (address => uint) creditedPoints;
 uint dividendsCollected;
 address public owner;
 bool private locked;
 constructor() { owner = msg.sender; }
 modifier onlyOwner() {
 require(msg.sender == owner, "Not owner");
 _;
 }
 modifier noReentrancy() {
 require(!locked, "Reentrant call");
 locked = true;
 _;
 locked = false;
 }
 function collectOwedDividends() public onlyOwner noReentrancy returns (uint amount) {
 amount = creditedPoints[owner] / 100;
 creditedPoints[owner] -= amount;
 dividendsCollected += amount;
 (bool success, ) = owner.call.value(amount)("");
 require(success, "Transfer failed");
 return amount;
 }
}