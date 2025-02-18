1: 1: pragma solidity ^0.4.18;
2: 2: 
3: 3: 
4: 4: 
5: 5: contract IChain is StandardToken {
6: 6:   string public name = 'IChain';
7: 7:   string public symbol = 'ISC';
8: 8:   uint8 public decimals = 18;
9: 9:   uint public INITIAL_SUPPLY = 210000000 ether;
10: 10:   
11: 11:    address public beneficiary;  
12: 12:    address public owner; 
13: 13:    
14: 14:     uint256 public fundingGoal ;   
15: 15: 	
16: 16:     uint256 public amountRaised ;   
17: 17: 	
18: 18: 	uint256 public amountRaisedIsc ;  
19: 19:   
20: 20:   
21: 21:   uint256 public price;
22: 22:   
23: 23:   uint256 public totalDistributed = 157500000 ether;
24: 24:   
25: 25:   uint256 public totalRemaining;
26: 26: 
27: 27:   
28: 28:   uint256 public tokenReward = INITIAL_SUPPLY.sub(totalDistributed);
29: 29: 
30: 30:      bool public fundingGoalReached = true;  
31: 31:      bool public crowdsaleClosed = true;  
32: 32:   
33: 33:    event Transfer(address indexed _from, address indexed _to, uint256 _value);
34: 34:    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
35: 35:    event Distr(address indexed to, uint256 amount);
36: 36:   
37: 37:   function IChain(address ifSuccessfulSendTo,
38: 38:         uint fundingGoalInEthers,
39: 39: 		uint _price
40: 40:          ) public {
41: 41: 			totalSupply_ = INITIAL_SUPPLY;
42: 42: 			beneficiary = ifSuccessfulSendTo;
43: 43:             fundingGoal = fundingGoalInEthers * 1 ether;       
44: 44:             price = _price;          
45: 45: 			owner = msg.sender;
46: 46: 			balances[msg.sender] = totalDistributed;
47: 47: 			
48: 48:   }
49: 49:  
50: 50:     modifier canDistr() {
51: 51:         require(!crowdsaleClosed);
52: 52:         _;
53: 53:     }
54: 54: 	  modifier onlyOwner() {
55: 55:         require(msg.sender == owner);
56: 56:         _;
57: 57:     }
58: 58:    
59: 59: 	
60: 60: 	
61: 61:    function () external payable {
62: 62: 		
63: 63: 		require(!crowdsaleClosed);
64: 64: 		require(!fundingGoalReached);
65: 65:         getTokens();
66: 66:      }	 
67: 67: 	
68: 68: 	
69: 69: 	
70: 70:   function finishDistribution() onlyOwner canDistr  public returns (bool) {
71: 71: 		
72: 72: 		
73: 73:         crowdsaleClosed = true;
74: 74: 		
75: 75: 		uint256 amount = tokenReward.sub(amountRaisedIsc);
76: 76: 		
77: 77: 		balances[beneficiary] = balances[beneficiary].add(amount);	
78: 78: 		
79: 79: 		emit Transfer(address(0), beneficiary, amount);
80: 80: 		require(msg.sender.call.value(amountRaised)());	
81: 81: 				
82: 82:         return true;
83: 83:     }	
84: 84: 	function StartDistribution() onlyOwner   public returns (bool) {		
85: 85: 		if(amountRaised == 0){
86: 86: 			crowdsaleClosed = false;
87: 87: 			fundingGoalReached = false;
88: 88: 			return true;
89: 89: 		}else{
90: 90: 			return;
91: 91: 		}		
92: 92:         
93: 93:     }	
94: 94: 
95: 95: 	
96: 96:   function getTokens() canDistr payable {
97: 97: 		
98: 98: 		if (amountRaised >= fundingGoal) {
99: 99:             fundingGoalReached = true;
100: 100: 			return;
101: 101:         } 			
102: 102:         address investor = msg.sender; 
103: 103: 		uint amount = msg.value;
104: 104:         distr(investor,amount);	
105: 105:     }
106: 106: 	
107: 107: 	function withdraw() onlyOwner public {
108: 108:         uint256 etherBalance = address(this).balance;
109: 109:         owner.transfer(etherBalance);
110: 110:     }
111: 111: 	 
112: 112:     function distr(address _to, uint256 _amount) canDistr private returns (bool) {
113: 113: 		
114: 114: 		amountRaised += _amount;				
115: 115: 		_amount=_amount.mul(price); 	
116: 116: 		amountRaisedIsc += _amount;		
117: 117:         balances[_to] = balances[_to].add(_amount);
118: 118: 		
119: 119: 		emit Distr(_to, _amount);
120: 120:         emit Transfer(address(0), _to, _amount);		  		
121: 121:         return true;           
122: 122: 		
123: 123:     }
124: 124: 
125: 125:   
126: 126: }