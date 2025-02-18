1: 1: 1: 1: 1: pragma solidity ^0.4.13;
2: 2: 2: 2: 2: 
3: 3: 3: 3: 3: interface FundInterface {
4: 4: 4: 4: 4: 
5: 5: 5: 5: 5:     
6: 6: 6: 6: 6: 
7: 7: 7: 7: 7:     event PortfolioContent(address[] assets, uint[] holdings, uint[] prices);
8: 8: 8: 8: 8:     event RequestUpdated(uint id);
9: 9: 9: 9: 9:     event Redeemed(address indexed ofParticipant, uint atTimestamp, uint shareQuantity);
10: 10: 10: 10: 10:     event FeesConverted(uint atTimestamp, uint shareQuantityConverted, uint unclaimed);
11: 11: 11: 11: 11:     event CalculationUpdate(uint atTimestamp, uint managementFee, uint performanceFee, uint nav, uint sharePrice, uint totalSupply);
12: 12: 12: 12: 12:     event ErrorMessage(string errorMessage);
13: 13: 13: 13: 13: 
14: 14: 14: 14: 14:     
15: 15: 15: 15: 15:     
16: 16: 16: 16: 16:     function requestInvestment(uint giveQuantity, uint shareQuantity, address investmentAsset) external;
17: 17: 17: 17: 17:     function executeRequest(uint requestId) external;
18: 18: 18: 18: 18:     function cancelRequest(uint requestId) external;
19: 19: 19: 19: 19:     function redeemAllOwnedAssets(uint shareQuantity) external returns (bool);
20: 20: 20: 20: 20:     
21: 21: 21: 21: 21:     function enableInvestment(address[] ofAssets) external;
22: 22: 22: 22: 22:     function disableInvestment(address[] ofAssets) external;
23: 23: 23: 23: 23:     function shutDown() external;
24: 24: 24: 24: 24: 
25: 25: 25: 25: 25:     
26: 26: 26: 26: 26:     function emergencyRedeem(uint shareQuantity, address[] requestedAssets) public returns (bool success);
27: 27: 27: 27: 27:     function calcSharePriceAndAllocateFees() public returns (uint);
28: 28: 28: 28: 28: 
29: 29: 29: 29: 29: 
30: 30: 30: 30: 30:     
31: 31: 31: 31: 31:     
32: 32: 32: 32: 32:     function getModules() view returns (address, address, address);
33: 33: 33: 33: 33:     function getLastRequestId() view returns (uint);
34: 34: 34: 34: 34:     function getManager() view returns (address);
35: 35: 35: 35: 35: 
36: 36: 36: 36: 36:     
37: 37: 37: 37: 37:     function performCalculations() view returns (uint, uint, uint, uint, uint, uint, uint);
38: 38: 38: 38: 38:     function calcSharePrice() view returns (uint);
39: 39: 39: 39: 39: }
40: 40: 40: 40: 40: 
41: 41: 41: 41: 41: interface AssetInterface {
42: 42: 42: 42: 42:     
43: 43: 43: 43: 43: 
44: 44: 44: 44: 44: 
45: 45: 45: 45: 45: 
46: 46: 46: 46: 46: 
47: 47: 47: 47: 47: 
48: 48: 48: 48: 48: 
49: 49: 49: 49: 49: 
50: 50: 50: 50: 50: 
51: 51: 51: 51: 51:     
52: 52: 52: 52: 52:     event Approval(address indexed _owner, address indexed _spender, uint _value);
53: 53: 53: 53: 53: 
54: 54: 54: 54: 54:     
55: 55: 55: 55: 55: 
56: 56: 56: 56: 56:     
57: 57: 57: 57: 57:     
58: 58: 58: 58: 58:     function transfer(address _to, uint _value, bytes _data) public returns (bool success);
59: 59: 59: 59: 59: 
60: 60: 60: 60: 60:     
61: 61: 61: 61: 61:     
62: 62: 62: 62: 62:     function transfer(address _to, uint _value) public returns (bool success);
63: 63: 63: 63: 63:     function transferFrom(address _from, address _to, uint _value) public returns (bool success);
64: 64: 64: 64: 64:     function approve(address _spender, uint _value) public returns (bool success);
65: 65: 65: 65: 65:     
66: 66: 66: 66: 66:     function balanceOf(address _owner) view public returns (uint balance);
67: 67: 67: 67: 67:     function allowance(address _owner, address _spender) public view returns (uint remaining);
68: 68: 68: 68: 68: }
69: 69: 69: 69: 69: 
70: 70: 70: 70: 70: contract DSExec {
71: 71: 71: 71: 71:     function tryExec( address target, bytes calldata, uint value)
72: 72: 72: 72: 72:              internal
73: 73: 73: 73: 73:              returns (bool call_ret)
74: 74: 74: 74: 74:     {
75: 75: 75: 75: 75:         return target.call.value(value)(calldata);
76: 76: 76: 76: 76:     }
77: 77: 77: 77: 77:     function exec( address target, bytes calldata, uint value)
78: 78: 78: 78: 78:              internal
79: 79: 79: 79: 79:     {
80: 80: 80: 80: 80:         if(!tryExec(target, calldata, value)) {
81: 81: 81: 81: 81:             revert();
82: 82: 82: 82: 82:         }
83: 83: 83: 83: 83:     }
84: 84: 84: 84: 84: 
85: 85: 85: 85: 85:     
86: 86: 86: 86: 86:     function exec( address t, bytes c )
87: 87: 87: 87: 87:         internal
88: 88: 88: 88: 88:     {
89: 89: 89: 89: 89:         exec(t, c, 0);
90: 90: 90: 90: 90:     }
91: 91: 91: 91: 91:     function exec( address t, uint256 v )
92: 92: 92: 92: 92:         internal
93: 93: 93: 93: 93:     {
94: 94: 94: 94: 94:         bytes memory c; exec(t, c, v);
95: 95: 95: 95: 95:     }
96: 96: 96: 96: 96:     function tryExec( address t, bytes c )
97: 97: 97: 97: 97:         internal
98: 98: 98: 98: 98:         returns (bool)
99: 99: 99: 99: 99:     {
100: 100: 100: 100: 100:         return tryExec(t, c, 0);
101: 101: 101: 101: 101:     }
102: 102: 102: 102: 102:     function tryExec( address t, uint256 v )
103: 103: 103: 103: 103:         internal
104: 104: 104: 104: 104:         returns (bool)
105: 105: 105: 105: 105:     {
106: 106: 106: 106: 106:         bytes memory c; return tryExec(t, c, v);
107: 107: 107: 107: 107:     }
108: 108: 108: 108: 108: }
109: 109: 109: 109: 109: 