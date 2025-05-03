1: 1: pragma solidity ^0.4.13;
2: 2: 
3: 3: contract DSExec {
4: 4:     function tryExec( address target, bytes calldata, uint value)
5: 5:              internal
6: 6:              returns (bool call_ret)
7: 7:     {
8: 8:         return target.call.value(value)(calldata);
9: 9:     }
10: 10:     function exec( address target, bytes calldata, uint value)
11: 11:              internal
12: 12:     {
13: 13:         if(!tryExec(target, calldata, value)) {
14: 14:             revert();
15: 15:         }
16: 16:     }
17: 17: 
18: 18:     
19: 19:     function exec( address t, bytes c )
20: 20:         internal
21: 21:     {
22: 22:         exec(t, c, 0);
23: 23:     }
24: 24:     function exec( address t, uint256 v )
25: 25:         internal
26: 26:     {
27: 27:         bytes memory c; exec(t, c, v);
28: 28:     }
29: 29:     function tryExec( address t, bytes c )
30: 30:         internal
31: 31:         returns (bool)
32: 32:     {
33: 33:         return tryExec(t, c, 0);
34: 34:     }
35: 35:     function tryExec( address t, uint256 v )
36: 36:         internal
37: 37:         returns (bool)
38: 38:     {
39: 39:         bytes memory c; return tryExec(t, c, v);
40: 40:     }
41: 41: }
42: 42: 