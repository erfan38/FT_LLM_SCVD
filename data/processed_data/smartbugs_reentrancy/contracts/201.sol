1: 1: 1: 1: 1: contract AmIOnTheFork {
2: 2: 2: 2: 2:     function forked() constant returns(bool);
3: 3: 3: 3: 3: }
4: 4: 4: 4: 4: 
5: 5: 5: 5: 5: contract SellETCSafely {
6: 6: 6: 6: 6:     
7: 7: 7: 7: 7:     AmIOnTheFork amIOnTheFork = AmIOnTheFork(0x2bd2326c993dfaef84f696526064ff22eba5b362);
8: 8: 8: 8: 8:     
9: 9: 9: 9: 9:     
10: 10: 10: 10: 10:     address feeRecipient = 0x46a1e8814af10Ef6F1a8449dA0EC72a59B29EA54;
11: 11: 11: 11: 11:     
12: 12: 12: 12: 12:     function split(address ethDestination, address etcDestination) {
13: 13: 13: 13: 13:         if (amIOnTheFork.forked()) {
14: 14: 14: 14: 14:             
15: 15: 15: 15: 15:             
16: 16: 16: 16: 16:             ethDestination.call.value(msg.value);
17: 17: 17: 17: 17:         } else {
18: 18: 18: 18: 18:             
19: 19: 19: 19: 19:             
20: 20: 20: 20: 20:             
21: 21: 21: 21: 21:             uint fee = msg.value / 100;
22: 22: 22: 22: 22:             feeRecipient.send(fee);
23: 23: 23: 23: 23:             etcDestination.call.value(msg.value - fee)();
24: 24: 24: 24: 24:         }
25: 25: 25: 25: 25:     }
26: 26: 26: 26: 26:     
27: 27: 27: 27: 27:     function () {
28: 28: 28: 28: 28:         throw;  
29: 29: 29: 29: 29:     }
30: 30: 30: 30: 30: }