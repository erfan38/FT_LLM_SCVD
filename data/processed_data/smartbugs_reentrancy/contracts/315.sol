1: 
2: 
3: pragma solidity ^0.5.9;
4: 
5: 
6: interface ERC20 {
7:     function transfer(address _to, uint _value) external returns (bool success);
8:     function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);
9:     function allowance(address _owner, address _spender) external view returns (uint256 remaining);
10:     function approve(address _spender, uint256 _value) external returns (bool success);
11:     function increaseApproval (address _spender, uint _addedValue) external returns (bool success);
12:     function balanceOf(address _owner) external view returns (uint256 balance);
13: }
14: 
15: 
16: 
17: pragma solidity ^0.5.9;
18: 
19: 
20: interface NanoLoanEngine {
21:     enum Status { initial, lent, paid, destroyed }
22:     function rcn() external returns (ERC20);
23:     function getTotalLoans() external view returns (uint256);
24:     function pay(uint index, uint256 _amount, address _from, bytes calldata oracleData) external returns (bool);
25:     function cosign(uint index, uint256 cost) external returns (bool);
26:     function getCreator(uint index) external view returns (address);
27:     function getDueTime(uint index) external view returns (uint256);
28:     function getDuesIn(uint index) external view returns (uint256);
29:     function getPendingAmount(uint index) external returns (uint256);
30:     function getStatus(uint index) external view returns (Status);
31: }
32: 
33: 
34: 
35: pragma solidity ^0.5.9;
36: 
37: 
38: contract Wallet is Ownable {
39:     function execute(
40:         address payable _to,
41:         uint256 _value,
42:         bytes calldata _data
43:     ) external onlyOwner returns (bool, bytes memory) {
44:         return _to.call.value(_value)(_data);
45:     }
46: }
47: 
48: 
49: 
50: pragma solidity ^0.5.9;
51: 
52: 
53: 