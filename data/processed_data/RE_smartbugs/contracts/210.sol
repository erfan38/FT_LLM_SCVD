1: 1: pragma solidity ^0.4.24;
2: 2: 
3: 3: 
4: 4: 
5: 5: 
6: 6: 
7: 7: 
8: 8: 
9: 9: contract CvcProxy is ImplementationStorage {
10: 10: 
11: 11:     
12: 12: 
13: 13: 
14: 14: 
15: 15:     event Upgraded(address implementation);
16: 16: 
17: 17:     
18: 18: 
19: 19: 
20: 20: 
21: 21: 
22: 22:     event AdminChanged(address previousAdmin, address newAdmin);
23: 23: 
24: 24:     
25: 25: 
26: 26: 
27: 27: 
28: 28:     bytes32 private constant ADMIN_SLOT = 0x2bbac3e52eee27be250d682577104e2abe776c40160cd3167b24633933100433;
29: 29: 
30: 30:     
31: 31: 
32: 32: 
33: 33: 
34: 34:     modifier ifAdmin() {
35: 35:         if (msg.sender == currentAdmin()) {
36: 36:             _;
37: 37:         } else {
38: 38:             delegate(implementation());
39: 39:         }
40: 40:     }
41: 41: 
42: 42:     
43: 43: 
44: 44: 
45: 45: 
46: 46:     constructor() public {
47: 47:         assert(ADMIN_SLOT == keccak256("cvc.proxy.admin"));
48: 48:         setAdmin(msg.sender);
49: 49:     }
50: 50: 
51: 51:     
52: 52: 
53: 53: 
54: 54:     function() external payable {
55: 55:         require(msg.sender != currentAdmin(), "Message sender is not contract admin");
56: 56:         delegate(implementation());
57: 57:     }
58: 58: 
59: 59:     
60: 60: 
61: 61: 
62: 62: 
63: 63: 
64: 64:     function changeAdmin(address _newAdmin) external ifAdmin {
65: 65:         require(_newAdmin != address(0), "Cannot change contract admin to zero address");
66: 66:         emit AdminChanged(currentAdmin(), _newAdmin);
67: 67:         setAdmin(_newAdmin);
68: 68:     }
69: 69: 
70: 70:     
71: 71: 
72: 72: 
73: 73: 
74: 74:     function upgradeTo(address _implementation) external ifAdmin {
75: 75:         upgradeImplementation(_implementation);
76: 76:     }
77: 77: 
78: 78:     
79: 79: 
80: 80: 
81: 81: 
82: 82: 
83: 83: 
84: 84: 
85: 85:     function upgradeToAndCall(address _implementation, bytes _data) external payable ifAdmin {
86: 86:         upgradeImplementation(_implementation);
87: 87:         
88: 88:         require(address(this).call.value(msg.value)(_data), "Upgrade error: initialization method call failed");
89: 89:     }
90: 90: 
91: 91:     
92: 92: 
93: 93: 
94: 94: 
95: 95:     function admin() external view ifAdmin returns (address) {
96: 96:         return currentAdmin();
97: 97:     }
98: 98: 
99: 99:     
100: 100: 
101: 101: 
102: 102: 
103: 103:     function upgradeImplementation(address _newImplementation) private {
104: 104:         address currentImplementation = implementation();
105: 105:         require(currentImplementation != _newImplementation, "Upgrade error: proxy contract already uses specified implementation");
106: 106:         setImplementation(_newImplementation);
107: 107:         emit Upgraded(_newImplementation);
108: 108:     }
109: 109: 
110: 110:     
111: 111: 
112: 112: 
113: 113: 
114: 114: 
115: 115: 
116: 116:     function delegate(address _implementation) private {
117: 117:         assembly {
118: 118:             
119: 119:             calldatacopy(0, 0, calldatasize)
120: 120: 
121: 121:             
122: 122:             let result := delegatecall(gas, _implementation, 0, calldatasize, 0, 0)
123: 123: 
124: 124:             
125: 125:             returndatacopy(0, 0, returndatasize)
126: 126: 
127: 127:             
128: 128:             switch result
129: 129:             case 0 {revert(0, returndatasize)}
130: 130:             default {return (0, returndatasize)}
131: 131:         }
132: 132:     }
133: 133: 
134: 134:     
135: 135: 
136: 136: 
137: 137:     function currentAdmin() private view returns (address proxyAdmin) {
138: 138:         bytes32 slot = ADMIN_SLOT;
139: 139:         assembly {
140: 140:             proxyAdmin := sload(slot)
141: 141:         }
142: 142:     }
143: 143: 
144: 144:     
145: 145: 
146: 146: 
147: 147: 
148: 148:     function setAdmin(address _newAdmin) private {
149: 149:         bytes32 slot = ADMIN_SLOT;
150: 150:         assembly {
151: 151:             sstore(slot, _newAdmin)
152: 152:         }
153: 153:     }
154: 154: 
155: 155:     
156: 156: 
157: 157: 
158: 158: 
159: 159:     function setImplementation(address _newImplementation) private {
160: 160:         require(
161: 161:             AddressUtils.isContract(_newImplementation),
162: 162:             "Cannot set new implementation: no contract code at contract address"
163: 163:         );
164: 164:         bytes32 slot = IMPLEMENTATION_SLOT;
165: 165:         assembly {
166: 166:             sstore(slot, _newImplementation)
167: 167:         }
168: 168:     }
169: 169: 
170: 170: }