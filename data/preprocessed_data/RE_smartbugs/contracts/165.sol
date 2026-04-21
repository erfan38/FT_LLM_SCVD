1: 1: contract DaoAccount
2: 2: {
3: 3: 	
4: 4: 
5: 5: 
6: 6: 
7: 7: 	uint256 constant tokenPrice = 1000000000000000; 
8: 8: 
9: 9: 	
10: 10: 
11: 11: 
12: 12: 
13: 13: 	
14: 14: 	
15: 15: 	
16: 16: 
17: 17: 
18: 18: 
19: 19:   uint256 public tokenBalance; 
20: 20: 
21: 21: 	
22: 22: 
23: 23: 
24: 24: 
25: 25:   address owner;        
26: 26: 	address daoChallenge; 
27: 27: 
28: 28:   
29: 29:   
30: 30:   address challengeOwner;
31: 31: 
32: 32: 	
33: 33: 
34: 34: 
35: 35: 
36: 36: 	modifier noEther() {if (msg.value > 0) throw; _}
37: 37: 
38: 38: 	modifier onlyOwner() {if (owner != msg.sender) throw; _}
39: 39: 
40: 40: 	modifier onlyChallengeOwner() {if (challengeOwner != msg.sender) throw; _}
41: 41: 
42: 42: 	
43: 43: 
44: 44: 
45: 45: 
46: 46:   function DaoAccount (address _owner, address _challengeOwner) {
47: 47:     owner = _owner;
48: 48:     daoChallenge = msg.sender;
49: 49: 
50: 50:     
51: 51:     challengeOwner = _challengeOwner;
52: 52: 	}
53: 53: 
54: 54:   
55: 55: 	function () onlyOwner returns (uint256 newBalance){
56: 56: 		uint256 amount = msg.value;
57: 57: 
58: 58: 		
59: 59: 		if (amount % tokenPrice != 0) {
60: 60: 			throw;
61: 61: 		}
62: 62: 
63: 63:     uint256 tokens = amount / tokenPrice;
64: 64: 
65: 65: 		tokenBalance += tokens;
66: 66: 
67: 67:     return tokenBalance;
68: 68: 	}
69: 69: 
70: 70: 	
71: 71: 
72: 72: 
73: 73: 
74: 74: 	
75: 75:   
76: 76: 	function withdrawEtherOrThrow(uint256 amount) private {
77: 77:     if (msg.sender != owner) throw;
78: 78: 		bool result = owner.call.value(amount)();
79: 79: 		if (!result) {
80: 80: 			throw;
81: 81: 		}
82: 82: 	}
83: 83: 
84: 84: 	
85: 85: 
86: 86: 
87: 87: 
88: 88: 	function refund() noEther onlyOwner {
89: 89: 		if (tokenBalance == 0) throw;
90: 90: 		tokenBalance = 0;
91: 91: 		withdrawEtherOrThrow(tokenBalance * tokenPrice);
92: 92: 	}
93: 93: 
94: 94: 	
95: 95: 	function terminate() noEther onlyChallengeOwner {
96: 96: 		suicide(challengeOwner);
97: 97: 	}
98: 98: }
99: 99: contract DaoChallenge
100: 100: {
101: 101: 	
102: 102: 
103: 103: 
104: 104: 
105: 105: 	
106: 106: 
107: 107: 	
108: 108: 
109: 109: 
110: 110: 
111: 111: 	event notifyTerminate(uint256 finalBalance);
112: 112: 
113: 113: 	
114: 114: 
115: 115: 
116: 116: 
117: 117: 	
118: 118: 
119: 119: 
120: 120: 
121: 121: 	
122: 122: 	address owner;
123: 123: 
124: 124: 	mapping (address => DaoAccount) private daoAccounts;
125: 125: 
126: 126: 	
127: 127: 
128: 128: 
129: 129: 
130: 130: 	modifier noEther() {if (msg.value > 0) throw; _}
131: 131: 
132: 132: 	modifier onlyOwner() {if (owner != msg.sender) throw; _}
133: 133: 
134: 134: 	
135: 135: 
136: 136: 
137: 137: 
138: 138: 	function DaoChallenge () {
139: 139: 		owner = msg.sender; 
140: 140: 	}
141: 141: 
142: 142: 	function () noEther {
143: 143: 	}
144: 144: 
145: 145: 	
146: 146: 
147: 147: 
148: 148: 
149: 149: 	
150: 150: 
151: 151: 	
152: 152: 
153: 153: 
154: 154: 
155: 155: 	function createAccount () noEther returns (DaoAccount account) {
156: 156: 		address accountOwner = msg.sender;
157: 157: 		address challengeOwner = owner; 
158: 158: 
159: 159: 		
160: 160: 		if(daoAccounts[accountOwner] != DaoAccount(0x00)) throw;
161: 161: 
162: 162: 		daoAccounts[accountOwner] = new DaoAccount(accountOwner, challengeOwner);
163: 163: 		return daoAccounts[accountOwner];
164: 164: 	}
165: 165: 
166: 166: 	function myAccount () noEther returns (DaoAccount) {
167: 167: 		address accountOwner = msg.sender;
168: 168: 		return daoAccounts[accountOwner];
169: 169: 	}
170: 170: 
171: 171: 	
172: 172: 	function terminate() noEther onlyOwner {
173: 173: 		notifyTerminate(this.balance);
174: 174: 		suicide(owner);
175: 175: 	}
176: 176: }