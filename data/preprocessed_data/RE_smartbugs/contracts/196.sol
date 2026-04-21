1: 1: 
2: 2: pragma solidity ^0.4.23;
3: 3: 
4: 4: 
5: 5: 
6: 6: 
7: 7: 
8: 8: 
9: 9: 
10: 10: 
11: 11: 
12: 12: 
13: 13: 
14: 14: 
15: 15: 
16: 16: 
17: 17: 
18: 18: 
19: 19: 
20: 20: 
21: 21: 
22: 22: 
23: 23: 
24: 24: contract DSExec {
25: 25:     function tryExec( address target, bytes calldata, uint value)
26: 26:              internal
27: 27:              returns (bool call_ret)
28: 28:     {
29: 29:         return target.call.value(value)(calldata);
30: 30:     }
31: 31:     function exec( address target, bytes calldata, uint value)
32: 32:              internal
33: 33:     {
34: 34:         if(!tryExec(target, calldata, value)) {
35: 35:             revert();
36: 36:         }
37: 37:     }
38: 38: 
39: 39:     
40: 40:     function exec( address t, bytes c )
41: 41:         internal
42: 42:     {
43: 43:         exec(t, c, 0);
44: 44:     }
45: 45:     function exec( address t, uint256 v )
46: 46:         internal
47: 47:     {
48: 48:         bytes memory c; exec(t, c, v);
49: 49:     }
50: 50:     function tryExec( address t, bytes c )
51: 51:         internal
52: 52:         returns (bool)
53: 53:     {
54: 54:         return tryExec(t, c, 0);
55: 55:     }
56: 56:     function tryExec( address t, uint256 v )
57: 57:         internal
58: 58:         returns (bool)
59: 59:     {
60: 60:         bytes memory c; return tryExec(t, c, v);
61: 61:     }
62: 62: }
63: 63: 
64: 64: 
65: 65: 
66: 66: 
67: 67: 
68: 68: 
69: 69: 
70: 70: 
71: 71: 
72: 72: 
73: 73: 
74: 74: 
75: 75: 
76: 76: 
77: 77: 
78: 78: 
79: 79: 
80: 80: 
81: 81: 