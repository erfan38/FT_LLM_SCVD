1: 1: pragma solidity ^0.4.16;
2: 2: interface ContractReceiver {
3: 3:   function tokenFallback( address from, uint value, bytes data ) external;
4: 4: }
5: 5: 
6: 6: interface TokenRecipient {
7: 7:   function receiveApproval( address from, uint256 value, bytes data ) external;
8: 8: }
9: 9: 
10: 10: interface ERC223TokenBasic {
11: 11:     function transfer(address receiver, uint256 amount, bytes data) external;
12: 12:     function balanceOf(address owner) external constant returns (uint);    
13: 13:     function transferFrom( address from, address to, uint256 value ) external returns (bool success);
14: 14: }
15: 15: contract ZBToken is ERC223TokenBasic
16: 16: {
17: 17:   string  public name;
18: 18:   string  public symbol;
19: 19:   uint8   public decimals;
20: 20:   uint256 public totalSupply;
21: 21:   address public issuer;
22: 22: 
23: 23:   mapping( address => uint256 ) balances_;
24: 24:   mapping( address => mapping(address => uint256) ) allowances_;
25: 25: 
26: 26:   
27: 27:   event Approval( address indexed owner,
28: 28:                   address indexed spender,
29: 29:                   uint value );
30: 30: 
31: 31:   event Transfer( address indexed from,
32: 32:                   address indexed to,
33: 33:                   uint256 value );
34: 34:                
35: 35: 
36: 36:   
37: 37:   event Burn( address indexed from, uint256 value );
38: 38: 
39: 39:   constructor ( uint256 initialSupply,
40: 40:                 string tokenName,
41: 41:                 uint8 decimalUnits,
42: 42:                 string tokenSymbol ) public
43: 43:   {
44: 44:     totalSupply = initialSupply * 10 ** uint256(decimalUnits);
45: 45:     balances_[msg.sender] = totalSupply;
46: 46:     name = tokenName;
47: 47:     decimals = decimalUnits;
48: 48:     symbol = tokenSymbol;
49: 49:     issuer = msg.sender;
50: 50:     emit Transfer( address(0), msg.sender, totalSupply );
51: 51:   }
52: 52: 
53: 53:   function() public payable { revert(); } 
54: 54: 
55: 55:   
56: 56:   function balanceOf( address owner ) public constant returns (uint) {
57: 57:     return balances_[owner];
58: 58:   }
59: 59: 
60: 60:   
61: 61:   
62: 62:   
63: 63:   
64: 64:   
65: 65:   
66: 66:   function approve( address spender, uint256 value ) public
67: 67:   returns (bool success)
68: 68:   {
69: 69:     allowances_[msg.sender][spender] = value;
70: 70:     emit Approval( msg.sender, spender, value );
71: 71:     return true;
72: 72:   }
73: 73: 
74: 74:   
75: 75:   function safeApprove( address _spender,
76: 76:                         uint256 _currentValue,
77: 77:                         uint256 _value ) public
78: 78:                         returns (bool success) 
79: 79:   {
80: 80:     
81: 81:     
82: 82:     if (allowances_[msg.sender][_spender] == _currentValue)
83: 83:       return approve(_spender, _value);
84: 84: 
85: 85:     return false;
86: 86:   }
87: 87: 
88: 88:   
89: 89:   function allowance( address owner, address spender ) public constant
90: 90:   returns (uint256 remaining)
91: 91:   {
92: 92:     return allowances_[owner][spender];
93: 93:   }
94: 94: 
95: 95:   function transfer(address to, uint256 value) public returns (bool success)
96: 96:   {
97: 97:     bytes memory empty; 
98: 98:     _transfer( msg.sender, to, value, empty );
99: 99:     return true;
100: 100:   }
101: 101: 
102: 102:   
103: 103:   function transferFrom( address from, address to, uint256 value ) public returns (bool success)
104: 104:   {
105: 105:     require( value <= allowances_[from][msg.sender] );
106: 106: 
107: 107:     allowances_[from][msg.sender] -= value;
108: 108:     bytes memory empty;
109: 109:     _transfer( from, to, value, empty );
110: 110: 
111: 111:     return true;
112: 112:   }
113: 113: 
114: 114:   
115: 115:   function approveAndCall( address spender,
116: 116:                            uint256 value,
117: 117:                            bytes context ) public
118: 118:   returns (bool success)
119: 119:   {
120: 120:     if ( approve(spender, value) )
121: 121:     {
122: 122:       TokenRecipient recip = TokenRecipient( spender );
123: 123:       recip.receiveApproval( msg.sender, value, context );
124: 124:       return true;
125: 125:     }
126: 126:     return false;
127: 127:   }
128: 128: 
129: 129:   
130: 130:   function burn( uint256 value ) public
131: 131:   returns (bool success)
132: 132:   {
133: 133:     require( balances_[msg.sender] >= value );
134: 134:     balances_[msg.sender] -= value;
135: 135:     totalSupply -= value;
136: 136: 
137: 137:     emit Burn( msg.sender, value );
138: 138:     return true;
139: 139:   }
140: 140: 
141: 141:   
142: 142:   function burnFrom( address from, uint256 value ) public
143: 143:   returns (bool success)
144: 144:   {
145: 145:     require( balances_[from] >= value );
146: 146:     require( value <= allowances_[from][msg.sender] );
147: 147: 
148: 148:     balances_[from] -= value;
149: 149:     allowances_[from][msg.sender] -= value;
150: 150:     totalSupply -= value;
151: 151: 
152: 152:     emit Burn( from, value );
153: 153:     return true;
154: 154:   }
155: 155: 
156: 156:   
157: 157:   function transfer( address to, uint value, bytes data ) external
158: 158:   {
159: 159:     if (isContract(to)) {
160: 160:       transferToContract( to, value, data );
161: 161:     }
162: 162:     else
163: 163:     {
164: 164:       _transfer( msg.sender, to, value, data );
165: 165:     }
166: 166:   }
167: 167: 
168: 168:   
169: 169:   function transfer( address to,
170: 170:                      uint value,
171: 171:                      bytes data,
172: 172:                      string custom_fallback ) public returns (bool success)
173: 173:   {
174: 174:     _transfer( msg.sender, to, value, data );
175: 175: 
176: 176:     if ( isContract(to) )
177: 177:     {
178: 178:       ContractReceiver rx = ContractReceiver( to );
179: 179:       require( address(rx).call.value(0)(bytes4(keccak256(abi.encodePacked(custom_fallback))),
180: 180:                msg.sender,
181: 181:                value,
182: 182:                data) );
183: 183:     }
184: 184: 
185: 185:     return true;
186: 186:   }
187: 187: 
188: 188:   
189: 189:   function transferToContract( address to, uint value, bytes data ) private
190: 190:   returns (bool success)
191: 191:   {
192: 192:     _transfer( msg.sender, to, value, data );
193: 193: 
194: 194:     ContractReceiver cr = ContractReceiver(to);
195: 195:     cr.tokenFallback( msg.sender, value, data );
196: 196: 
197: 197:     return true;
198: 198:   }
199: 199: 
200: 200:   
201: 201:   function isContract( address _addr ) private constant returns (bool)
202: 202:   {
203: 203:     uint length;
204: 204:     assembly { length := extcodesize(_addr) }
205: 205:     return (length > 0);
206: 206:   }
207: 207: 
208: 208:   function _transfer( address from,
209: 209:                       address to,
210: 210:                       uint value,
211: 211:                       bytes data ) internal
212: 212:   {
213: 213:     require( to != 0x0 );
214: 214:     require( balances_[from] >= value );
215: 215:     require( balances_[to] + value > balances_[to] ); 
216: 216: 
217: 217:     balances_[from] -= value;
218: 218:     balances_[to] += value;
219: 219: 
220: 220:     
221: 221:     bytes memory empty;
222: 222:     empty = data;
223: 223:     emit Transfer( from, to, value ); 
224: 224:   }
225: 225: }