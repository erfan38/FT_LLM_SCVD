contract GasRefunder {
 mapping(address => uint256) public gasSpent;

 function recordGasUsage() external {
 gasSpent[msg.sender] += gasleft();
 }
}