1: contract Whitelist {
2:     address public owner;
3:     address public sale;
4: 
5:     mapping (address => uint) public accepted;
6: 
7:     function Whitelist() {
8:         owner = msg.sender;
9:     }
10: 
11:     
12:     function accept(address a, uint amount) {
13:         assert (msg.sender == owner || msg.sender == sale);
14: 
15:         accepted[a] = amount;
16:     }
17: 
18:     function setSale(address sale_) {
19:         assert (msg.sender == owner);
20: 
21:         sale = sale_;
22:     } 
23: }
24: 
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
66: 
67: 