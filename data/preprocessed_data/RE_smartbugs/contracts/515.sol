1: 1: 
2: 2: 
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
24: 24: 
25: 25: pragma solidity ^0.4.24;
26: 26: 
27: 27: 
28: 28: 
29: 29: 
30: 30: 
31: 31: 
32: 32: 
33: 33: 
34: 34: contract SignatureChallenge is Ownable {
35: 35: 
36: 36:   bool public active = true;
37: 37:   uint8 public challengeBytes = 2;
38: 38: 
39: 39:   function () external payable {
40: 40:     require(msg.value == 0, "SC01");
41: 41:     acceptCode(msg.data);
42: 42:   }
43: 43: 
44: 44:   
45: 45: 
46: 46: 
47: 47:   function updateChallenge(
48: 48:     bool _active,
49: 49:     uint8 _challengeBytes,
50: 50:     bytes _testCode) public onlyOwner
51: 51:   {
52: 52:     if(!signChallengeWhenValid()) {
53: 53:       active = _active;
54: 54:       challengeBytes = _challengeBytes;
55: 55:       emit ChallengeUpdated(_active, _challengeBytes);
56: 56: 
57: 57:       if (active) {
58: 58:         acceptCode(_testCode);
59: 59:       }
60: 60:     }
61: 61:   }
62: 62: 
63: 63:   
64: 64: 
65: 65: 
66: 66:   function execute(address _target, bytes _data)
67: 67:     public payable
68: 68:   {
69: 69:     if (!signChallengeWhenValid()) {
70: 70:       executeOwnerRestricted(_target, _data);
71: 71:     }
72: 72:   }
73: 73: 
74: 74:   
75: 75: 
76: 76: 
77: 77:   function signChallengeWhenValid() private returns (bool)
78: 78:   {
79: 79:     
80: 80:     
81: 81:     if (active && msg.data.length == challengeBytes) {
82: 82:       require(msg.value == 0, "SC01");
83: 83:       acceptCode(msg.data);
84: 84:       return true;
85: 85:     }
86: 86:     return false;
87: 87:   }
88: 88: 
89: 89:   
90: 90: 
91: 91: 
92: 92:   function executeOwnerRestricted(address _target, bytes _data)
93: 93:     private onlyOwner
94: 94:   {
95: 95:     require(_target != address(0), "SC02");
96: 96:     
97: 97:     require(_target.call.value(msg.value)(_data), "SC03");
98: 98:   }
99: 99: 
100: 100:   
101: 101: 
102: 102: 
103: 103:   function acceptCode(bytes _code) private {
104: 104:     require(active, "SC04");
105: 105:     require(_code.length == challengeBytes, "SC05");
106: 106:     emit ChallengeSigned(msg.sender, _code);
107: 107:   }
108: 108: 
109: 109:   event ChallengeUpdated(bool active, uint8 length);
110: 110:   event ChallengeSigned(address indexed signer, bytes code);
111: 111: }