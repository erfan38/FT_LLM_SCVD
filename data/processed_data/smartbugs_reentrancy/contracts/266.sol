1: 1: 1: 1: 1: pragma solidity 0.5.4;
2: 2: 2: 2: 2: 
3: 3: 3: 3: 3: 
4: 4: 4: 4: 4: 
5: 5: 5: 5: 5: 
6: 6: 6: 6: 6: 
7: 7: 7: 7: 7: 
8: 8: 8: 8: 8: contract OTCDesk is Ownable, ReentrancyGuard {
9: 9: 9: 9: 9:     using SafeMath for uint256;
10: 10: 10: 10: 10: 
11: 11: 11: 11: 11:     uint8 constant public version = 1;
12: 12: 12: 12: 12: 
13: 13: 13: 13: 13:     address public beneficiary = msg.sender;
14: 14: 14: 14: 14:     address public arbitrationManager = msg.sender;
15: 15: 15: 15: 15: 
16: 16: 16: 16: 16:     uint256 public confidealFund;
17: 17: 17: 17: 17: 
18: 18: 18: 18: 18:     uint256 public closeoutCredit = 0.0017 ether;
19: 19: 19: 19: 19: 
20: 20: 20: 20: 20:     address[] public arbitratorsPool;
21: 21: 21: 21: 21: 
22: 22: 22: 22: 22:     mapping(address => address) public arbitrators; 
23: 23: 23: 23: 23: 
24: 24: 24: 24: 24:     event DealCreation(address deal);
25: 25: 25: 25: 25:     event FeePayment(address deal, uint256 amount);
26: 26: 26: 26: 26:     event CloseoutCreditIssuance(address deal, uint256 amount);
27: 27: 27: 27: 27:     event CloseoutCreditCollection(address deal, uint256 amount);
28: 28: 28: 28: 28:     event ArbitratorAssignment(address deal, address arbitrator);
29: 29: 29: 29: 29: 
30: 30: 30: 30: 30:     function newDeal(
31: 31: 31: 31: 31:         bytes32 _dataHash,
32: 32: 32: 32: 32:         address payable _buyer,
33: 33: 33: 33: 33:         address _sellerPartner,
34: 34: 34: 34: 34:         address _buyerPartner,
35: 35: 35: 35: 35:         uint256 _price,
36: 36: 36: 36: 36:         uint32 _paymentWindow,
37: 37: 37: 37: 37:         bool _buyerIsTaker
38: 38: 38: 38: 38:     )
39: 39: 39: 39: 39:     public
40: 40: 40: 40: 40:     payable
41: 41: 41: 41: 41:     {
42: 42: 42: 42: 42:         OTCDeal _deal = (new OTCDeal).value(msg.value)(
43: 43: 43: 43: 43:             _dataHash,
44: 44: 44: 44: 44:             msg.sender,
45: 45: 45: 45: 45:             _buyer,
46: 46: 46: 46: 46:             _sellerPartner,
47: 47: 47: 47: 47:             _buyerPartner,
48: 48: 48: 48: 48:             _price,
49: 49: 49: 49: 49:             _paymentWindow,
50: 50: 50: 50: 50:             _buyerIsTaker
51: 51: 51: 51: 51:         );
52: 52: 52: 52: 52: 
53: 53: 53: 53: 53:         emit DealCreation(address(_deal));
54: 54: 54: 54: 54: 
55: 55: 55: 55: 55:         if (_buyer.balance < closeoutCredit) {
56: 56: 56: 56: 56:             uint256 _closeoutCredit = closeoutCredit.sub(_buyer.balance);
57: 57: 57: 57: 57:             if (confidealFund >= _closeoutCredit) {
58: 58: 58: 58: 58:                 confidealFund = confidealFund.sub(_closeoutCredit);
59: 59: 59: 59: 59:                 _deal.transferCloseoutCredit.value(_closeoutCredit)();
60: 60: 60: 60: 60:                 emit CloseoutCreditIssuance(address(_deal), _closeoutCredit);
61: 61: 61: 61: 61:             }
62: 62: 62: 62: 62:         }
63: 63: 63: 63: 63:     }
64: 64: 64: 64: 64: 
65: 65: 65: 65: 65:     function setBeneficiary(address _beneficiary)
66: 66: 66: 66: 66:     external
67: 67: 67: 67: 67:     onlyOwner
68: 68: 68: 68: 68:     {
69: 69: 69: 69: 69:         beneficiary = _beneficiary;
70: 70: 70: 70: 70:     }
71: 71: 71: 71: 71: 
72: 72: 72: 72: 72:     function setArbitrationManager(address _arbitrationManager)
73: 73: 73: 73: 73:     external
74: 74: 74: 74: 74:     onlyOwner
75: 75: 75: 75: 75:     {
76: 76: 76: 76: 76:         arbitrationManager = _arbitrationManager;
77: 77: 77: 77: 77:     }
78: 78: 78: 78: 78: 
79: 79: 79: 79: 79:     function setCloseoutCredit(uint256 _closeoutCredit)
80: 80: 80: 80: 80:     external
81: 81: 81: 81: 81:     onlyOwner
82: 82: 82: 82: 82:     {
83: 83: 83: 83: 83:         closeoutCredit = _closeoutCredit;
84: 84: 84: 84: 84:     }
85: 85: 85: 85: 85: 
86: 86: 86: 86: 86:     function collectFee(uint256 _closeoutCreditReturn)
87: 87: 87: 87: 87:     external
88: 88: 88: 88: 88:     payable
89: 89: 89: 89: 89:     {
90: 90: 90: 90: 90:         uint256 fee = msg.value.sub(_closeoutCreditReturn);
91: 91: 91: 91: 91:         confidealFund = confidealFund.add(fee);
92: 92: 92: 92: 92:         emit FeePayment(msg.sender, fee);
93: 93: 93: 93: 93: 
94: 94: 94: 94: 94:         if (_closeoutCreditReturn > 0) {
95: 95: 95: 95: 95:             confidealFund = confidealFund.add(_closeoutCreditReturn);
96: 96: 96: 96: 96:             emit CloseoutCreditCollection(msg.sender, _closeoutCreditReturn);
97: 97: 97: 97: 97:         }
98: 98: 98: 98: 98:     }
99: 99: 99: 99: 99: 
100: 100: 100: 100: 100:     function arbitratorsPoolSize()
101: 101: 101: 101: 101:     external
102: 102: 102: 102: 102:     view
103: 103: 103: 103: 103:     returns (uint)
104: 104: 104: 104: 104:     {
105: 105: 105: 105: 105:         return arbitratorsPool.length;
106: 106: 106: 106: 106:     }
107: 107: 107: 107: 107: 
108: 108: 108: 108: 108:     function addArbitratorToPool(address _arbitrator)
109: 109: 109: 109: 109:     external
110: 110: 110: 110: 110:     {
111: 111: 111: 111: 111:         require(msg.sender == arbitrationManager);
112: 112: 112: 112: 112: 
113: 113: 113: 113: 113:         arbitratorsPool.push(_arbitrator);
114: 114: 114: 114: 114:     }
115: 115: 115: 115: 115: 
116: 116: 116: 116: 116:     function removeArbitratorFromPool(uint _index)
117: 117: 117: 117: 117:     external
118: 118: 118: 118: 118:     {
119: 119: 119: 119: 119:         require(msg.sender == arbitrationManager);
120: 120: 120: 120: 120:         require(arbitratorsPool.length > 0);
121: 121: 121: 121: 121: 
122: 122: 122: 122: 122:         arbitratorsPool[_index] = arbitratorsPool[arbitratorsPool.length - 1];
123: 123: 123: 123: 123:         arbitratorsPool.pop();
124: 124: 124: 124: 124:     }
125: 125: 125: 125: 125: 
126: 126: 126: 126: 126:     function assignArbitratorFromPool()
127: 127: 127: 127: 127:     external
128: 128: 128: 128: 128:     {
129: 129: 129: 129: 129:         if (arbitratorsPool.length == 0) {
130: 130: 130: 130: 130:             return;
131: 131: 131: 131: 131:         }
132: 132: 132: 132: 132: 
133: 133: 133: 133: 133:         address _arbitrator = arbitratorsPool[block.number % arbitratorsPool.length];
134: 134: 134: 134: 134:         arbitrators[msg.sender] = _arbitrator;
135: 135: 135: 135: 135:         emit ArbitratorAssignment(msg.sender, _arbitrator);
136: 136: 136: 136: 136:     }
137: 137: 137: 137: 137: 
138: 138: 138: 138: 138:     function assignArbitrator(address _deal, address _arbitrator)
139: 139: 139: 139: 139:     external
140: 140: 140: 140: 140:     {
141: 141: 141: 141: 141:         require(msg.sender == arbitrationManager);
142: 142: 142: 142: 142: 
143: 143: 143: 143: 143:         arbitrators[_deal] = _arbitrator;
144: 144: 144: 144: 144:         emit ArbitratorAssignment(_deal, _arbitrator);
145: 145: 145: 145: 145:     }
146: 146: 146: 146: 146: 
147: 147: 147: 147: 147:     function resolveDispute(address _deal, bytes32 _dataHash, uint256 _sellerAsset)
148: 148: 148: 148: 148:     external
149: 149: 149: 149: 149:     {
150: 150: 150: 150: 150:         require(msg.sender == arbitrators[_deal]);
151: 151: 151: 151: 151:         OTCDeal(_deal).resolveDispute(_dataHash, _sellerAsset);
152: 152: 152: 152: 152:     }
153: 153: 153: 153: 153: 
154: 154: 154: 154: 154:     function withdraw(uint256 _rest)
155: 155: 155: 155: 155:     external
156: 156: 156: 156: 156:     {
157: 157: 157: 157: 157:         require(msg.sender == beneficiary);
158: 158: 158: 158: 158: 
159: 159: 159: 159: 159:         uint256 _amount = confidealFund.sub(_rest);
160: 160: 160: 160: 160:         require(_amount > 0);
161: 161: 161: 161: 161: 
162: 162: 162: 162: 162:         confidealFund = confidealFund.sub(_amount);
163: 163: 163: 163: 163:         (bool _successfulTransfer,) = beneficiary.call.value(_amount)("");
164: 164: 164: 164: 164:         require(_successfulTransfer);
165: 165: 165: 165: 165:     }
166: 166: 166: 166: 166: 
167: 167: 167: 167: 167:     function contribute()
168: 168: 168: 168: 168:     external
169: 169: 169: 169: 169:     payable
170: 170: 170: 170: 170:     {
171: 171: 171: 171: 171:         confidealFund = confidealFund.add(msg.value);
172: 172: 172: 172: 172:     }
173: 173: 173: 173: 173: 
174: 174: 174: 174: 174:     function()
175: 175: 175: 175: 175:     external
176: 176: 176: 176: 176:     {
177: 177: 177: 177: 177:         revert();
178: 178: 178: 178: 178:     }
179: 179: 179: 179: 179: }