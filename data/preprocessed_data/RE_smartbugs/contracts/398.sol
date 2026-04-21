1: 1: pragma solidity ^0.4.24;
2: 2: 
3: 3: 
4: 4: 
5: 5: 
6: 6: 
7: 7: 
8: 8: contract BaseWallet {
9: 9: 
10: 10:     
11: 11:     address public implementation;
12: 12:     
13: 13:     address public owner;
14: 14:     
15: 15:     mapping (address => bool) public authorised;
16: 16:     
17: 17:     mapping (bytes4 => address) public enabled;
18: 18:     
19: 19:     uint public modules;
20: 20:     
21: 21:     event AuthorisedModule(address indexed module, bool value);
22: 22:     event EnabledStaticCall(address indexed module, bytes4 indexed method);
23: 23:     event Invoked(address indexed module, address indexed target, uint indexed value, bytes data);
24: 24:     event Received(uint indexed value, address indexed sender, bytes data);
25: 25:     event OwnerChanged(address owner);
26: 26:     
27: 27:     
28: 28: 
29: 29: 
30: 30:     modifier moduleOnly {
31: 31:         require(authorised[msg.sender], "BW: msg.sender not an authorized module");
32: 32:         _;
33: 33:     }
34: 34: 
35: 35:     
36: 36: 
37: 37: 
38: 38: 
39: 39: 
40: 40:     function init(address _owner, address[] _modules) external {
41: 41:         require(owner == address(0) && modules == 0, "BW: wallet already initialised");
42: 42:         require(_modules.length > 0, "BW: construction requires at least 1 module");
43: 43:         owner = _owner;
44: 44:         modules = _modules.length;
45: 45:         for(uint256 i = 0; i < _modules.length; i++) {
46: 46:             require(authorised[_modules[i]] == false, "BW: module is already added");
47: 47:             authorised[_modules[i]] = true;
48: 48:             Module(_modules[i]).init(this);
49: 49:             emit AuthorisedModule(_modules[i], true);
50: 50:         }
51: 51:     }
52: 52:     
53: 53:     
54: 54: 
55: 55: 
56: 56: 
57: 57: 
58: 58:     function authoriseModule(address _module, bool _value) external moduleOnly {
59: 59:         if (authorised[_module] != _value) {
60: 60:             if(_value == true) {
61: 61:                 modules += 1;
62: 62:                 authorised[_module] = true;
63: 63:                 Module(_module).init(this);
64: 64:             }
65: 65:             else {
66: 66:                 modules -= 1;
67: 67:                 require(modules > 0, "BW: wallet must have at least one module");
68: 68:                 delete authorised[_module];
69: 69:             }
70: 70:             emit AuthorisedModule(_module, _value);
71: 71:         }
72: 72:     }
73: 73: 
74: 74:     
75: 75: 
76: 76: 
77: 77: 
78: 78: 
79: 79: 
80: 80:     function enableStaticCall(address _module, bytes4 _method) external moduleOnly {
81: 81:         require(authorised[_module], "BW: must be an authorised module for static call");
82: 82:         enabled[_method] = _module;
83: 83:         emit EnabledStaticCall(_module, _method);
84: 84:     }
85: 85: 
86: 86:     
87: 87: 
88: 88: 
89: 89: 
90: 90:     function setOwner(address _newOwner) external moduleOnly {
91: 91:         require(_newOwner != address(0), "BW: address cannot be null");
92: 92:         owner = _newOwner;
93: 93:         emit OwnerChanged(_newOwner);
94: 94:     }
95: 95:     
96: 96:     
97: 97: 
98: 98: 
99: 99: 
100: 100: 
101: 101: 
102: 102:     function invoke(address _target, uint _value, bytes _data) external moduleOnly {
103: 103:         
104: 104:         require(_target.call.value(_value)(_data), "BW: call to target failed");
105: 105:         emit Invoked(msg.sender, _target, _value, _data);
106: 106:     }
107: 107: 
108: 108:     
109: 109: 
110: 110: 
111: 111: 
112: 112: 
113: 113:     function() public payable {
114: 114:         if(msg.data.length > 0) { 
115: 115:             address module = enabled[msg.sig];
116: 116:             if(module == address(0)) {
117: 117:                 emit Received(msg.value, msg.sender, msg.data);
118: 118:             } 
119: 119:             else {
120: 120:                 require(authorised[module], "BW: must be an authorised module for static call");
121: 121:                 
122: 122:                 assembly {
123: 123:                     calldatacopy(0, 0, calldatasize())
124: 124:                     let result := staticcall(gas, module, 0, calldatasize(), 0, 0)
125: 125:                     returndatacopy(0, 0, returndatasize())
126: 126:                     switch result 
127: 127:                     case 0 {revert(0, returndatasize())} 
128: 128:                     default {return (0, returndatasize())}
129: 129:                 }
130: 130:             }
131: 131:         }
132: 132:     }
133: 133: }
134: 134: 
135: 135: 
136: 136: 
137: 137: 