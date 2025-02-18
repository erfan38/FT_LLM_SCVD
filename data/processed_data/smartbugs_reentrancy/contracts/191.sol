1: 1: 1: 1: 1: pragma solidity ^0.4.24;
2: 2: 2: 2: 2: 
3: 3: 3: 3: 3: 
4: 4: 4: 4: 4: 
5: 5: 5: 5: 5: 
6: 6: 6: 6: 6: 
7: 7: 7: 7: 7: 
8: 8: 8: 8: 8: 
9: 9: 9: 9: 9: 
10: 10: 10: 10: 10: contract MultiChanger {
11: 11: 11: 11: 11:     using SafeMath for uint256;
12: 12: 12: 12: 12:     using CheckedERC20 for ERC20;
13: 13: 13: 13: 13:     using ExternalCall for address;
14: 14: 14: 14: 14: 
15: 15: 15: 15: 15:     function change(bytes callDatas, uint[] starts) public payable { 
16: 16: 16: 16: 16:         for (uint i = 0; i < starts.length - 1; i++) {
17: 17: 17: 17: 17:             require(address(this).externalCall(0, callDatas, starts[i], starts[i + 1] - starts[i]));
18: 18: 18: 18: 18:         }
19: 19: 19: 19: 19:     }
20: 20: 20: 20: 20: 
21: 21: 21: 21: 21:     
22: 22: 22: 22: 22: 
23: 23: 23: 23: 23:     function sendEthValue(address target, uint256 value) external {
24: 24: 24: 24: 24:         
25: 25: 25: 25: 25:         require(target.call.value(value)());
26: 26: 26: 26: 26:     }
27: 27: 27: 27: 27: 
28: 28: 28: 28: 28:     function sendEthProportion(address target, uint256 mul, uint256 div) external {
29: 29: 29: 29: 29:         uint256 value = address(this).balance.mul(mul).div(div);
30: 30: 30: 30: 30:         
31: 31: 31: 31: 31:         require(target.call.value(value)());
32: 32: 32: 32: 32:     }
33: 33: 33: 33: 33: 
34: 34: 34: 34: 34:     
35: 35: 35: 35: 35: 
36: 36: 36: 36: 36:     function depositEtherTokenAmount(IEtherToken etherToken, uint256 amount) external {
37: 37: 37: 37: 37:         etherToken.deposit.value(amount)();
38: 38: 38: 38: 38:     }
39: 39: 39: 39: 39: 
40: 40: 40: 40: 40:     function depositEtherTokenProportion(IEtherToken etherToken, uint256 mul, uint256 div) external {
41: 41: 41: 41: 41:         uint256 amount = address(this).balance.mul(mul).div(div);
42: 42: 42: 42: 42:         etherToken.deposit.value(amount)();
43: 43: 43: 43: 43:     }
44: 44: 44: 44: 44: 
45: 45: 45: 45: 45:     function withdrawEtherTokenAmount(IEtherToken etherToken, uint256 amount) external {
46: 46: 46: 46: 46:         etherToken.withdraw(amount);
47: 47: 47: 47: 47:     }
48: 48: 48: 48: 48: 
49: 49: 49: 49: 49:     function withdrawEtherTokenProportion(IEtherToken etherToken, uint256 mul, uint256 div) external {
50: 50: 50: 50: 50:         uint256 amount = etherToken.balanceOf(this).mul(mul).div(div);
51: 51: 51: 51: 51:         etherToken.withdraw(amount);
52: 52: 52: 52: 52:     }
53: 53: 53: 53: 53: 
54: 54: 54: 54: 54:     
55: 55: 55: 55: 55: 
56: 56: 56: 56: 56:     function transferTokenAmount(address target, ERC20 fromToken, uint256 amount) external {
57: 57: 57: 57: 57:         require(fromToken.asmTransfer(target, amount));
58: 58: 58: 58: 58:     }
59: 59: 59: 59: 59: 
60: 60: 60: 60: 60:     function transferTokenProportion(address target, ERC20 fromToken, uint256 mul, uint256 div) external {
61: 61: 61: 61: 61:         uint256 amount = fromToken.balanceOf(this).mul(mul).div(div);
62: 62: 62: 62: 62:         require(fromToken.asmTransfer(target, amount));
63: 63: 63: 63: 63:     }
64: 64: 64: 64: 64: 
65: 65: 65: 65: 65:     function transferFromTokenAmount(ERC20 fromToken, uint256 amount) external {
66: 66: 66: 66: 66:         require(fromToken.asmTransferFrom(tx.origin, this, amount));
67: 67: 67: 67: 67:     }
68: 68: 68: 68: 68: 
69: 69: 69: 69: 69:     function transferFromTokenProportion(ERC20 fromToken, uint256 mul, uint256 div) external {
70: 70: 70: 70: 70:         uint256 amount = fromToken.balanceOf(this).mul(mul).div(div);
71: 71: 71: 71: 71:         require(fromToken.asmTransferFrom(tx.origin, this, amount));
72: 72: 72: 72: 72:     }
73: 73: 73: 73: 73: 
74: 74: 74: 74: 74:     
75: 75: 75: 75: 75: 
76: 76: 76: 76: 76:     function multitokenChangeAmount(IMultiToken mtkn, ERC20 fromToken, ERC20 toToken, uint256 minReturn, uint256 amount) external {
77: 77: 77: 77: 77:         if (fromToken.allowance(this, mtkn) == 0) {
78: 78: 78: 78: 78:             fromToken.asmApprove(mtkn, uint256(-1));
79: 79: 79: 79: 79:         }
80: 80: 80: 80: 80:         mtkn.change(fromToken, toToken, amount, minReturn);
81: 81: 81: 81: 81:     }
82: 82: 82: 82: 82: 
83: 83: 83: 83: 83:     function multitokenChangeProportion(IMultiToken mtkn, ERC20 fromToken, ERC20 toToken, uint256 minReturn, uint256 mul, uint256 div) external {
84: 84: 84: 84: 84:         uint256 amount = fromToken.balanceOf(this).mul(mul).div(div);
85: 85: 85: 85: 85:         this.multitokenChangeAmount(mtkn, fromToken, toToken, minReturn, amount);
86: 86: 86: 86: 86:     }
87: 87: 87: 87: 87: }