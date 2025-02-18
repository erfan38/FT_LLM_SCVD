1: 1: pragma solidity ^0.4.4;
2: 2: 
3: 3: contract FunFairSale is Owned, TokenReceivable {
4: 4:     uint public deadline = 1499436000;
5: 5:     uint public startTime = 1498140000;
6: 6:     uint public capAmount;
7: 7: 
8: 8:     function FunFairSale() {}
9: 9: 
10: 10:     function setSoftCapDeadline(uint t) onlyOwner {
11: 11:         if (t > deadline) throw;
12: 12:         deadline = t;
13: 13:     }
14: 14: 
15: 15:     function launch(uint _cap) onlyOwner {
16: 16:         capAmount = _cap;
17: 17:     }
18: 18: 
19: 19:     function () payable {
20: 20:         if (block.timestamp < startTime || block.timestamp >= deadline) throw;
21: 21: 
22: 22:         if (this.balance > capAmount) {
23: 23:             deadline = block.timestamp - 1;
24: 24:         }
25: 25:     }
26: 26: 
27: 27:     function withdraw() onlyOwner {
28: 28:         if (block.timestamp < deadline) throw;
29: 29: 
30: 30:         
31: 31:         
32: 32:         if (!owner.call.value(this.balance)()) throw;
33: 33:     }
34: 34: 
35: 35:     function setStartTime(uint _startTime, uint _deadline) onlyOwner {
36: 36:         if (block.timestamp >= startTime) throw;
37: 37:         startTime = _startTime;
38: 38:         deadline = _deadline;
39: 39:     }
40: 40: 
41: 41: }