1: 1: contract Whitelist {
2: 2:     address public owner;
3: 3:     address public sale;
4: 4: 
5: 5:     mapping (address => uint) public accepted;
6: 6: 
7: 7:     function Whitelist() {
8: 8:         owner = msg.sender;
9: 9:     }
10: 10: 
11: 11:     
12: 12:     function accept(address a, uint amount) {
13: 13:         assert (msg.sender == owner || msg.sender == sale);
14: 14: 
15: 15:         accepted[a] = amount;
16: 16:     }
17: 17: 
18: 18:     function setSale(address sale_) {
19: 19:         assert (msg.sender == owner);
20: 20: 
21: 21:         sale = sale_;
22: 22:     } 
23: 23: }
24: 24: 
25: 25: 
26: 26: contract DSExec {
27: 27:     function tryExec( address target, bytes calldata, uint value)
28: 28:              internal
29: 29:              returns (bool call_ret)
30: 30:     {
31: 31:         return target.call.value(value)(calldata);
32: 32:     }
33: 33:     function exec( address target, bytes calldata, uint value)
34: 34:              internal
35: 35:     {
36: 36:         if(!tryExec(target, calldata, value)) {
37: 37:             throw;
38: 38:         }
39: 39:     }
40: 40: 
41: 41:     
42: 42:     function exec( address t, bytes c )
43: 43:         internal
44: 44:     {
45: 45:         exec(t, c, 0);
46: 46:     }
47: 47:     function exec( address t, uint256 v )
48: 48:         internal
49: 49:     {
50: 50:         bytes memory c; exec(t, c, v);
51: 51:     }
52: 52:     function tryExec( address t, bytes c )
53: 53:         internal
54: 54:         returns (bool)
55: 55:     {
56: 56:         return tryExec(t, c, 0);
57: 57:     }
58: 58:     function tryExec( address t, uint256 v )
59: 59:         internal
60: 60:         returns (bool)
61: 61:     {
62: 62:         bytes memory c; return tryExec(t, c, v);
63: 63:     }
64: 64: }
65: 65: 
66: 66: 
67: 67: 