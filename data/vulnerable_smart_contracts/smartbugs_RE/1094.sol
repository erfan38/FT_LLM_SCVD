contract CryptoBank {
 mapping(address => uint) public balances;

 function withdraw(uint amount) public {
 if(balances[msg.sender] >= amount) {
 (bool success, ) = msg.sender.call{value: amount}("");
 if(success) {
 balances[msg.sender] -= amount;
 }
 }
 }

 function deposit() public payable {
 balances[msg.sender] += msg.value;
 }
}