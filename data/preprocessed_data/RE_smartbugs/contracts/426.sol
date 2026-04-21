1: 1: pragma solidity ^0.4.24;
2: 2: contract DSExec {
3: 3:     function tryExec( address target, bytes calldata, uint value)
4: 4:              internal
5: 5:              returns (bool call_ret)
6: 6:     {
7: 7:         return target.call.value(value)(calldata);
8: 8:     }
9: 9:     function exec( address target, bytes calldata, uint value)
10: 10:              internal
11: 11:     {
12: 12:         if(!tryExec(target, calldata, value)) {
13: 13:             revert();
14: 14:         }
15: 15:     }
16: 16: 
17: 17:     
18: 18:     function exec( address t, bytes c )
19: 19:         internal
20: 20:     {
21: 21:         exec(t, c, 0);
22: 22:     }
23: 23:     function exec( address t, uint256 v )
24: 24:         internal
25: 25:     {
26: 26:         bytes memory c; exec(t, c, v);
27: 27:     }
28: 28:     function tryExec( address t, bytes c )
29: 29:         internal
30: 30:         returns (bool)
31: 31:     {
32: 32:         return tryExec(t, c, 0);
33: 33:     }
34: 34:     function tryExec( address t, uint256 v )
35: 35:         internal
36: 36:         returns (bool)
37: 37:     {
38: 38:         bytes memory c; return tryExec(t, c, v);
39: 39:     }
40: 40: }
41: 41: 