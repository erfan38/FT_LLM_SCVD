1: 1: 1: 1: 1: pragma solidity ^0.4.20;
2: 2: 2: 2: 2: 
3: 3: 3: 3: 3: 
4: 4: 4: 4: 4: 
5: 5: 5: 5: 5: 
6: 6: 6: 6: 6: library SafeMath {
7: 7: 7: 7: 7:     function mul(uint256 a, uint256 b) internal pure returns (uint256) {
8: 8: 8: 8: 8:         if (a == 0) {
9: 9: 9: 9: 9:             return 0;
10: 10: 10: 10: 10:         }
11: 11: 11: 11: 11:         uint256 c = a * b;
12: 12: 12: 12: 12:         assert(c / a == b);
13: 13: 13: 13: 13:         return c;
14: 14: 14: 14: 14:     }
15: 15: 15: 15: 15: 
16: 16: 16: 16: 16:     function div(uint256 a, uint256 b) internal pure returns (uint256) {
17: 17: 17: 17: 17:         
18: 18: 18: 18: 18:         uint256 c = a / b;
19: 19: 19: 19: 19:         
20: 20: 20: 20: 20:         return c;
21: 21: 21: 21: 21:     }
22: 22: 22: 22: 22: 
23: 23: 23: 23: 23:     function sub(uint256 a, uint256 b) internal pure returns (uint256) {
24: 24: 24: 24: 24:         assert(b <= a);
25: 25: 25: 25: 25:         return a - b;
26: 26: 26: 26: 26:     }
27: 27: 27: 27: 27: 
28: 28: 28: 28: 28:     function add(uint256 a, uint256 b) internal pure returns (uint256) {
29: 29: 29: 29: 29:         uint256 c = a + b;
30: 30: 30: 30: 30:         assert(c >= a);
31: 31: 31: 31: 31:         return c;
32: 32: 32: 32: 32:     }
33: 33: 33: 33: 33: }
34: 34: 34: 34: 34: 
35: 35: 35: 35: 35: 
36: 36: 36: 36: 36: 
37: 37: 37: 37: 37: 
38: 38: 38: 38: 38: contract ParcelXToken is ERC20, MultiOwnable, Pausable, Buyable, Convertible {
39: 39: 39: 39: 39: 
40: 40: 40: 40: 40:     using SafeMath for uint256;
41: 41: 41: 41: 41:   
42: 42: 42: 42: 42:     string public constant name = "TestGPX-name";
43: 43: 43: 43: 43:     string public constant symbol = "TestGPX-symbol";
44: 44: 44: 44: 44:     uint8 public constant decimals = 18;
45: 45: 45: 45: 45:     uint256 public constant TOTAL_SUPPLY = uint256(1000000000) * (uint256(10) ** decimals);  
46: 46: 46: 46: 46: 
47: 47: 47: 47: 47:     address internal tokenPool;      
48: 48: 48: 48: 48:     mapping(address => uint256) internal balances;
49: 49: 49: 49: 49:     mapping (address => mapping (address => uint256)) internal allowed;
50: 50: 50: 50: 50: 
51: 51: 51: 51: 51:     function ParcelXToken(address[] _otherOwners, uint _multiRequires) 
52: 52: 52: 52: 52:         MultiOwnable(_otherOwners, _multiRequires) public {
53: 53: 53: 53: 53:         tokenPool = this;
54: 54: 54: 54: 54:         balances[tokenPool] = TOTAL_SUPPLY;
55: 55: 55: 55: 55:     }
56: 56: 56: 56: 56: 
57: 57: 57: 57: 57:     
58: 58: 58: 58: 58: 
59: 59: 59: 59: 59: 
60: 60: 60: 60: 60:     function totalSupply() public view returns (uint256) {
61: 61: 61: 61: 61:         return TOTAL_SUPPLY;       
62: 62: 62: 62: 62:     }
63: 63: 63: 63: 63: 
64: 64: 64: 64: 64:     function transfer(address _to, uint256 _value) public returns (bool) {
65: 65: 65: 65: 65:         require(_to != address(0));
66: 66: 66: 66: 66:         require(_value <= balances[msg.sender]);
67: 67: 67: 67: 67: 
68: 68: 68: 68: 68:         
69: 69: 69: 69: 69:         balances[msg.sender] = balances[msg.sender].sub(_value);
70: 70: 70: 70: 70:         balances[_to] = balances[_to].add(_value);
71: 71: 71: 71: 71:         Transfer(msg.sender, _to, _value);
72: 72: 72: 72: 72:         return true;
73: 73: 73: 73: 73:   }
74: 74: 74: 74: 74: 
75: 75: 75: 75: 75:     function balanceOf(address _owner) public view returns (uint256) {
76: 76: 76: 76: 76:         return balances[_owner];
77: 77: 77: 77: 77:     }
78: 78: 78: 78: 78: 
79: 79: 79: 79: 79:     function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
80: 80: 80: 80: 80:         require(_to != address(0));
81: 81: 81: 81: 81:         require(_value <= balances[_from]);
82: 82: 82: 82: 82:         require(_value <= allowed[_from][msg.sender]);
83: 83: 83: 83: 83: 
84: 84: 84: 84: 84:         balances[_from] = balances[_from].sub(_value);
85: 85: 85: 85: 85:         balances[_to] = balances[_to].add(_value);
86: 86: 86: 86: 86:         allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
87: 87: 87: 87: 87:         Transfer(_from, _to, _value);
88: 88: 88: 88: 88:         return true;
89: 89: 89: 89: 89:     }
90: 90: 90: 90: 90: 
91: 91: 91: 91: 91:     function approve(address _spender, uint256 _value) public returns (bool) {
92: 92: 92: 92: 92:         allowed[msg.sender][_spender] = _value;
93: 93: 93: 93: 93:         Approval(msg.sender, _spender, _value);
94: 94: 94: 94: 94:         return true;
95: 95: 95: 95: 95:     }
96: 96: 96: 96: 96: 
97: 97: 97: 97: 97:     function allowance(address _owner, address _spender) public view returns (uint256) {
98: 98: 98: 98: 98:         return allowed[_owner][_spender];
99: 99: 99: 99: 99:     }
100: 100: 100: 100: 100: 
101: 101: 101: 101: 101:     function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
102: 102: 102: 102: 102:         allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
103: 103: 103: 103: 103:         Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
104: 104: 104: 104: 104:         return true;
105: 105: 105: 105: 105:     }
106: 106: 106: 106: 106: 
107: 107: 107: 107: 107:     function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
108: 108: 108: 108: 108:         uint oldValue = allowed[msg.sender][_spender];
109: 109: 109: 109: 109:         if (_subtractedValue > oldValue) {
110: 110: 110: 110: 110:             allowed[msg.sender][_spender] = 0;
111: 111: 111: 111: 111:         } else {
112: 112: 112: 112: 112:             allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
113: 113: 113: 113: 113:         }
114: 114: 114: 114: 114:         Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
115: 115: 115: 115: 115:         return true;
116: 116: 116: 116: 116:     }
117: 117: 117: 117: 117: 
118: 118: 118: 118: 118:     
119: 119: 119: 119: 119: 
120: 120: 120: 120: 120: 
121: 121: 121: 121: 121: 
122: 122: 122: 122: 122:     uint256 internal buyRate = uint256(3731); 
123: 123: 123: 123: 123:     
124: 124: 124: 124: 124:     event Deposit(address indexed who, uint256 value);
125: 125: 125: 125: 125:     event Withdraw(address indexed who, uint256 value, address indexed lastApprover);
126: 126: 126: 126: 126:         
127: 127: 127: 127: 127: 
128: 128: 128: 128: 128:     function getBuyRate() external view returns (uint256) {
129: 129: 129: 129: 129:         return buyRate;
130: 130: 130: 130: 130:     }
131: 131: 131: 131: 131: 
132: 132: 132: 132: 132:     function setBuyRate(uint256 newBuyRate) mostOwner(keccak256(msg.data)) external {
133: 133: 133: 133: 133:         buyRate = newBuyRate;
134: 134: 134: 134: 134:     }
135: 135: 135: 135: 135: 
136: 136: 136: 136: 136:     
137: 137: 137: 137: 137:     function buy() payable whenNotPaused public returns (uint256) {
138: 138: 138: 138: 138:         require(msg.value >= 0.001 ether);
139: 139: 139: 139: 139:         uint256 tokens = msg.value.mul(buyRate);  
140: 140: 140: 140: 140:         require(balances[tokenPool] >= tokens);               
141: 141: 141: 141: 141:         balances[tokenPool] = balances[tokenPool].sub(tokens);                        
142: 142: 142: 142: 142:         balances[msg.sender] = balances[msg.sender].add(tokens);                  
143: 143: 143: 143: 143:         Transfer(tokenPool, msg.sender, tokens);               
144: 144: 144: 144: 144:         return tokens;                                    
145: 145: 145: 145: 145:     }
146: 146: 146: 146: 146: 
147: 147: 147: 147: 147:     
148: 148: 148: 148: 148:     function () public payable {
149: 149: 149: 149: 149:         if (msg.value > 0) {
150: 150: 150: 150: 150:             buy();
151: 151: 151: 151: 151:             Deposit(msg.sender, msg.value);
152: 152: 152: 152: 152:         }
153: 153: 153: 153: 153:     }
154: 154: 154: 154: 154: 
155: 155: 155: 155: 155:     function execute(address _to, uint256 _value, bytes _data) mostOwner(keccak256(msg.data)) external returns (bool){
156: 156: 156: 156: 156:         require(_to != address(0));
157: 157: 157: 157: 157:         Withdraw(_to, _value, msg.sender);
158: 158: 158: 158: 158:         return _to.call.value(_value)(_data);
159: 159: 159: 159: 159:     }
160: 160: 160: 160: 160: 
161: 161: 161: 161: 161:     
162: 162: 162: 162: 162: 
163: 163: 163: 163: 163: 
164: 164: 164: 164: 164:     function convertMainchainGPX(string destinationAccount, string extra) external returns (bool) {
165: 165: 165: 165: 165:         require(bytes(destinationAccount).length > 10 && bytes(destinationAccount).length < 128);
166: 166: 166: 166: 166:         require(balances[msg.sender] > 0);
167: 167: 167: 167: 167:         uint256 amount = balances[msg.sender];
168: 168: 168: 168: 168:         balances[msg.sender] = 0;
169: 169: 169: 169: 169:         balances[tokenPool] = balances[tokenPool].add(amount);   
170: 170: 170: 170: 170:         Converted(msg.sender, destinationAccount, amount, extra);
171: 171: 171: 171: 171:         return true;
172: 172: 172: 172: 172:     }
173: 173: 173: 173: 173: 
174: 174: 174: 174: 174: }