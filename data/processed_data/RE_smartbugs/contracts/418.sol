1: 1: 
2: 2: pragma solidity >=0.4.10;
3: 3: 
4: 4: 
5: 5: contract Receiver {
6: 6:     event StartSale();
7: 7:     event EndSale();
8: 8:     event EtherIn(address from, uint amount);
9: 9: 
10: 10:     address public owner;    
11: 11:     address public newOwner; 
12: 12:     string public notice;    
13: 13: 
14: 14:     Sale public sale;
15: 15: 
16: 16:     function Receiver() {
17: 17:         owner = msg.sender;
18: 18:     }
19: 19: 
20: 20:     modifier onlyOwner() {
21: 21:         require(msg.sender == owner);
22: 22:         _;
23: 23:     }
24: 24: 
25: 25:     modifier onlySale() {
26: 26:         require(msg.sender == address(sale));
27: 27:         _;
28: 28:     }
29: 29: 
30: 30:     function live() constant returns(bool) {
31: 31:         return sale.live();
32: 32:     }
33: 33: 
34: 34:     
35: 35:     function start() onlySale {
36: 36:         StartSale();
37: 37:     }
38: 38: 
39: 39:     
40: 40:     function end() onlySale {
41: 41:         EndSale();
42: 42:     }
43: 43: 
44: 44:     function () payable {
45: 45:         
46: 46:         EtherIn(msg.sender, msg.value);
47: 47:         require(sale.call.value(msg.value)());
48: 48:     }
49: 49: 
50: 50:     
51: 51:     function changeOwner(address next) onlyOwner {
52: 52:         newOwner = next;
53: 53:     }
54: 54: 
55: 55:     
56: 56:     function acceptOwnership() {
57: 57:         require(msg.sender == newOwner);
58: 58:         owner = msg.sender;
59: 59:         newOwner = 0;
60: 60:     }
61: 61: 
62: 62:     
63: 63:     function setNotice(string note) onlyOwner {
64: 64:         notice = note;
65: 65:     }
66: 66: 
67: 67:     
68: 68:     function setSale(address s) onlyOwner {
69: 69:         sale = Sale(s);
70: 70:     }
71: 71: 
72: 72:     
73: 73:     
74: 74:     
75: 75: 
76: 76:     
77: 77:     function withdrawToken(address token) onlyOwner {
78: 78:         Token t = Token(token);
79: 79:         require(t.transfer(msg.sender, t.balanceOf(this)));
80: 80:     }
81: 81: 
82: 82:     
83: 83:     function refundToken(address token, address sender, uint amount) onlyOwner {
84: 84:         Token t = Token(token);
85: 85:         require(t.transfer(sender, amount));
86: 86:     }
87: 87: }
88: 88: 