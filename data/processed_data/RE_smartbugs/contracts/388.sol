1: 1: pragma solidity ^0.4.18;
2: 2: 
3: 3: contract NeuroSale is Owned {
4: 4:     using SafeMath for uint;
5: 5: 
6: 6:     mapping(address => uint) public totalSpentEth;
7: 7:     mapping(address => uint) public totalTokensWithoutBonuses;
8: 8:     mapping(address => uint) public volumeBonusesTokens;
9: 9: 
10: 10:     uint public constant TOKEN_PRICE = 0.001 ether;
11: 11:     uint public constant MULTIPLIER = uint(10) ** uint(18);
12: 12:     uint public salesStart;
13: 13:     uint public salesDeadline;
14: 14:     Token public token;
15: 15:     address public wallet;
16: 16:     bool public salePaused;
17: 17: 
18: 18:     event LogBought(address indexed receiver, uint contribution, uint reward, uint128 customerId);
19: 19:     event LogPaused(bool isPaused);
20: 20:     event LogWalletUpdated(address to);
21: 21: 
22: 22:     modifier notPaused() {
23: 23:         require(!salePaused);
24: 24:         _;
25: 25:     }
26: 26: 
27: 27:     
28: 28:     function init(Token _token, address _wallet, uint _start, uint _deadline) onlyContractOwner() public returns(bool) {
29: 29:         require(address(token) == 0);
30: 30:         require(_wallet != 0);
31: 31:         token = _token;
32: 32:         wallet = _wallet;
33: 33:         salesStart = _start;
34: 34:         salesDeadline = _deadline;
35: 35:         return true;
36: 36:     }
37: 37: 
38: 38:     function setSalePause(bool _value) onlyContractOwner() public returns(bool) {
39: 39:         salePaused = _value;
40: 40:         LogPaused(_value);
41: 41:         return true;
42: 42:     }
43: 43: 
44: 44:     function setWallet(address _wallet) onlyContractOwner() public returns(bool) {
45: 45:         require(_wallet != 0);
46: 46:         wallet = _wallet;
47: 47:         LogWalletUpdated(_wallet);
48: 48:         return true;
49: 49:     }
50: 50: 
51: 51:     function transferOwnership() onlyContractOwner() public returns(bool) {
52: 52:         token.transferOwnership(contractOwner);
53: 53:         return true;
54: 54:     }
55: 55: 
56: 56:     function burnUnsold() onlyContractOwner() public returns(bool) {
57: 57:         uint tokensToBurn = token.balanceOf(address(this));
58: 58:         token.burn(tokensToBurn);
59: 59:         return true;
60: 60:     }
61: 61: 
62: 62:     function buy() payable notPaused() public returns(bool) {
63: 63:         require(now >= salesStart);
64: 64:         require(now < salesDeadline);
65: 65: 
66: 66:         
67: 67:         
68: 68:         uint tokensToBuy = msg.value * MULTIPLIER / TOKEN_PRICE;
69: 69:         require(tokensToBuy > 0);
70: 70:         uint timeBonus = _calculateTimeBonus(tokensToBuy, now);
71: 71:         uint volumeBonus = _calculateVolumeBonus(tokensToBuy, msg.sender, msg.value);
72: 72:         
73: 73:         uint totalTokensToTransfer = tokensToBuy + timeBonus + volumeBonus;
74: 74:         require(token.transfer(msg.sender, totalTokensToTransfer));
75: 75:         LogBought(msg.sender, msg.value, totalTokensToTransfer, 0);
76: 76:         
77: 77:         require(wallet.call.value(msg.value)());
78: 78:         return true;
79: 79:     }
80: 80: 
81: 81:     function buyWithCustomerId(address _beneficiary, uint _value, uint _amount, uint128 _customerId, uint _date, bool _autobonus) onlyContractOwner() public returns(bool) {
82: 82:         uint totalTokensToTransfer;
83: 83:         uint volumeBonus;
84: 84: 
85: 85:         if (_autobonus) {
86: 86:             uint tokensToBuy = _value.mul(MULTIPLIER).div(TOKEN_PRICE);
87: 87:             require(tokensToBuy > 0);
88: 88:             uint timeBonus = _calculateTimeBonus(tokensToBuy, _date);
89: 89:             volumeBonus = _calculateVolumeBonus(tokensToBuy, _beneficiary, _value);
90: 90:             
91: 91:             totalTokensToTransfer = tokensToBuy.add(timeBonus).add(volumeBonus);
92: 92:         } else {
93: 93:             totalTokensToTransfer = _amount;
94: 94:         }
95: 95: 
96: 96:         require(token.transfer(_beneficiary, totalTokensToTransfer));
97: 97:         LogBought(_beneficiary, _value, totalTokensToTransfer, _customerId);
98: 98:         return true;
99: 99:     }
100: 100: 
101: 101:     function _calculateTimeBonus(uint _value, uint _date) view internal returns(uint) {
102: 102:         
103: 103:         if (_date < salesStart) {
104: 104:             return 0;
105: 105:         }
106: 106:         
107: 107:         if (_date < salesStart + 1 weeks) {
108: 108:             return _value.mul(150).div(1000);
109: 109:         }
110: 110:         
111: 111:         if (_date < salesStart + 2 weeks) {
112: 112:             return _value.mul(100).div(1000);
113: 113:         }
114: 114:         
115: 115:         if (_date < salesStart + 3 weeks) {
116: 116:             return _value.mul(70).div(1000);
117: 117:         }
118: 118:         
119: 119:         if (_date < salesStart + 4 weeks) {
120: 120:             return _value.mul(40).div(1000);
121: 121:         }
122: 122:         
123: 123:         if (_date < salesStart + 5 weeks) {
124: 124:             return _value.mul(20).div(1000);
125: 125:         }
126: 126:         
127: 127:         if (_date < salesDeadline) {
128: 128:             return _value.mul(10).div(1000);
129: 129:         }
130: 130: 
131: 131:         return 0;
132: 132:     }
133: 133: 
134: 134:     function _calculateVolumeBonus(uint _amount, address _receiver, uint _value) internal returns(uint) {
135: 135:         
136: 136:         uint totalCollected = totalTokensWithoutBonuses[_receiver].add(_amount);
137: 137:         uint totalEth = totalSpentEth[_receiver].add(_value);
138: 138:         uint totalBonus;
139: 139: 
140: 140:         if (totalEth < 30 ether) {
141: 141:             totalBonus = 0;
142: 142:         } else if (totalEth < 50 ether) {
143: 143:             totalBonus = totalCollected.mul(10).div(1000);
144: 144:         } else if (totalEth < 100 ether) {
145: 145:             totalBonus = totalCollected.mul(25).div(1000);
146: 146:         } else if (totalEth < 300 ether) {
147: 147:             totalBonus = totalCollected.mul(50).div(1000);
148: 148:         } else if (totalEth < 500 ether) {
149: 149:             totalBonus = totalCollected.mul(80).div(1000);
150: 150:         } else if (totalEth < 1000 ether) {
151: 151:             totalBonus = totalCollected.mul(150).div(1000);
152: 152:         } else if (totalEth < 2000 ether) {
153: 153:             totalBonus = totalCollected.mul(200).div(1000);
154: 154:         } else if (totalEth < 3000 ether) {
155: 155:             totalBonus = totalCollected.mul(300).div(1000);
156: 156:         } else if (totalEth >= 3000 ether) {
157: 157:             totalBonus = totalCollected.mul(400).div(1000);
158: 158:         }
159: 159: 
160: 160:         
161: 161:         uint bonusToPay = totalBonus - volumeBonusesTokens[_receiver];
162: 162:         volumeBonusesTokens[_receiver] = totalBonus;
163: 163: 
164: 164:         totalSpentEth[_receiver] = totalEth;
165: 165:         totalTokensWithoutBonuses[_receiver] = totalCollected;
166: 166:         return bonusToPay;
167: 167:     }
168: 168: 
169: 169:     function () payable public {
170: 170:         buy();
171: 171:     }
172: 172: 
173: 173:     
174: 174:     function recoverTokens(Token _token, uint _amount) onlyContractOwner() public returns(bool) {
175: 175:         return _token.transfer(contractOwner, _amount);
176: 176:     }
177: 177: }