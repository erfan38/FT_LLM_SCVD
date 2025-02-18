1: pragma solidity ^0.4.24;
2: contract DSExec {
3:     function tryExec( address target, bytes calldata, uint value)
4:              internal
5:              returns (bool call_ret)
6:     {
7:         return target.call.value(value)(calldata);
8:     }
9:     function exec( address target, bytes calldata, uint value)
10:              internal
11:     {
12:         if(!tryExec(target, calldata, value)) {
13:             revert();
14:         }
15:     }
16: 
17:     
18:     function exec( address t, bytes c )
19:         internal
20:     {
21:         exec(t, c, 0);
22:     }
23:     function exec( address t, uint256 v )
24:         internal
25:     {
26:         bytes memory c; exec(t, c, v);
27:     }
28:     function tryExec( address t, bytes c )
29:         internal
30:         returns (bool)
31:     {
32:         return tryExec(t, c, 0);
33:     }
34:     function tryExec( address t, uint256 v )
35:         internal
36:         returns (bool)
37:     {
38:         bytes memory c; return tryExec(t, c, v);
39:     }
40: }
41: 