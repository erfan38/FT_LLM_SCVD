contract SafeWallet {
 mapping(address => uint) private balances;
 bool private locked = false;

 modifier noReentrancy() {
 require(!locked, "Reentrant call");
 locked = true;
 _;
 locked = false;
 }

 function withdraw(uint amount) public noReentrancy {
 require(balances[msg.sender] >= amount, "Insufficient balance");
 balances[msg.sender] -= amount;
 (bool success, ) = msg.sender.call{value: amount}("");
 require(success, "Transfer failed");
 }

 function deposit() public payable {
 balances[msg.sender] += msg.value;
 }
}