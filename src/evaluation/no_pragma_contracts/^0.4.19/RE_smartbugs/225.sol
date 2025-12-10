1: 1: contract DSFalseFallback {
2: 2:     function() returns (bool) {
3: 3:         return false;
4: 4:     }
5: 5: }
6: 6: 
7: 7: contract DSBaseActor is DSActionStructUser {
8: 8:     
9: 9:     function tryExec(Action a) internal returns (bool call_ret) {
10: 10:         return a.target.call.value(a.value)(a.calldata);
11: 11:     }
12: 12:     function exec(Action a) internal {
13: 13:         if(!tryExec(a)) {
14: 14:             throw;
15: 15:         }
16: 16:     }
17: 17:     function tryExec( address target, bytes calldata, uint value)
18: 18:              internal
19: 19:              returns (bool call_ret)
20: 20:     {
21: 21:         return target.call.value(value)(calldata);
22: 22:     }
23: 23:     function exec( address target, bytes calldata, uint value)
24: 24:              internal
25: 25:     {
26: 26:         if(!tryExec(target, calldata, value)) {
27: 27:             throw;
28: 28:         }
29: 29:     }
30: 30: }
31: 31: 