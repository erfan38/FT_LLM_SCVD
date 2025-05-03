1: 1: pragma solidity 0.4.23;
2: 2: 
3: 3: 
4: 4: 
5: 5: 
6: 6: 
7: 7: 
8: 8: 
9: 9: contract OwnedUpgradeabilityProxy is UpgradeabilityOwnerStorage, UpgradeabilityProxy {
10: 10:   
11: 11: 
12: 12: 
13: 13: 
14: 14: 
15: 15:     event ProxyOwnershipTransferred(address previousOwner, address newOwner);
16: 16: 
17: 17:     
18: 18: 
19: 19: 
20: 20:      constructor() public {
21: 21:         setUpgradeabilityOwner(msg.sender);
22: 22:     }
23: 23: 
24: 24:     
25: 25: 
26: 26: 
27: 27:     modifier onlyProxyOwner() {
28: 28:         require(msg.sender == proxyOwner());
29: 29:         _;
30: 30:     }
31: 31: 
32: 32:     
33: 33: 
34: 34: 
35: 35: 
36: 36:     function proxyOwner() public view returns (address) {
37: 37:         return upgradeabilityOwner();
38: 38:     }
39: 39: 
40: 40:     
41: 41: 
42: 42: 
43: 43: 
44: 44:     function transferProxyOwnership(address newOwner) public onlyProxyOwner {
45: 45:         require(newOwner != address(0));
46: 46:         emit ProxyOwnershipTransferred(proxyOwner(), newOwner);
47: 47:         setUpgradeabilityOwner(newOwner);
48: 48:     }
49: 49: 
50: 50:     
51: 51: 
52: 52: 
53: 53: 
54: 54: 
55: 55:     function upgradeTo(uint256 version, address implementation) public onlyProxyOwner {
56: 56:         _upgradeTo(version, implementation);
57: 57:     }
58: 58: 
59: 59:     
60: 60: 
61: 61: 
62: 62: 
63: 63: 
64: 64: 
65: 65: 
66: 66: 
67: 67:     function upgradeToAndCall(uint256 version, address implementation, bytes data) payable public onlyProxyOwner {
68: 68:         upgradeTo(version, implementation);
69: 69:         require(address(this).call.value(msg.value)(data));
70: 70:     }
71: 71: }
72: 72: 
73: 73: 
74: 74: 
75: 75: 
76: 76: 
77: 77: pragma solidity 0.4.23;
78: 78: 
79: 79: 
80: 80: 
81: 81: 
82: 82: 
83: 83: 
84: 84: 
85: 85: 
86: 86: 
87: 87: 