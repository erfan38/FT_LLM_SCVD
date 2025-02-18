1: contract DSNote {
2:     event LogNote(
3:         bytes4   indexed  sig,
4:         address  indexed  guy,
5:         bytes32  indexed  foo,
6:         bytes32  indexed  bar,
7: 	uint	 	  wad,
8:         bytes             fax
9:     ) anonymous;
10: 
11:     modifier note {
12:         bytes32 foo;
13:         bytes32 bar;
14: 
15:         assembly {
16:             foo := calldataload(4)
17:             bar := calldataload(36)
18:         }
19: 
20:         LogNote(msg.sig, msg.sender, foo, bar, msg.value, msg.data);
21: 
22:         _;
23:     }
24: }
25: 
26: contract DSExec {
27:     function tryExec( address target, bytes calldata, uint value)
28:              internal
29:              returns (bool call_ret)
30:     {
31:         return target.call.value(value)(calldata);
32:     }
33:     function exec( address target, bytes calldata, uint value)
34:              internal
35:     {
36:         if(!tryExec(target, calldata, value)) {
37:             throw;
38:         }
39:     }
40: 
41:     
42:     function exec( address t, bytes c )
43:         internal
44:     {
45:         exec(t, c, 0);
46:     }
47:     function exec( address t, uint256 v )
48:         internal
49:     {
50:         bytes memory c; exec(t, c, v);
51:     }
52:     function tryExec( address t, bytes c )
53:         internal
54:         returns (bool)
55:     {
56:         return tryExec(t, c, 0);
57:     }
58:     function tryExec( address t, uint256 v )
59:         internal
60:         returns (bool)
61:     {
62:         bytes memory c; return tryExec(t, c, v);
63:     }
64: }
65: 