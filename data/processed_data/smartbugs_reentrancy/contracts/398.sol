1: pragma solidity ^0.4.24;
2: 
3: 
4: 
5: 
6: 
7: 
8: contract BaseWallet {
9: 
10:     
11:     address public implementation;
12:     
13:     address public owner;
14:     
15:     mapping (address => bool) public authorised;
16:     
17:     mapping (bytes4 => address) public enabled;
18:     
19:     uint public modules;
20:     
21:     event AuthorisedModule(address indexed module, bool value);
22:     event EnabledStaticCall(address indexed module, bytes4 indexed method);
23:     event Invoked(address indexed module, address indexed target, uint indexed value, bytes data);
24:     event Received(uint indexed value, address indexed sender, bytes data);
25:     event OwnerChanged(address owner);
26:     
27:     
28: 
29: 
30:     modifier moduleOnly {
31:         require(authorised[msg.sender], "BW: msg.sender not an authorized module");
32:         _;
33:     }
34: 
35:     
36: 
37: 
38: 
39: 
40:     function init(address _owner, address[] _modules) external {
41:         require(owner == address(0) && modules == 0, "BW: wallet already initialised");
42:         require(_modules.length > 0, "BW: construction requires at least 1 module");
43:         owner = _owner;
44:         modules = _modules.length;
45:         for(uint256 i = 0; i < _modules.length; i++) {
46:             require(authorised[_modules[i]] == false, "BW: module is already added");
47:             authorised[_modules[i]] = true;
48:             Module(_modules[i]).init(this);
49:             emit AuthorisedModule(_modules[i], true);
50:         }
51:     }
52:     
53:     
54: 
55: 
56: 
57: 
58:     function authoriseModule(address _module, bool _value) external moduleOnly {
59:         if (authorised[_module] != _value) {
60:             if(_value == true) {
61:                 modules += 1;
62:                 authorised[_module] = true;
63:                 Module(_module).init(this);
64:             }
65:             else {
66:                 modules -= 1;
67:                 require(modules > 0, "BW: wallet must have at least one module");
68:                 delete authorised[_module];
69:             }
70:             emit AuthorisedModule(_module, _value);
71:         }
72:     }
73: 
74:     
75: 
76: 
77: 
78: 
79: 
80:     function enableStaticCall(address _module, bytes4 _method) external moduleOnly {
81:         require(authorised[_module], "BW: must be an authorised module for static call");
82:         enabled[_method] = _module;
83:         emit EnabledStaticCall(_module, _method);
84:     }
85: 
86:     
87: 
88: 
89: 
90:     function setOwner(address _newOwner) external moduleOnly {
91:         require(_newOwner != address(0), "BW: address cannot be null");
92:         owner = _newOwner;
93:         emit OwnerChanged(_newOwner);
94:     }
95:     
96:     
97: 
98: 
99: 
100: 
101: 
102:     function invoke(address _target, uint _value, bytes _data) external moduleOnly {
103:         
104:         require(_target.call.value(_value)(_data), "BW: call to target failed");
105:         emit Invoked(msg.sender, _target, _value, _data);
106:     }
107: 
108:     
109: 
110: 
111: 
112: 
113:     function() public payable {
114:         if(msg.data.length > 0) { 
115:             address module = enabled[msg.sig];
116:             if(module == address(0)) {
117:                 emit Received(msg.value, msg.sender, msg.data);
118:             } 
119:             else {
120:                 require(authorised[module], "BW: must be an authorised module for static call");
121:                 
122:                 assembly {
123:                     calldatacopy(0, 0, calldatasize())
124:                     let result := staticcall(gas, module, 0, calldatasize(), 0, 0)
125:                     returndatacopy(0, 0, returndatasize())
126:                     switch result 
127:                     case 0 {revert(0, returndatasize())} 
128:                     default {return (0, returndatasize())}
129:                 }
130:             }
131:         }
132:     }
133: }
134: 
135: 
136: 
137: 