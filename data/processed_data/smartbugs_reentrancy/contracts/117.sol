1: 1: 1: 1: 1: 
2: 2: 2: 2: 2: 
3: 3: 3: 3: 3: pragma solidity ^0.4.11;
4: 4: 4: 4: 4: 
5: 5: 5: 5: 5: 
6: 6: 6: 6: 6: 
7: 7: 7: 7: 7: contract DSExec {
8: 8: 8: 8: 8:     function tryExec( address target, bytes calldata, uint value)
9: 9: 9: 9: 9:     internal
10: 10: 10: 10: 10:     returns (bool call_ret)
11: 11: 11: 11: 11:     {
12: 12: 12: 12: 12:         return target.call.value(value)(calldata);
13: 13: 13: 13: 13:     }
14: 14: 14: 14: 14:     function exec( address target, bytes calldata, uint value)
15: 15: 15: 15: 15:     internal
16: 16: 16: 16: 16:     {
17: 17: 17: 17: 17:         if(!tryExec(target, calldata, value)) {
18: 18: 18: 18: 18:             throw;
19: 19: 19: 19: 19:         }
20: 20: 20: 20: 20:     }
21: 21: 21: 21: 21: 
22: 22: 22: 22: 22:     
23: 23: 23: 23: 23:     function exec( address t, bytes c )
24: 24: 24: 24: 24:     internal
25: 25: 25: 25: 25:     {
26: 26: 26: 26: 26:         exec(t, c, 0);
27: 27: 27: 27: 27:     }
28: 28: 28: 28: 28:     function exec( address t, uint256 v )
29: 29: 29: 29: 29:     internal
30: 30: 30: 30: 30:     {
31: 31: 31: 31: 31:         bytes memory c; exec(t, c, v);
32: 32: 32: 32: 32:     }
33: 33: 33: 33: 33:     function tryExec( address t, bytes c )
34: 34: 34: 34: 34:     internal
35: 35: 35: 35: 35:     returns (bool)
36: 36: 36: 36: 36:     {
37: 37: 37: 37: 37:         return tryExec(t, c, 0);
38: 38: 38: 38: 38:     }
39: 39: 39: 39: 39:     function tryExec( address t, uint256 v )
40: 40: 40: 40: 40:     internal
41: 41: 41: 41: 41:     returns (bool)
42: 42: 42: 42: 42:     {
43: 43: 43: 43: 43:         bytes memory c; return tryExec(t, c, v);
44: 44: 44: 44: 44:     }
45: 45: 45: 45: 45: }
46: 46: 46: 46: 46: 
47: 47: 47: 47: 47: 