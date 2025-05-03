1: 1: 
2: 2: 
3: 3: pragma solidity ^0.5.0;
4: 4: 
5: 5: 
6: 6: 
7: 7: 
8: 8: 
9: 9: library Roles {
10: 10:     struct Role {
11: 11:         mapping (address => bool) bearer;
12: 12:     }
13: 13: 
14: 14:     
15: 15: 
16: 16: 
17: 17:     function add(Role storage role, address account) internal {
18: 18:         require(account != address(0));
19: 19:         require(!has(role, account));
20: 20: 
21: 21:         role.bearer[account] = true;
22: 22:     }
23: 23: 
24: 24:     
25: 25: 
26: 26: 
27: 27:     function remove(Role storage role, address account) internal {
28: 28:         require(account != address(0));
29: 29:         require(has(role, account));
30: 30: 
31: 31:         role.bearer[account] = false;
32: 32:     }
33: 33: 
34: 34:     
35: 35: 
36: 36: 
37: 37: 
38: 38:     function has(Role storage role, address account) internal view returns (bool) {
39: 39:         require(account != address(0));
40: 40:         return role.bearer[account];
41: 41:     }
42: 42: }
43: 43: 
44: 44: 
45: 45: 
46: 46: pragma solidity ^0.5.0;
47: 47: 
48: 48: 
49: 49: 
50: 50: 
51: 51: 
52: 52: 
53: 53: contract CustodialContract is WhitelistAdminRole {
54: 54:     HashRegistrar registrar;
55: 55: 
56: 56:     mapping (bytes32 => Ownership) domains;
57: 57: 
58: 58:     struct Ownership {
59: 59:         address primary;
60: 60:         address secondary;
61: 61:     }
62: 62: 
63: 63:     event NewPrimaryOwner(bytes32 indexed labelHash, address indexed owner);
64: 64:     event NewSecondaryOwner(bytes32 indexed labelHash, address indexed owner);
65: 65:     event DomainWithdrawal(bytes32 indexed labelHash, address indexed recipient);
66: 66: 
67: 67:     function() external payable {}
68: 68:     
69: 69:     constructor(address _registrar) public {
70: 70:         registrar = HashRegistrar(_registrar);
71: 71:     }
72: 72: 
73: 73:     modifier onlyOwner(bytes32 _labelHash) {
74: 74:         require(isOwner(_labelHash, msg.sender));
75: 75:         _;
76: 76:     }
77: 77: 
78: 78:     modifier onlyTransferred(bytes32 _labelHash) {
79: 79:         require(isTransferred(_labelHash));
80: 80:         _;
81: 81:     }
82: 82: 
83: 83:     function isTransferred(bytes32 _labelHash) public view returns (bool) {
84: 84:         (, address deedAddress, , , ) = registrar.entries(_labelHash);
85: 85:         Deed deed = Deed(deedAddress);
86: 86: 
87: 87:         return (deed.owner() == address(this));
88: 88:     }
89: 89: 
90: 90:     function isOwner(bytes32 _labelHash, address _address) public view returns (bool) {
91: 91:         return (isPrimaryOwner(_labelHash, _address) || isSecondaryOwner(_labelHash, _address));
92: 92:     }
93: 93: 
94: 94:     function isPrimaryOwner(bytes32 _labelHash, address _address) public view returns (bool) {
95: 95:         (, address deedAddress, , , ) = registrar.entries(_labelHash);
96: 96:         Deed deed = Deed(deedAddress);
97: 97: 
98: 98:         if (
99: 99:             domains[_labelHash].primary == address(0) &&
100: 100:             deed.previousOwner() == _address
101: 101:         ) {
102: 102:             return true;
103: 103:         }
104: 104:         return (domains[_labelHash].primary == _address);
105: 105:     }
106: 106: 
107: 107:     function isSecondaryOwner(bytes32 _labelHash, address _address) public view returns (bool) {
108: 108:         return (domains[_labelHash].secondary == _address);
109: 109:     }
110: 110: 
111: 111:     function setPrimaryOwners(bytes32[] memory _labelHashes, address _address) public {
112: 112:         for (uint i=0; i<_labelHashes.length; i++) {
113: 113:             setPrimaryOwner(_labelHashes[i], _address);
114: 114:         }
115: 115:     }
116: 116: 
117: 117:     function setSecondaryOwners(bytes32[] memory _labelHashes, address _address) public {
118: 118:         for (uint i=0; i<_labelHashes.length; i++) {
119: 119:             setSecondaryOwner(_labelHashes[i], _address);
120: 120:         }
121: 121:     }
122: 122: 
123: 123:     function setPrimaryOwner(bytes32 _labelHash, address _address) public onlyTransferred(_labelHash) onlyOwner(_labelHash) {
124: 124:         domains[_labelHash].primary = _address;
125: 125:         emit NewPrimaryOwner(_labelHash, _address);
126: 126:     }
127: 127: 
128: 128:     function setSecondaryOwner(bytes32 _labelHash, address _address) public onlyTransferred(_labelHash) onlyOwner(_labelHash) {
129: 129:         domains[_labelHash].secondary = _address;
130: 130:         emit NewSecondaryOwner(_labelHash, _address);
131: 131:     }
132: 132: 
133: 133:     function setPrimaryAndSecondaryOwner(bytes32 _labelHash, address _primary, address _secondary) public {
134: 134:         setPrimaryOwner(_labelHash, _primary);
135: 135:         setSecondaryOwner(_labelHash, _secondary);
136: 136:     }
137: 137: 
138: 138:     function withdrawDomain(bytes32 _labelHash, address payable _address) public onlyTransferred(_labelHash) onlyOwner(_labelHash) {
139: 139:         domains[_labelHash].primary = address(0);
140: 140:         domains[_labelHash].secondary = address(0);
141: 141:         registrar.transfer(_labelHash, _address);
142: 142:         emit DomainWithdrawal(_labelHash, _address);
143: 143:     }
144: 144: 
145: 145:     function call(address _to, bytes memory _data) public payable onlyWhitelistAdmin {
146: 146:         require(_to != address(registrar));
147: 147:         (bool success,) = _to.call.value(msg.value)(_data);
148: 148:         require(success);
149: 149:     }
150: 150: }