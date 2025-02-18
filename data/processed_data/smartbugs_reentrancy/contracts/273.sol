1: 1: 1: 1: 1: 
2: 2: 2: 2: 2: 
3: 3: 3: 3: 3: pragma solidity 0.4.19;
4: 4: 4: 4: 4: 
5: 5: 5: 5: 5: 
6: 6: 6: 6: 6: 
7: 7: 7: 7: 7: 
8: 8: 8: 8: 8: 
9: 9: 9: 9: 9: 
10: 10: 10: 10: 10: contract OwnedUpgradeabilityProxy is UpgradeabilityOwnerStorage, UpgradeabilityProxy {
11: 11: 11: 11: 11:   
12: 12: 12: 12: 12: 
13: 13: 13: 13: 13: 
14: 14: 14: 14: 14: 
15: 15: 15: 15: 15: 
16: 16: 16: 16: 16:     event ProxyOwnershipTransferred(address previousOwner, address newOwner);
17: 17: 17: 17: 17: 
18: 18: 18: 18: 18:     
19: 19: 19: 19: 19: 
20: 20: 20: 20: 20: 
21: 21: 21: 21: 21:     function OwnedUpgradeabilityProxy() public {
22: 22: 22: 22: 22:         setUpgradeabilityOwner(msg.sender);
23: 23: 23: 23: 23:     }
24: 24: 24: 24: 24: 
25: 25: 25: 25: 25:     
26: 26: 26: 26: 26: 
27: 27: 27: 27: 27: 
28: 28: 28: 28: 28:     modifier onlyProxyOwner() {
29: 29: 29: 29: 29:         require(msg.sender == proxyOwner());
30: 30: 30: 30: 30:         _;
31: 31: 31: 31: 31:     }
32: 32: 32: 32: 32: 
33: 33: 33: 33: 33:     
34: 34: 34: 34: 34: 
35: 35: 35: 35: 35: 
36: 36: 36: 36: 36: 
37: 37: 37: 37: 37:     function proxyOwner() public view returns (address) {
38: 38: 38: 38: 38:         return upgradeabilityOwner();
39: 39: 39: 39: 39:     }
40: 40: 40: 40: 40: 
41: 41: 41: 41: 41:     
42: 42: 42: 42: 42: 
43: 43: 43: 43: 43: 
44: 44: 44: 44: 44: 
45: 45: 45: 45: 45:     function transferProxyOwnership(address newOwner) public onlyProxyOwner {
46: 46: 46: 46: 46:         require(newOwner != address(0));
47: 47: 47: 47: 47:         ProxyOwnershipTransferred(proxyOwner(), newOwner);
48: 48: 48: 48: 48:         setUpgradeabilityOwner(newOwner);
49: 49: 49: 49: 49:     }
50: 50: 50: 50: 50: 
51: 51: 51: 51: 51:     
52: 52: 52: 52: 52: 
53: 53: 53: 53: 53: 
54: 54: 54: 54: 54: 
55: 55: 55: 55: 55: 
56: 56: 56: 56: 56:     function upgradeTo(uint256 version, address implementation) public onlyProxyOwner {
57: 57: 57: 57: 57:         _upgradeTo(version, implementation);
58: 58: 58: 58: 58:     }
59: 59: 59: 59: 59: 
60: 60: 60: 60: 60:     
61: 61: 61: 61: 61: 
62: 62: 62: 62: 62: 
63: 63: 63: 63: 63: 
64: 64: 64: 64: 64: 
65: 65: 65: 65: 65: 
66: 66: 66: 66: 66: 
67: 67: 67: 67: 67: 
68: 68: 68: 68: 68:     function upgradeToAndCall(uint256 version, address implementation, bytes data) payable public onlyProxyOwner {
69: 69: 69: 69: 69:         upgradeTo(version, implementation);
70: 70: 70: 70: 70:         require(address(this).call.value(msg.value)(data));
71: 71: 71: 71: 71:     }
72: 72: 72: 72: 72: }
73: 73: 73: 73: 73: 
74: 74: 74: 74: 74: 
75: 75: 75: 75: 75: 
76: 76: 76: 76: 76: pragma solidity 0.4.19;
77: 77: 77: 77: 77: 
78: 78: 78: 78: 78: 
79: 79: 79: 79: 79: 
80: 80: 80: 80: 80: 
81: 81: 81: 81: 81: 
82: 82: 82: 82: 82: 
83: 83: 83: 83: 83: 
84: 84: 84: 84: 84: 
85: 85: 85: 85: 85: 
86: 86: 86: 86: 86: 