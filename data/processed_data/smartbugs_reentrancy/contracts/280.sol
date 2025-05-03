1: 1: pragma solidity ^0.4.24;
2: 2: 
3: 3: 
4: 4: 
5: 5: 
6: 6: 
7: 7: 
8: 8: 
9: 9: 
10: 10: contract ERC827Token is ERC827, StandardToken {
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
24: 24: 
25: 25: 
26: 26:     function approveAndCall(
27: 27:         address _spender,
28: 28:         uint256 _value,
29: 29:         bytes _data
30: 30:     )
31: 31:     public
32: 32:     payable
33: 33:     returns (bool)
34: 34:     {
35: 35:         require(_spender != address(this));
36: 36: 
37: 37:         super.approve(_spender, _value);
38: 38: 
39: 39:         
40: 40:         require(_spender.call.value(msg.value)(_data));
41: 41: 
42: 42:         return true;
43: 43:     }
44: 44: 
45: 45:   
46: 46: 
47: 47: 
48: 48: 
49: 49: 
50: 50: 
51: 51: 
52: 52: 
53: 53:     function transferAndCall(
54: 54:         address _to,
55: 55:         uint256 _value,
56: 56:         bytes _data
57: 57:     )
58: 58:     public
59: 59:     payable
60: 60:     returns (bool)
61: 61:     {
62: 62:         require(_to != address(this));
63: 63: 
64: 64:         super.transfer(_to, _value);
65: 65: 
66: 66:         
67: 67:         require(_to.call.value(msg.value)(_data));
68: 68:         return true;
69: 69:     }
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
80: 80:     function transferFromAndCall(
81: 81:         address _from,
82: 82:         address _to,
83: 83:         uint256 _value,
84: 84:         bytes _data
85: 85:     )
86: 86:     public payable returns (bool)
87: 87:     {
88: 88:         require(_to != address(this));
89: 89: 
90: 90:         super.transferFrom(_from, _to, _value);
91: 91: 
92: 92:         
93: 93:         require(_to.call.value(msg.value)(_data));
94: 94:         return true;
95: 95:     }
96: 96: 
97: 97:   
98: 98: 
99: 99: 
100: 100: 
101: 101: 
102: 102: 
103: 103: 
104: 104: 
105: 105: 
106: 106: 
107: 107: 
108: 108:     function increaseApprovalAndCall(
109: 109:         address _spender,
110: 110:         uint _addedValue,
111: 111:         bytes _data
112: 112:     )
113: 113:     public
114: 114:     payable
115: 115:     returns (bool)
116: 116:     {
117: 117:         require(_spender != address(this));
118: 118: 
119: 119:         super.increaseApproval(_spender, _addedValue);
120: 120: 
121: 121:         
122: 122:         require(_spender.call.value(msg.value)(_data));
123: 123: 
124: 124:         return true;
125: 125:     }
126: 126: 
127: 127:   
128: 128: 
129: 129: 
130: 130: 
131: 131: 
132: 132: 
133: 133: 
134: 134: 
135: 135: 
136: 136: 
137: 137: 
138: 138:     function decreaseApprovalAndCall(
139: 139:         address _spender,
140: 140:         uint _subtractedValue,
141: 141:         bytes _data
142: 142:     )
143: 143:     public
144: 144:     payable
145: 145:     returns (bool)
146: 146:     {
147: 147:         require(_spender != address(this));
148: 148: 
149: 149:         super.decreaseApproval(_spender, _subtractedValue);
150: 150: 
151: 151:         
152: 152:         require(_spender.call.value(msg.value)(_data));
153: 153: 
154: 154:         return true;
155: 155:     }
156: 156: 
157: 157: }
158: 158: 
159: 159: 
160: 160: 
161: 161: 
162: 162: 
163: 163: 