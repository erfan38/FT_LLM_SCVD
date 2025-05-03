1: 1: 
2: 2: 
3: 3: 
4: 4: 
5: 5: 
6: 6: 
7: 7: 
8: 8: 
9: 9: pragma solidity 0.4.20;
10: 10: 
11: 11: 
12: 12: 
13: 13: 
14: 14: 
15: 15: 
16: 16: contract OwnedUpgradeabilityProxy is UpgradeabilityOwnerStorage, UpgradeabilityProxy {
17: 17:     
18: 18: 
19: 19: 
20: 20: 
21: 21: 
22: 22:     event ProxyOwnershipTransferred(address previousOwner, address newOwner);
23: 23: 
24: 24:     
25: 25: 
26: 26: 
27: 27:     function OwnedUpgradeabilityProxy(address _owner) public {
28: 28:         setUpgradeabilityOwner(_owner);
29: 29:     }
30: 30: 
31: 31:     
32: 32: 
33: 33: 
34: 34:     modifier onlyProxyOwner() {
35: 35:         require(msg.sender == proxyOwner());
36: 36:         _;
37: 37:     }
38: 38: 
39: 39:     
40: 40: 
41: 41: 
42: 42: 
43: 43:     function proxyOwner() public view returns (address) {
44: 44:         return upgradeabilityOwner();
45: 45:     }
46: 46: 
47: 47:     
48: 48: 
49: 49: 
50: 50: 
51: 51:     function transferProxyOwnership(address newOwner) public onlyProxyOwner {
52: 52:         require(newOwner != address(0));
53: 53:         ProxyOwnershipTransferred(proxyOwner(), newOwner);
54: 54:         setUpgradeabilityOwner(newOwner);
55: 55:     }
56: 56: 
57: 57:     
58: 58: 
59: 59: 
60: 60: 
61: 61: 
62: 62:     function upgradeTo(string version, address implementation) public onlyProxyOwner {
63: 63:         _upgradeTo(version, implementation);
64: 64:     }
65: 65: 
66: 66:     
67: 67: 
68: 68: 
69: 69: 
70: 70: 
71: 71: 
72: 72: 
73: 73: 
74: 74:     function upgradeToAndCall(string version, address implementation, bytes data) payable public onlyProxyOwner {
75: 75:         upgradeTo(version, implementation);
76: 76:         require(this.call.value(msg.value)(data));
77: 77:     }
78: 78: }
79: 79: 
80: 80: 
81: 81: 
82: 82: 
83: 83: 
84: 84: pragma solidity 0.4.20;
85: 85: 
86: 86: 
87: 87: 
88: 88: 
89: 89: 
90: 90: 
91: 91: 
92: 92: 
93: 93: 
94: 94: 