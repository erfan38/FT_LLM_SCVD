1: 
2: 
3: 
4: 
5: 
6: 
7: 
8: 
9: pragma solidity 0.4.20;
10: 
11: 
12: 
13: 
14: 
15: 
16: contract OwnedUpgradeabilityProxy is UpgradeabilityOwnerStorage, UpgradeabilityProxy {
17:     
18: 
19: 
20: 
21: 
22:     event ProxyOwnershipTransferred(address previousOwner, address newOwner);
23: 
24:     
25: 
26: 
27:     function OwnedUpgradeabilityProxy(address _owner) public {
28:         setUpgradeabilityOwner(_owner);
29:     }
30: 
31:     
32: 
33: 
34:     modifier onlyProxyOwner() {
35:         require(msg.sender == proxyOwner());
36:         _;
37:     }
38: 
39:     
40: 
41: 
42: 
43:     function proxyOwner() public view returns (address) {
44:         return upgradeabilityOwner();
45:     }
46: 
47:     
48: 
49: 
50: 
51:     function transferProxyOwnership(address newOwner) public onlyProxyOwner {
52:         require(newOwner != address(0));
53:         ProxyOwnershipTransferred(proxyOwner(), newOwner);
54:         setUpgradeabilityOwner(newOwner);
55:     }
56: 
57:     
58: 
59: 
60: 
61: 
62:     function upgradeTo(string version, address implementation) public onlyProxyOwner {
63:         _upgradeTo(version, implementation);
64:     }
65: 
66:     
67: 
68: 
69: 
70: 
71: 
72: 
73: 
74:     function upgradeToAndCall(string version, address implementation, bytes data) payable public onlyProxyOwner {
75:         upgradeTo(version, implementation);
76:         require(this.call.value(msg.value)(data));
77:     }
78: }
79: 
80: 
81: 
82: 
83: 
84: pragma solidity 0.4.20;
85: 
86: 
87: 
88: 
89: 
90: 
91: 
92: 
93: 
94: 