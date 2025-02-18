1: 
2: 
3: pragma solidity ^0.5.0;
4: 
5: 
6: 
7: 
8: 
9: library Roles {
10:     struct Role {
11:         mapping (address => bool) bearer;
12:     }
13: 
14:     
15: 
16: 
17:     function add(Role storage role, address account) internal {
18:         require(account != address(0));
19:         require(!has(role, account));
20: 
21:         role.bearer[account] = true;
22:     }
23: 
24:     
25: 
26: 
27:     function remove(Role storage role, address account) internal {
28:         require(account != address(0));
29:         require(has(role, account));
30: 
31:         role.bearer[account] = false;
32:     }
33: 
34:     
35: 
36: 
37: 
38:     function has(Role storage role, address account) internal view returns (bool) {
39:         require(account != address(0));
40:         return role.bearer[account];
41:     }
42: }
43: 
44: 
45: 
46: pragma solidity ^0.5.0;
47: 
48: 
49: 
50: 
51: 
52: 
53: contract CustodialContract is WhitelistAdminRole {
54:     HashRegistrar registrar;
55: 
56:     mapping (bytes32 => Ownership) domains;
57: 
58:     struct Ownership {
59:         address primary;
60:         address secondary;
61:     }
62: 
63:     event NewPrimaryOwner(bytes32 indexed labelHash, address indexed owner);
64:     event NewSecondaryOwner(bytes32 indexed labelHash, address indexed owner);
65:     event DomainWithdrawal(bytes32 indexed labelHash, address indexed recipient);
66: 
67:     function() external payable {}
68:     
69:     constructor(address _registrar) public {
70:         registrar = HashRegistrar(_registrar);
71:     }
72: 
73:     modifier onlyOwner(bytes32 _labelHash) {
74:         require(isOwner(_labelHash));
75:         _;
76:     }
77: 
78:     modifier onlyTransferred(bytes32 _labelHash) {
79:         require(isTransferred(_labelHash));
80:         _;
81:     }
82: 
83:     function isTransferred(bytes32 _labelHash) public view returns (bool) {
84:         (, address deedAddress, , , ) = registrar.entries(_labelHash);
85:         Deed deed = Deed(deedAddress);
86: 
87:         return (deed.owner() == address(this));
88:     }
89: 
90:     function isOwner(bytes32 _labelHash) public view returns (bool) {
91:         return (isPrimaryOwner(_labelHash) || isSecondaryOwner(_labelHash));
92:     }
93: 
94:     function isPrimaryOwner(bytes32 _labelHash) public view returns (bool) {
95:         (, address deedAddress, , , ) = registrar.entries(_labelHash);
96:         Deed deed = Deed(deedAddress);
97: 
98:         if (
99:             domains[_labelHash].primary == address(0) &&
100:             deed.previousOwner() == msg.sender
101:         ) {
102:             return true;
103:         }
104:         return (domains[_labelHash].primary == msg.sender);
105:     }
106: 
107:     function isSecondaryOwner(bytes32 _labelHash) public view returns (bool) {
108:         return (domains[_labelHash].secondary == msg.sender);
109:     }
110: 
111:     function setPrimaryOwners(bytes32[] memory _labelHashes, address _address) public {
112:         for (uint i=0; i<_labelHashes.length; i++) {
113:             setPrimaryOwner(_labelHashes[i], _address);
114:         }
115:     }
116: 
117:     function setSecondaryOwners(bytes32[] memory _labelHashes, address _address) public {
118:         for (uint i=0; i<_labelHashes.length; i++) {
119:             setSecondaryOwner(_labelHashes[i], _address);
120:         }
121:     }
122: 
123:     function setPrimaryOwner(bytes32 _labelHash, address _address) public onlyTransferred(_labelHash) onlyOwner(_labelHash) {
124:         domains[_labelHash].primary = _address;
125:         emit NewPrimaryOwner(_labelHash, _address);
126:     }
127: 
128:     function setSecondaryOwner(bytes32 _labelHash, address _address) public onlyTransferred(_labelHash) onlyOwner(_labelHash) {
129:         domains[_labelHash].secondary = _address;
130:         emit NewSecondaryOwner(_labelHash, _address);
131:     }
132: 
133:     function setPrimaryAndSecondaryOwner(bytes32 _labelHash, address _primary, address _secondary) public onlyTransferred(_labelHash) onlyOwner(_labelHash) {
134:         setPrimaryOwner(_labelHash, _primary);
135:         setSecondaryOwner(_labelHash, _secondary);
136:     }
137: 
138:     function withdrawDomain(bytes32 _labelHash, address payable _address) public onlyTransferred(_labelHash) onlyOwner(_labelHash) {
139:         domains[_labelHash].primary = address(0);
140:         domains[_labelHash].secondary = address(0);
141:         registrar.transfer(_labelHash, _address);
142:         emit DomainWithdrawal(_labelHash, _address);
143:     }
144: 
145:     function call(address _to, bytes memory _data) public payable onlyWhitelistAdmin {
146:         require(_to != address(registrar));
147:         (bool success,) = _to.call.value(msg.value)(_data);
148:         require(success);
149:     }
150: }