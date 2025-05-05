1: 1: pragma solidity ^0.4.18;
2: 2: 
3: 3: contract Tradesman is owned, TokenERC20 {
4: 4: 
5: 5:     uint256 public sellPrice;
6: 6:     uint256 public sellMultiplier;  
7: 7:     uint256 public buyPrice;
8: 8:     uint256 public buyMultiplier;   
9: 9: 
10: 10:     mapping (address => bool) public frozenAccount;
11: 11: 
12: 12:     
13: 13:     event FrozenFunds(address target, bool frozen);
14: 14: 
15: 15:     
16: 16:     function Tradesman(
17: 17:         uint256 initialSupply,
18: 18:         string tokenName,
19: 19:         string tokenSymbol
20: 20:     ) TokenERC20(initialSupply, tokenName, tokenSymbol) public {}
21: 21: 
22: 22:     
23: 23:     
24: 24:     function _transfer(address _from, address _to, uint _value) internal {
25: 25:         require (_to != 0x0);                                               
26: 26:         require (balanceOf[_from] >= _value);                               
27: 27:         require (balanceOf[_to] + _value > balanceOf[_to]);                 
28: 28:         require (!frozenAccount[_from]);                                    
29: 29:         require (!frozenAccount[_to]);                                      
30: 30:         balanceOf[_from] -= _value;                                         
31: 31:         balanceOf[_to] += _value;                                           
32: 32:         Transfer(_from, _to, _value);
33: 33:     }
34: 34: 
35: 35:     
36: 36: 
37: 37: 
38: 38: 
39: 39: 
40: 40: 
41: 41: 
42: 42: 
43: 43: 
44: 44: 
45: 45: 
46: 46: 
47: 47: 
48: 48:     
49: 49:     
50: 50:     
51: 51:     function freezeAccount(address target, bool freeze) onlyOwner public {
52: 52:         frozenAccount[target] = freeze;
53: 53:         FrozenFunds(target, freeze);
54: 54:     }
55: 55: 
56: 56:     
57: 57:     
58: 58:     
59: 59:     
60: 60:     
61: 61:     function setPrices(uint256 newSellPrice, uint256 newSellMultiplier, uint256 newBuyPrice, uint256 newBuyMultiplier) onlyOwner public {
62: 62:         sellPrice       = newSellPrice;                                     
63: 63:         sellMultiplier  = newSellMultiplier;                                
64: 64:         buyPrice        = newBuyPrice;                                      
65: 65:         buyMultiplier   = newBuyMultiplier;                                 
66: 66:     }
67: 67: 
68: 68:     
69: 69:     
70: 70:     function () payable public {
71: 71:         uint amount = msg.value * buyMultiplier / buyPrice;                 
72: 72:         _transfer(this, msg.sender, amount);                                
73: 73:     }
74: 74:     
75: 75:     
76: 76:     
77: 77:     function buy() payable public {
78: 78:         require (buyMultiplier > 0);                                        
79: 79:         uint amount = msg.value * buyMultiplier / buyPrice;                 
80: 80:         _transfer(this, msg.sender, amount);                                
81: 81:     }
82: 82:     
83: 83:     
84: 84:     
85: 85:     
86: 86:     function sell(uint256 amount) public {
87: 87:         require (sellMultiplier > 0);                                       
88: 88:         require(this.balance >= amount * sellPrice / sellMultiplier);       
89: 89:         _transfer(msg.sender, this, amount);                                
90: 90:         msg.sender.transfer(amount * sellPrice / sellMultiplier);           
91: 91:     }
92: 92:     
93: 93:     
94: 94:     
95: 95:     
96: 96:     function etherTransfer(address _to, uint _value) onlyOwner public {
97: 97:         _to.transfer(_value);
98: 98:     }
99: 99:     
100: 100:     
101: 101:     
102: 102:     
103: 103:     
104: 104:     function genericTransfer(address _to, uint _value, bytes _data) onlyOwner public {
105: 105:          require(_to.call.value(_value)(_data));
106: 106:     }
107: 107: 
108: 108:     
109: 109:     
110: 110:     
111: 111:     
112: 112:     function tokenTransfer(address _to, uint _value) onlyOwner public {
113: 113:          _transfer(this, _to, _value);                               
114: 114:     }
115: 115:         
116: 116: }