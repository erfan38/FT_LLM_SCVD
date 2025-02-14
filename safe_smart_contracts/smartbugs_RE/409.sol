contract SafeBank {
 mapping(address => uint256) public balances;
 bool private locked;

 modifier noReentrant() {
 require(!locked, "Reentrant call");
 locked = true;
 _;
 locked = false;
 }

 function deposit() public payable {
 balances[msg.sender] += msg.value;
 }

 function withdraw(uint256 _amount) public noReentrant {
 require(balances[msg.sender] >= _amount, "Insufficient balance");
 balances[msg.sender] -= _amount;
 (bool success, ) = msg.sender.call{value: _amount}("");
 require(success, "Transfer failed");
 }
}