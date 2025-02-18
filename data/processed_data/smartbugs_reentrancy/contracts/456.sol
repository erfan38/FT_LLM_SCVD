1: 1: 
2: 2: 
3: 3: 
4: 4: 
5: 5: contract Safe {
6: 6:     
7: 7:     modifier noValue {
8: 8:         if (msg.value > 0) {
9: 9:             
10: 10:             
11: 11:             
12: 12:             _safeSend(msg.sender, msg.value);
13: 13:         }
14: 14:         _
15: 15:     }
16: 16: 
17: 17:     modifier onlyHuman {
18: 18:         if (_isHuman()) {
19: 19:             _
20: 20:         }
21: 21:     }
22: 22: 
23: 23:     modifier noCallback {
24: 24:         if (!isCall) {
25: 25:             _
26: 26:         }
27: 27:     }
28: 28: 
29: 29:     modifier immutable(address _address) {
30: 30:         if (_address == 0) {
31: 31:             _
32: 32:         }
33: 33:     }
34: 34: 
35: 35:     address stackDepthLib;
36: 36:     function setupStackDepthLib(address _stackDepthLib) immutable(address(stackDepthLib)) returns(bool) {
37: 37:         stackDepthLib = _stackDepthLib;
38: 38:         return true;
39: 39:     }
40: 40: 
41: 41:     modifier requireStackDepth(uint16 _depth) {
42: 42:         if (stackDepthLib == 0x0) {
43: 43:             throw;
44: 44:         }
45: 45:         if (_depth > 1023) {
46: 46:             throw;
47: 47:         }
48: 48:         if (!stackDepthLib.delegatecall(0x32921690, stackDepthLib, _depth)) {
49: 49:             throw;
50: 50:         }
51: 51:         _
52: 52:     }
53: 53: 
54: 54:     
55: 55:     function _safeFalse() internal noValue() returns(bool) {
56: 56:         return false;
57: 57:     }
58: 58: 
59: 59:     function _safeSend(address _to, uint _value) internal {
60: 60:         if (!_unsafeSend(_to, _value)) {
61: 61:             throw;
62: 62:         }
63: 63:     }
64: 64: 
65: 65:     function _unsafeSend(address _to, uint _value) internal returns(bool) {
66: 66:         return _to.call.value(_value)();
67: 67:     }
68: 68: 
69: 69:     function _isContract() constant internal returns(bool) {
70: 70:         return msg.sender != tx.origin;
71: 71:     }
72: 72: 
73: 73:     function _isHuman() constant internal returns(bool) {
74: 74:         return !_isContract();
75: 75:     }
76: 76: 
77: 77:     bool private isCall = false;
78: 78:     function _setupNoCallback() internal {
79: 79:         isCall = true;
80: 80:     }
81: 81: 
82: 82:     function _finishNoCallback() internal {
83: 83:         isCall = false;
84: 84:     }
85: 85: }
86: 86: 