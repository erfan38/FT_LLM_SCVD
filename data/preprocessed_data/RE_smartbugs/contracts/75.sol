1: 1: pragma solidity ^0.4.19;
2: 2: 
3: 3: 
4: 4: 
5: 5: 
6: 6: 
7: 7: 
8: 8: 
9: 9: 
10: 10: 
11: 11: 
12: 12: 
13: 13: 
14: 14: 
15: 15: library SafeMath {
16: 16:   function mul(uint256 a, uint256 b) internal pure returns (uint256) {
17: 17:     if (a == 0) {
18: 18:       return 0;
19: 19:     }
20: 20:     uint256 c = a * b;
21: 21:     assert(c / a == b);
22: 22:     return c;
23: 23:   }
24: 24: 
25: 25:   function div(uint256 a, uint256 b) internal pure returns (uint256) {
26: 26:     
27: 27:     uint256 c = a / b;
28: 28:     
29: 29:     return c;
30: 30:   }
31: 31: 
32: 32:   function sub(uint256 a, uint256 b) internal pure returns (uint256) {
33: 33:     assert(b <= a);
34: 34:     return a - b;
35: 35:   }
36: 36: 
37: 37:   function add(uint256 a, uint256 b) internal pure returns (uint256) {
38: 38:     uint256 c = a + b;
39: 39:     assert(c >= a);
40: 40:     return c;
41: 41:   }
42: 42: }
43: 43: 
44: 44: 
45: 45: 
46: 46: 
47: 47: 
48: 48: 
49: 49: 
50: 50: 
51: 51: contract TokensGate is MintableToken {
52: 52:   event Burn(address indexed burner, uint256 value);
53: 53: 
54: 54:   string public constant name = "TokensGate";
55: 55:   string public constant symbol = "TGC";
56: 56:   uint8 public constant decimals = 18;
57: 57:   
58: 58:   bool public AllowTransferGlobal = false;
59: 59:   bool public AllowTransferLocal = false;
60: 60:   bool public AllowTransferExternal = false;
61: 61:   bool public AllowBurnByCreator = true;
62: 62:   bool public AllowBurn = true;
63: 63:   
64: 64:   mapping(address => uint256) public Whitelist;
65: 65:   mapping(address => uint256) public LockupList;
66: 66:   mapping(address => bool) public WildcardList;
67: 67:   mapping(address => bool) public Managers;
68: 68:     
69: 69:   function allowTransfer(address _from, address _to) public view returns (bool) {
70: 70:     if (WildcardList[_from])
71: 71:       return true;
72: 72:       
73: 73:     if (LockupList[_from] > now)
74: 74:       return false;
75: 75:     
76: 76:     if (!AllowTransferGlobal) {
77: 77:       if (AllowTransferLocal && Whitelist[_from] != 0 && Whitelist[_to] != 0 && Whitelist[_from] < now && Whitelist[_to] < now)
78: 78:         return true;
79: 79:             
80: 80:       if (AllowTransferExternal && Whitelist[_from] != 0 && Whitelist[_from] < now)
81: 81:         return true;
82: 82:         
83: 83:       return false;
84: 84:     }
85: 85:       
86: 86:     return true;
87: 87:   }
88: 88:     
89: 89:   function allowManager() public view returns (bool) {
90: 90:     if (msg.sender == owner)
91: 91:       return true;
92: 92:     
93: 93:     if (Managers[msg.sender])
94: 94:       return true;
95: 95:       
96: 96:     return false;
97: 97:   }
98: 98:     
99: 99:   function transfer(address _to, uint256 _value) public returns (bool) {
100: 100:     require(allowTransfer(msg.sender, _to));
101: 101:       
102: 102:     return super.transfer(_to, _value);
103: 103:   }
104: 104:   
105: 105:   function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
106: 106:     require(allowTransfer(_from, _to));
107: 107:       
108: 108:     return super.transferFrom(_from, _to, _value);
109: 109:   }
110: 110:     
111: 111:   function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
112: 112:     require(totalSupply.add(_amount) <= 1000000000000000000000000000);
113: 113: 
114: 114:     return super.mint(_to, _amount);
115: 115:   }
116: 116:     
117: 117:   function burn(uint256 _value) public {
118: 118:     require(AllowBurn);
119: 119:     require(_value <= balances[msg.sender]);
120: 120: 
121: 121:     balances[msg.sender] = balances[msg.sender].sub(_value);
122: 122:     totalSupply = totalSupply.sub(_value);
123: 123:     Burn(msg.sender, _value);
124: 124:     Transfer(msg.sender, address(0), _value);
125: 125:   }
126: 126:   
127: 127:   function burnByCreator(address _burner, uint256 _value) onlyOwner public {
128: 128:     require(AllowBurnByCreator);
129: 129:     require(_value <= balances[_burner]);
130: 130:     
131: 131:     balances[_burner] = balances[_burner].sub(_value);
132: 132:     totalSupply = totalSupply.sub(_value);
133: 133:     Burn(_burner, _value);
134: 134:     Transfer(_burner, address(0), _value);
135: 135:   }
136: 136:   
137: 137:   function finishBurning() onlyOwner public returns (bool) {
138: 138:     AllowBurn = false;
139: 139:     return true;
140: 140:   }
141: 141:   
142: 142:   function finishBurningByCreator() onlyOwner public returns (bool) {
143: 143:     AllowBurnByCreator = false;
144: 144:     return true;
145: 145:   }
146: 146:   
147: 147:   function setManager(address _manager, bool _status) onlyOwner public {
148: 148:     Managers[_manager] = _status;
149: 149:   }
150: 150:   
151: 151:   function setAllowTransferGlobal(bool _status) onlyOwner public {
152: 152:     AllowTransferGlobal = _status;
153: 153:   }
154: 154:   
155: 155:   function setAllowTransferLocal(bool _status) onlyOwner public {
156: 156:     AllowTransferLocal = _status;
157: 157:   }
158: 158:   
159: 159:   function setAllowTransferExternal(bool _status) onlyOwner public {
160: 160:     AllowTransferExternal = _status;
161: 161:   }
162: 162:     
163: 163:   function setWhitelist(address _address, uint256 _date) public {
164: 164:     require(allowManager());
165: 165:     
166: 166:     Whitelist[_address] = _date;
167: 167:   }
168: 168:   
169: 169:   function setLockupList(address _address, uint256 _date) onlyOwner public {
170: 170:     LockupList[_address] = _date;
171: 171:   }
172: 172:   
173: 173:   function setWildcardList(address _address, bool _status) onlyOwner public {
174: 174:     WildcardList[_address] = _status;
175: 175:   }
176: 176:   
177: 177:   function transferTokens(address walletToTransfer, address tokenAddress, uint256 tokenAmount) onlyOwner payable public {
178: 178:     ERC20 erc20 = ERC20(tokenAddress);
179: 179:     erc20.transfer(walletToTransfer, tokenAmount);
180: 180:   }
181: 181:   
182: 182:   function transferEth(address walletToTransfer, uint256 weiAmount) onlyOwner payable public {
183: 183:     require(walletToTransfer != address(0));
184: 184:     require(address(this).balance >= weiAmount);
185: 185:     require(address(this) != walletToTransfer);
186: 186: 
187: 187:     require(walletToTransfer.call.value(weiAmount)());
188: 188:   }
189: 189: }