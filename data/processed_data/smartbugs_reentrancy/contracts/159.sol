1: 1: 1: 1: 1: contract owned {
2: 2: 2: 2: 2:     function owned() {
3: 3: 3: 3: 3:         owner = msg.sender;
4: 4: 4: 4: 4:     }
5: 5: 5: 5: 5: 
6: 6: 6: 6: 6:     address public owner;
7: 7: 7: 7: 7: 
8: 8: 8: 8: 8:     modifier onlyowner { if (msg.sender != owner) throw; _ }
9: 9: 9: 9: 9: 
10: 10: 10: 10: 10:     event OwnershipTransfer(address indexed from, address indexed to);
11: 11: 11: 11: 11: 
12: 12: 12: 12: 12:     function transferOwnership(address to) public onlyowner {
13: 13: 13: 13: 13:         owner = to;
14: 14: 14: 14: 14:         OwnershipTransfer(msg.sender, to);
15: 15: 15: 15: 15:     }
16: 16: 16: 16: 16: }
17: 17: 17: 17: 17: 
18: 18: 18: 18: 18: 
19: 19: 19: 19: 19: contract Order is owned {
20: 20: 20: 20: 20:     ERC20 public token;
21: 21: 21: 21: 21:     uint public weiPerToken;
22: 22: 22: 22: 22:     uint public decimalPlaces;
23: 23: 23: 23: 23: 
24: 24: 24: 24: 24:     function Order(address _token, uint _weiPerToken, uint _decimalPlaces) {
25: 25: 25: 25: 25:         token = ERC20(_token);
26: 26: 26: 26: 26:         weiPerToken = _weiPerToken;
27: 27: 27: 27: 27:         decimalPlaces = _decimalPlaces;
28: 28: 28: 28: 28:     }
29: 29: 29: 29: 29: 
30: 30: 30: 30: 30:     function sendRobust(address to, uint value) internal {
31: 31: 31: 31: 31:         if (!to.send(value)) {
32: 32: 32: 32: 32:             if (!to.call.value(value)()) throw;
33: 33: 33: 33: 33:         }
34: 34: 34: 34: 34:     }
35: 35: 35: 35: 35: 
36: 36: 36: 36: 36:     function min(uint a, uint b) internal returns (uint) {
37: 37: 37: 37: 37:         if (a <= b) {
38: 38: 38: 38: 38:             return a;
39: 39: 39: 39: 39:         } else {
40: 40: 40: 40: 40:             return b;
41: 41: 41: 41: 41:         }
42: 42: 42: 42: 42:     }
43: 43: 43: 43: 43: 
44: 44: 44: 44: 44:     function getTransferableBalance(address who) internal returns (uint amount) {
45: 45: 45: 45: 45:         uint allowance = token.allowance(msg.sender, address(this));
46: 46: 46: 46: 46:         uint balance = token.balanceOf(msg.sender);
47: 47: 47: 47: 47: 
48: 48: 48: 48: 48:         amount = min(min(allowance, balance), numTokensAbleToPurchase());
49: 49: 49: 49: 49: 
50: 50: 50: 50: 50:         return amount;
51: 51: 51: 51: 51:     }
52: 52: 52: 52: 52: 
53: 53: 53: 53: 53:     function numTokensAbleToPurchase() constant returns (uint) {
54: 54: 54: 54: 54:         return (this.balance / weiPerToken) * decimalPlaces;
55: 55: 55: 55: 55:     }
56: 56: 56: 56: 56: 
57: 57: 57: 57: 57:     event OrderFilled(address _from, uint numTokens);
58: 58: 58: 58: 58: 
59: 59: 59: 59: 59:     
60: 60: 60: 60: 60:     function _fillOrder(address _from, uint numTokens) internal returns (bool) {
61: 61: 61: 61: 61:         if (numTokens == 0) throw;
62: 62: 62: 62: 62:         if (this.balance < numTokens * weiPerToken / decimalPlaces) throw;
63: 63: 63: 63: 63: 
64: 64: 64: 64: 64:         if (!token.transferFrom(_from, owner, numTokens)) return false;
65: 65: 65: 65: 65:         sendRobust(_from, numTokens * weiPerToken / decimalPlaces);
66: 66: 66: 66: 66:         OrderFilled(_from, numTokens);
67: 67: 67: 67: 67:         return true;
68: 68: 68: 68: 68:     }
69: 69: 69: 69: 69: 
70: 70: 70: 70: 70:     function fillOrder(address _from, uint numTokens) public returns (bool) {
71: 71: 71: 71: 71:         return _fillOrder(_from, numTokens);
72: 72: 72: 72: 72:     }
73: 73: 73: 73: 73: 
74: 74: 74: 74: 74:     
75: 75: 75: 75: 75:     function fillMyOrder(uint numTokens) public returns (bool) {
76: 76: 76: 76: 76:         return _fillOrder(msg.sender, numTokens);
77: 77: 77: 77: 77:     }
78: 78: 78: 78: 78: 
79: 79: 79: 79: 79:     
80: 80: 80: 80: 80:     function fillTheirOrder(address who) public returns (bool) {
81: 81: 81: 81: 81:         return _fillOrder(who, getTransferableBalance(who));
82: 82: 82: 82: 82:     }
83: 83: 83: 83: 83: 
84: 84: 84: 84: 84:     
85: 85: 85: 85: 85:     
86: 86: 86: 86: 86:     function fillOrderAuto() public returns (bool) {
87: 87: 87: 87: 87:         return _fillOrder(msg.sender, getTransferableBalance(msg.sender));
88: 88: 88: 88: 88:     }
89: 89: 89: 89: 89: 
90: 90: 90: 90: 90:     
91: 91: 91: 91: 91:     function () {
92: 92: 92: 92: 92:         
93: 93: 93: 93: 93:         if (msg.value > 0) {
94: 94: 94: 94: 94:             return;
95: 95: 95: 95: 95:         } else {
96: 96: 96: 96: 96:             fillOrderAuto();
97: 97: 97: 97: 97:         }
98: 98: 98: 98: 98:     }
99: 99: 99: 99: 99: 
100: 100: 100: 100: 100:     
101: 101: 101: 101: 101:     function cancel() onlyowner {
102: 102: 102: 102: 102:         selfdestruct(owner);
103: 103: 103: 103: 103:     }
104: 104: 104: 104: 104: }