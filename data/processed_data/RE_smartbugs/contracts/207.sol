1: 1: pragma solidity ^0.4.24;
2: 2: 
3: 3: 
4: 4: 
5: 5: 
6: 6: 
7: 7: 
8: 8: 
9: 9: 
10: 10: 
11: 11: 
12: 12: contract AdminUpgradeabilityProxy is UpgradeabilityProxy {
13: 13:     
14: 14: 
15: 15: 
16: 16: 
17: 17: 
18: 18:     event AdminChanged(address previousAdmin, address newAdmin);
19: 19: 
20: 20:     
21: 21: 
22: 22: 
23: 23: 
24: 24: 
25: 25:     bytes32 private constant ADMIN_SLOT = 0x10d6a54a4754c8869d6886b5f5d7fbfa5b4522237ea5c60d11bc4e7a1ff9390b;
26: 26: 
27: 27:     
28: 28: 
29: 29: 
30: 30: 
31: 31: 
32: 32:     modifier ifAdmin() {
33: 33:         if (msg.sender == _admin()) {
34: 34:             _;
35: 35:         } else {
36: 36:             _fallback();
37: 37:         }
38: 38:     }
39: 39: 
40: 40:     
41: 41: 
42: 42: 
43: 43: 
44: 44: 
45: 45:     constructor(address _implementation) UpgradeabilityProxy(_implementation) public {
46: 46:         assert(ADMIN_SLOT == keccak256("org.zeppelinos.proxy.admin"));
47: 47: 
48: 48:         _setAdmin(msg.sender);
49: 49:     }
50: 50: 
51: 51:     
52: 52: 
53: 53: 
54: 54:     function admin() external view ifAdmin returns (address) {
55: 55:         return _admin();
56: 56:     }
57: 57: 
58: 58:     
59: 59: 
60: 60: 
61: 61:     function implementation() external view ifAdmin returns (address) {
62: 62:         return _implementation();
63: 63:     }
64: 64: 
65: 65:     
66: 66: 
67: 67: 
68: 68: 
69: 69: 
70: 70:     function changeAdmin(address newAdmin) external ifAdmin {
71: 71:         require(newAdmin != address(0), "Cannot change the admin of a proxy to the zero address");
72: 72:         emit AdminChanged(_admin(), newAdmin);
73: 73:         _setAdmin(newAdmin);
74: 74:     }
75: 75: 
76: 76:     
77: 77: 
78: 78: 
79: 79: 
80: 80: 
81: 81:     function upgradeTo(address newImplementation) external ifAdmin {
82: 82:         _upgradeTo(newImplementation);
83: 83:     }
84: 84: 
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
95: 95:     function upgradeToAndCall(address newImplementation, bytes data) payable external ifAdmin {
96: 96:         _upgradeTo(newImplementation);
97: 97:         require(address(this).call.value(msg.value)(data));
98: 98:     }
99: 99: 
100: 100:     
101: 101: 
102: 102: 
103: 103:     function _admin() internal view returns (address adm) {
104: 104:         bytes32 slot = ADMIN_SLOT;
105: 105:         assembly {
106: 106:             adm := sload(slot)
107: 107:         }
108: 108:     }
109: 109: 
110: 110:     
111: 111: 
112: 112: 
113: 113: 
114: 114:     function _setAdmin(address newAdmin) internal {
115: 115:         bytes32 slot = ADMIN_SLOT;
116: 116: 
117: 117:         assembly {
118: 118:             sstore(slot, newAdmin)
119: 119:         }
120: 120:     }
121: 121: 
122: 122:     
123: 123: 
124: 124: 
125: 125:     function _willFallback() internal {
126: 126:         require(msg.sender != _admin(), "Cannot call fallback function from the proxy admin");
127: 127:         super._willFallback();
128: 128:     }
129: 129: }