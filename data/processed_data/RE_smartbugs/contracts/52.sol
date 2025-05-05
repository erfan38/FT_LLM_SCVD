1: 1: contract MultiAsset {
2: 2:     function isCreated(bytes32 _symbol) constant returns(bool);
3: 3:     function owner(bytes32 _symbol) constant returns(address);
4: 4:     function totalSupply(bytes32 _symbol) constant returns(uint);
5: 5:     function balanceOf(address _holder, bytes32 _symbol) constant returns(uint);
6: 6:     function transfer(address _to, uint _value, bytes32 _symbol) returns(bool);
7: 7:     function proxyTransferWithReference(address _to, uint _value, bytes32 _symbol, string _reference) returns(bool);
8: 8:     function proxyTransferToICAPWithReference(bytes32 _icap, uint _value, string _reference) returns(bool);
9: 9:     function proxyApprove(address _spender, uint _value, bytes32 _symbol) returns(bool);
10: 10:     function allowance(address _from, address _spender, bytes32 _symbol) constant returns(uint);
11: 11:     function transferFromWithReference(address _from, address _to, uint _value, bytes32 _symbol, string _reference) returns(bool);
12: 12:     function transferFromToICAPWithReference(address _from, bytes32 _icap, uint _value, string _reference) returns(bool);
13: 13:     function proxyTransferFromWithReference(address _from, address _to, uint _value, bytes32 _symbol, string _reference) returns(bool);
14: 14:     function proxyTransferFromToICAPWithReference(address _from, bytes32 _icap, uint _value, string _reference) returns(bool);
15: 15:     function proxySetCosignerAddress(address _address, bytes32 _symbol) returns(bool);
16: 16: }
17: 17: 
18: 18: contract Safe {
19: 19:     
20: 20:     modifier noValue {
21: 21:         if (msg.value > 0) {
22: 22:             
23: 23:             
24: 24:             
25: 25:             _safeSend(msg.sender, msg.value);
26: 26:         }
27: 27:         _
28: 28:     }
29: 29: 
30: 30:     modifier onlyHuman {
31: 31:         if (_isHuman()) {
32: 32:             _
33: 33:         }
34: 34:     }
35: 35: 
36: 36:     modifier noCallback {
37: 37:         if (!isCall) {
38: 38:             _
39: 39:         }
40: 40:     }
41: 41: 
42: 42:     modifier immutable(address _address) {
43: 43:         if (_address == 0) {
44: 44:             _
45: 45:         }
46: 46:     }
47: 47: 
48: 48:     address stackDepthLib;
49: 49:     function setupStackDepthLib(address _stackDepthLib) immutable(address(stackDepthLib)) returns(bool) {
50: 50:         stackDepthLib = _stackDepthLib;
51: 51:         return true;
52: 52:     }
53: 53: 
54: 54:     modifier requireStackDepth(uint16 _depth) {
55: 55:         if (stackDepthLib == 0x0) {
56: 56:             throw;
57: 57:         }
58: 58:         if (_depth > 1023) {
59: 59:             throw;
60: 60:         }
61: 61:         if (!stackDepthLib.delegatecall(0x32921690, stackDepthLib, _depth)) {
62: 62:             throw;
63: 63:         }
64: 64:         _
65: 65:     }
66: 66: 
67: 67:     
68: 68:     function _safeFalse() internal noValue() returns(bool) {
69: 69:         return false;
70: 70:     }
71: 71: 
72: 72:     function _safeSend(address _to, uint _value) internal {
73: 73:         if (!_unsafeSend(_to, _value)) {
74: 74:             throw;
75: 75:         }
76: 76:     }
77: 77: 
78: 78:     function _unsafeSend(address _to, uint _value) internal returns(bool) {
79: 79:         return _to.call.value(_value)();
80: 80:     }
81: 81: 
82: 82:     function _isContract() constant internal returns(bool) {
83: 83:         return msg.sender != tx.origin;
84: 84:     }
85: 85: 
86: 86:     function _isHuman() constant internal returns(bool) {
87: 87:         return !_isContract();
88: 88:     }
89: 89: 
90: 90:     bool private isCall = false;
91: 91:     function _setupNoCallback() internal {
92: 92:         isCall = true;
93: 93:     }
94: 94: 
95: 95:     function _finishNoCallback() internal {
96: 96:         isCall = false;
97: 97:     }
98: 98: }
99: 99: 