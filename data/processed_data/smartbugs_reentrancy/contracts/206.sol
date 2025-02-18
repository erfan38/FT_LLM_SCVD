1: 1: 1: 1: 1: pragma solidity ^0.4.25;
2: 2: 2: 2: 2: contract TMBToken  {
3: 3: 3: 3: 3:         string public constant name = "TimeBankToken";
4: 4: 4: 4: 4:         string public constant symbol = "TMB";
5: 5: 5: 5: 5:         uint public constant decimals = 18;
6: 6: 6: 6: 6:         uint256 _totalSupply = 1e9 * (10 ** uint256(decimals)); 
7: 7: 7: 7: 7:         uint public baseStartTime;
8: 8: 8: 8: 8:         uint256 public distributed = 0;
9: 9: 9: 9: 9:         mapping (address => bool) public freezed;
10: 10: 10: 10: 10:         mapping(address => uint256) balances;       
11: 11: 11: 11: 11:         mapping(address => uint256) distBalances;   
12: 12: 12: 12: 12:         mapping(address => mapping (address => uint256)) allowed;
13: 13: 13: 13: 13:         address public founder;
14: 14: 14: 14: 14:         event AllocateFounderTokens(address indexed sender);
15: 15: 15: 15: 15:         event Transfer(address indexed _from, address indexed _to, uint256 _value);
16: 16: 16: 16: 16:         event Approval(address indexed _owner, address indexed _spender, uint256 _value);
17: 17: 17: 17: 17:         event Burn(address indexed fromAddr, uint256 value);
18: 18: 18: 18: 18:      
19: 19: 19: 19: 19:         function TMBToken() {
20: 20: 20: 20: 20:             founder = msg.sender;
21: 21: 21: 21: 21:         }
22: 22: 22: 22: 22:          function totalSupply() constant returns (uint256 supply) {
23: 23: 23: 23: 23:             return _totalSupply;
24: 24: 24: 24: 24:         }
25: 25: 25: 25: 25:  
26: 26: 26: 26: 26:         function balanceOf(address _owner) constant returns (uint256 balance) {
27: 27: 27: 27: 27:             return balances[_owner];
28: 28: 28: 28: 28:         }
29: 29: 29: 29: 29:  
30: 30: 30: 30: 30:         function approve(address _spender, uint256 _value) returns (bool success) {
31: 31: 31: 31: 31:             allowed[msg.sender][_spender] = _value;
32: 32: 32: 32: 32:             Approval(msg.sender, _spender, _value);
33: 33: 33: 33: 33:             return true;
34: 34: 34: 34: 34:         }
35: 35: 35: 35: 35:  
36: 36: 36: 36: 36:         function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
37: 37: 37: 37: 37:           return allowed[_owner][_spender];
38: 38: 38: 38: 38:         }
39: 39: 39: 39: 39:         function setStartTime(uint _startTime) {
40: 40: 40: 40: 40:             if (msg.sender!=founder) revert();
41: 41: 41: 41: 41:             baseStartTime = _startTime;
42: 42: 42: 42: 42:         }
43: 43: 43: 43: 43:  
44: 44: 44: 44: 44:        
45: 45: 45: 45: 45:         function distribute(uint256 _amount, address _to) {
46: 46: 46: 46: 46:             if (msg.sender!=founder) revert();
47: 47: 47: 47: 47:             if (distributed + _amount > _totalSupply) revert();
48: 48: 48: 48: 48:             if (freezed[_to]) revert();
49: 49: 49: 49: 49:             distributed += _amount;
50: 50: 50: 50: 50:             balances[_to] += _amount;
51: 51: 51: 51: 51:             distBalances[_to] += _amount;
52: 52: 52: 52: 52:         }
53: 53: 53: 53: 53:  
54: 54: 54: 54: 54:       
55: 55: 55: 55: 55:         function transfer(address _to, uint256 _value) returns (bool success) {
56: 56: 56: 56: 56:             if (now < baseStartTime) revert();
57: 57: 57: 57: 57:             if (freezed[msg.sender]) revert();
58: 58: 58: 58: 58:             if (freezed[_to]) revert();
59: 59: 59: 59: 59:             
60: 60: 60: 60: 60:             
61: 61: 61: 61: 61:             
62: 62: 62: 62: 62:             if (balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
63: 63: 63: 63: 63:                 uint _freeAmount = freeAmount(msg.sender);
64: 64: 64: 64: 64:                 if (_freeAmount < _value) {
65: 65: 65: 65: 65:                     return false;
66: 66: 66: 66: 66:                 } 
67: 67: 67: 67: 67:  
68: 68: 68: 68: 68:                 balances[msg.sender] -= _value;
69: 69: 69: 69: 69:                 balances[_to] += _value;
70: 70: 70: 70: 70:                 Transfer(msg.sender, _to, _value);
71: 71: 71: 71: 71:                 return true;
72: 72: 72: 72: 72:             } else {
73: 73: 73: 73: 73:                 return false;
74: 74: 74: 74: 74:             }
75: 75: 75: 75: 75:         }
76: 76: 76: 76: 76:         
77: 77: 77: 77: 77:         function addTokenTotal(uint256 _addAmount) public returns (bool success){
78: 78: 78: 78: 78:     require(msg.sender == founder);                        
79: 79: 79: 79: 79:     require(_addAmount > 0);                             
80: 80: 80: 80: 80:         
81: 81: 81: 81: 81:     _totalSupply += _addAmount * 10 ** decimals;           
82: 82: 82: 82: 82:     balances[msg.sender] += _addAmount * 10 ** decimals;  
83: 83: 83: 83: 83:     return true;
84: 84: 84: 84: 84: }  
85: 85: 85: 85: 85:     function unFreezenAccount(address _freezen) public returns (bool success) {
86: 86: 86: 86: 86:         require(msg.sender == founder);       
87: 87: 87: 87: 87:         
88: 88: 88: 88: 88:         freezed[_freezen] = false;
89: 89: 89: 89: 89:         return true;
90: 90: 90: 90: 90:     }
91: 91: 91: 91: 91:     
92: 92: 92: 92: 92:     function burn(uint256 _value) public returns (bool success) {
93: 93: 93: 93: 93:         require(msg.sender == founder);                  
94: 94: 94: 94: 94:         require(balances[msg.sender] >= _value);      
95: 95: 95: 95: 95:         balances[msg.sender] -= _value;
96: 96: 96: 96: 96:         _totalSupply -= _value;
97: 97: 97: 97: 97:         Burn(msg.sender, _value);
98: 98: 98: 98: 98:         return true;
99: 99: 99: 99: 99:     }
100: 100: 100: 100: 100:     
101: 101: 101: 101: 101:    
102: 102: 102: 102: 102:     function burnFrom(address _from, uint256 _value) public returns (bool success) {
103: 103: 103: 103: 103:         require(msg.sender == founder);                  
104: 104: 104: 104: 104:         require(balances[_from] >= _value);            
105: 105: 105: 105: 105:         require(_value <= allowed[_from][msg.sender]);  
106: 106: 106: 106: 106:         balances[_from] -= _value;
107: 107: 107: 107: 107:         allowed[_from][msg.sender] -= _value;
108: 108: 108: 108: 108:         _totalSupply -= _value;
109: 109: 109: 109: 109:         Burn(_from, _value);
110: 110: 110: 110: 110:         return true;
111: 111: 111: 111: 111:     }
112: 112: 112: 112: 112: 
113: 113: 113: 113: 113:    
114: 114: 114: 114: 114: 
115: 115: 115: 115: 115:   function freezenAccount(address _freezen) public returns (bool success) {
116: 116: 116: 116: 116:         require(msg.sender == founder);      
117: 117: 117: 117: 117:         require(_freezen != founder);         
118: 118: 118: 118: 118:     
119: 119: 119: 119: 119:         freezed[_freezen] = true;
120: 120: 120: 120: 120:         return true;
121: 121: 121: 121: 121:     }
122: 122: 122: 122: 122: 
123: 123: 123: 123: 123:         function freeAmount(address user) returns (uint256 amount) {
124: 124: 124: 124: 124:            
125: 125: 125: 125: 125:             if (user == founder) {
126: 126: 126: 126: 126:                 return balances[user];
127: 127: 127: 127: 127:             }
128: 128: 128: 128: 128: 
129: 129: 129: 129: 129:             if (now < baseStartTime) {
130: 130: 130: 130: 130:                 return 0;
131: 131: 131: 131: 131:             }
132: 132: 132: 132: 132:  
133: 133: 133: 133: 133:          
134: 134: 134: 134: 134:             uint monthDiff = (now - baseStartTime) / (30 days);
135: 135: 135: 135: 135:  
136: 136: 136: 136: 136:            
137: 137: 137: 137: 137:             if (monthDiff > 5) {
138: 138: 138: 138: 138:                 return balances[user];
139: 139: 139: 139: 139:             }
140: 140: 140: 140: 140:  
141: 141: 141: 141: 141:            
142: 142: 142: 142: 142:             uint unrestricted = distBalances[user] / 10 + distBalances[user] * 20 / 100 * monthDiff;
143: 143: 143: 143: 143:             if (unrestricted > distBalances[user]) {
144: 144: 144: 144: 144:                 unrestricted = distBalances[user];
145: 145: 145: 145: 145:             }
146: 146: 146: 146: 146:  
147: 147: 147: 147: 147:            
148: 148: 148: 148: 148:             if (unrestricted + balances[user] < distBalances[user]) {
149: 149: 149: 149: 149:                 amount = 0;
150: 150: 150: 150: 150:             } else {
151: 151: 151: 151: 151:                 amount = unrestricted + (balances[user] - distBalances[user]);
152: 152: 152: 152: 152:             }
153: 153: 153: 153: 153:  
154: 154: 154: 154: 154:             return amount;
155: 155: 155: 155: 155:         }
156: 156: 156: 156: 156:  
157: 157: 157: 157: 157:        
158: 158: 158: 158: 158:         function changeFounder(address newFounder) {
159: 159: 159: 159: 159:             if (msg.sender!=founder) revert();
160: 160: 160: 160: 160:             founder = newFounder;
161: 161: 161: 161: 161:         }
162: 162: 162: 162: 162:  
163: 163: 163: 163: 163:         
164: 164: 164: 164: 164:         function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
165: 165: 165: 165: 165:             require(_to != address(0));
166: 166: 166: 166: 166:             if (freezed[_from]) revert();
167: 167: 167: 167: 167:             if (freezed[_to]) revert();
168: 168: 168: 168: 168:             
169: 169: 169: 169: 169:             if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
170: 170: 170: 170: 170:                 uint _freeAmount = freeAmount(_from);
171: 171: 171: 171: 171:                 if (_freeAmount < _value) {
172: 172: 172: 172: 172:                     return false;
173: 173: 173: 173: 173:                 } 
174: 174: 174: 174: 174:  
175: 175: 175: 175: 175:                 balances[_to] += _value;
176: 176: 176: 176: 176:                 balances[_from] -= _value;
177: 177: 177: 177: 177:                 allowed[_from][msg.sender] -= _value;
178: 178: 178: 178: 178:                 Transfer(_from, _to, _value);
179: 179: 179: 179: 179:                 return true;
180: 180: 180: 180: 180:             } else { return false; }
181: 181: 181: 181: 181:         }
182: 182: 182: 182: 182:         function kill() public {
183: 183: 183: 183: 183:         require(msg.sender == founder);
184: 184: 184: 184: 184:         selfdestruct(founder);
185: 185: 185: 185: 185:         }
186: 186: 186: 186: 186: 
187: 187: 187: 187: 187:         function() payable {
188: 188: 188: 188: 188:             if (!founder.call.value(msg.value)()) revert(); 
189: 189: 189: 189: 189:         }
190: 190: 190: 190: 190:     }