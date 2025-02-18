1: 1: pragma solidity ^0.4.24; 
2: 2: 
3: 3: 
4: 4: 
5: 5: 
6: 6: 
7: 7: 
8: 8: 
9: 9: contract Aion {
10: 10:     using SafeMath for uint256;
11: 11: 
12: 12:     address public owner;
13: 13:     uint256 public serviceFee;
14: 14:     uint256 public AionID;
15: 15:     uint256 public feeChangeInterval;
16: 16:     mapping(address => address) public clientAccount;
17: 17:     mapping(uint256 => bytes32) public scheduledCalls;
18: 18: 
19: 19:     
20: 20:     event ExecutedCallEvent(address indexed from, uint256 indexed AionID, bool TxStatus, bool TxStatus_cancel, bool reimbStatus);
21: 21:     
22: 22:     
23: 23:     event ScheduleCallEvent(uint256 indexed blocknumber, address indexed from, address to, uint256 value, uint256 gaslimit,
24: 24:                             uint256 gasprice, uint256 fee, bytes data, uint256 indexed AionID, bool schedType);
25: 25:     
26: 26:     
27: 27:     event CancellScheduledTxEvent(address indexed from, uint256 Total, bool Status, uint256 indexed AionID);
28: 28:     
29: 29: 
30: 30:     
31: 31:     event feeChanged(uint256 newfee, uint256 oldfee);
32: 32:     
33: 33: 
34: 34:     
35: 35:     
36: 36:     constructor () public {
37: 37:         owner = msg.sender;
38: 38:         serviceFee = 500000000000000;
39: 39:     }    
40: 40: 
41: 41:     
42: 42:     function transferOwnership(address newOwner) public {
43: 43:         require(msg.sender == owner);
44: 44:         withdraw();
45: 45:         owner = newOwner;
46: 46:     }
47: 47: 
48: 48:     
49: 49:     
50: 50:     function createAccount() internal {
51: 51:         if(clientAccount[msg.sender]==address(0x0)){
52: 52:             AionClient newContract = new AionClient(address(this));
53: 53:             clientAccount[msg.sender] = address(newContract);
54: 54:         }
55: 55:     }
56: 56:     
57: 57:     
58: 58:     
59: 59:     
60: 60: 
61: 61: 
62: 62: 
63: 63: 
64: 64: 
65: 65: 
66: 66: 
67: 67: 
68: 68: 
69: 69: 
70: 70:     function ScheduleCall(uint256 blocknumber, address to, uint256 value, uint256 gaslimit, uint256 gasprice, bytes data, bool schedType) public payable returns (uint,address){
71: 71:         require(msg.value == value.add(gaslimit.mul(gasprice)).add(serviceFee));
72: 72:         AionID = AionID + 1;
73: 73:         scheduledCalls[AionID] = keccak256(abi.encodePacked(blocknumber, msg.sender, to, value, gaslimit, gasprice, serviceFee, data, schedType));
74: 74:         createAccount();
75: 75:         clientAccount[msg.sender].transfer(msg.value);
76: 76:         emit ScheduleCallEvent(blocknumber, msg.sender, to, value, gaslimit, gasprice, serviceFee, data, AionID, schedType);
77: 77:         return (AionID,clientAccount[msg.sender]);
78: 78:     }
79: 79: 
80: 80:     
81: 81:     
82: 82: 
83: 83: 
84: 84: 
85: 85: 
86: 86:     function executeCall(uint256 blocknumber, address from, address to, uint256 value, uint256 gaslimit, uint256 gasprice,
87: 87:                          uint256 fee, bytes data, uint256 aionId, bool schedType) external {
88: 88:         require(msg.sender==owner);
89: 89:         if(schedType) require(blocknumber <= block.timestamp);
90: 90:         if(!schedType) require(blocknumber <= block.number);
91: 91:         
92: 92:         require(scheduledCalls[aionId]==keccak256(abi.encodePacked(blocknumber, from, to, value, gaslimit, gasprice, fee, data, schedType)));
93: 93:         AionClient instance = AionClient(clientAccount[from]);
94: 94:         
95: 95:         require(instance.execfunct(address(this), gasprice*gaslimit+fee, 2100, hex"00"));
96: 96:         bool TxStatus = instance.execfunct(to, value, gasleft().sub(50000), data);
97: 97:         
98: 98:         
99: 99:         bool TxStatus_cancel;
100: 100:         if(!TxStatus && value>0){TxStatus_cancel = instance.execfunct(from, value, 2100, hex"00");}
101: 101:         
102: 102:         delete scheduledCalls[aionId];
103: 103:         bool reimbStatus = from.call.value((gasleft()).mul(gasprice)).gas(2100)();
104: 104:         emit ExecutedCallEvent(from, aionId,TxStatus, TxStatus_cancel, reimbStatus);
105: 105:         
106: 106:     }
107: 107: 
108: 108:     
109: 109:     
110: 110: 
111: 111: 
112: 112: 
113: 113:     function cancellScheduledTx(uint256 blocknumber, address from, address to, uint256 value, uint256 gaslimit, uint256 gasprice,
114: 114:                          uint256 fee, bytes data, uint256 aionId, bool schedType) external returns(bool) {
115: 115:         if(schedType) require(blocknumber >=  block.timestamp+(3 minutes) || blocknumber <= block.timestamp-(5 minutes));
116: 116:         if(!schedType) require(blocknumber >  block.number+10 || blocknumber <= block.number-20);
117: 117:         require(scheduledCalls[aionId]==keccak256(abi.encodePacked(blocknumber, from, to, value, gaslimit, gasprice, fee, data, schedType)));
118: 118:         require(msg.sender==from);
119: 119:         AionClient instance = AionClient(clientAccount[msg.sender]);
120: 120:         
121: 121:         bool Status = instance.execfunct(from, value+gasprice*gaslimit+fee, 3000, hex"00");
122: 122:         require(Status);
123: 123:         emit CancellScheduledTxEvent(from, value+gasprice*gaslimit+fee, Status, aionId);
124: 124:         delete scheduledCalls[aionId];
125: 125:         return true;
126: 126:     }
127: 127:     
128: 128:     
129: 129:     
130: 130:     
131: 131:     
132: 132:     function withdraw() public {
133: 133:         require(msg.sender==owner);
134: 134:         owner.transfer(address(this).balance);
135: 135:     }
136: 136:     
137: 137:     
138: 138:     
139: 139:     
140: 140:     
141: 141:     
142: 142:     
143: 143:     function updatefee(uint256 fee) public{
144: 144:         require(msg.sender==owner);
145: 145:         require(feeChangeInterval<block.timestamp);
146: 146:         uint256 oldfee = serviceFee;
147: 147:         if(fee>serviceFee){
148: 148:             require(((fee.sub(serviceFee)).mul(100)).div(serviceFee)<=10);
149: 149:             serviceFee = fee;
150: 150:         } else{
151: 151:             serviceFee = fee;
152: 152:         }
153: 153:         feeChangeInterval = block.timestamp + (1 days);
154: 154:         emit feeChanged(serviceFee, oldfee);
155: 155:     } 
156: 156:     
157: 157: 
158: 158:     
159: 159:     
160: 160:     function () public payable {
161: 161:     
162: 162:     }
163: 163: 
164: 164: 
165: 165: 
166: 166: }