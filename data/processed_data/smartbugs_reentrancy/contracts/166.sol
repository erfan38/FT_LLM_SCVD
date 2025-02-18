1: 1: pragma solidity ^0.4.16;
2: 2: 
3: 3: contract OasisDirectProxy is DSMath {
4: 4:     function withdrawAndSend(TokenInterface wethToken, uint wethAmt) internal {
5: 5:         wethToken.withdraw(wethAmt);
6: 6:         require(msg.sender.call.value(wethAmt)());
7: 7:     }
8: 8: 
9: 9:     function sellAllAmount(OtcInterface otc, TokenInterface payToken, uint payAmt, TokenInterface buyToken, uint minBuyAmt) public returns (uint buyAmt) {
10: 10:         require(payToken.transferFrom(msg.sender, this, payAmt));
11: 11:         if (payToken.allowance(this, otc) < payAmt) {
12: 12:             payToken.approve(otc, uint(-1));
13: 13:         }
14: 14:         buyAmt = otc.sellAllAmount(payToken, payAmt, buyToken, minBuyAmt);
15: 15:         require(buyToken.transfer(msg.sender, buyAmt));
16: 16:     }
17: 17: 
18: 18:     function sellAllAmountPayEth(OtcInterface otc, TokenInterface wethToken, TokenInterface buyToken, uint minBuyAmt) public payable returns (uint buyAmt) {
19: 19:         wethToken.deposit.value(msg.value)();
20: 20:         if (wethToken.allowance(this, otc) < msg.value) {
21: 21:             wethToken.approve(otc, uint(-1));
22: 22:         }
23: 23:         buyAmt = otc.sellAllAmount(wethToken, msg.value, buyToken, minBuyAmt);
24: 24:         require(buyToken.transfer(msg.sender, buyAmt));
25: 25:     }
26: 26: 
27: 27:     function sellAllAmountBuyEth(OtcInterface otc, TokenInterface payToken, uint payAmt, TokenInterface wethToken, uint minBuyAmt) public returns (uint wethAmt) {
28: 28:         require(payToken.transferFrom(msg.sender, this, payAmt));
29: 29:         if (payToken.allowance(this, otc) < payAmt) {
30: 30:             payToken.approve(otc, uint(-1));
31: 31:         }
32: 32:         wethAmt = otc.sellAllAmount(payToken, payAmt, wethToken, minBuyAmt);
33: 33:         withdrawAndSend(wethToken, wethAmt);
34: 34:     }
35: 35: 
36: 36:     function buyAllAmount(OtcInterface otc, TokenInterface buyToken, uint buyAmt, TokenInterface payToken, uint maxPayAmt) public returns (uint payAmt) {
37: 37:         uint payAmtNow = otc.getPayAmount(payToken, buyToken, buyAmt);
38: 38:         require(payAmtNow <= maxPayAmt);
39: 39:         require(payToken.transferFrom(msg.sender, this, payAmtNow));
40: 40:         if (payToken.allowance(this, otc) < payAmtNow) {
41: 41:             payToken.approve(otc, uint(-1));
42: 42:         }
43: 43:         payAmt = otc.buyAllAmount(buyToken, buyAmt, payToken, payAmtNow);
44: 44:         require(buyToken.transfer(msg.sender, min(buyAmt, buyToken.balanceOf(this)))); 
45: 45:     }
46: 46: 
47: 47:     function buyAllAmountPayEth(OtcInterface otc, TokenInterface buyToken, uint buyAmt, TokenInterface wethToken) public payable returns (uint wethAmt) {
48: 48:         
49: 49:         wethToken.deposit.value(msg.value)();
50: 50:         if (wethToken.allowance(this, otc) < msg.value) {
51: 51:             wethToken.approve(otc, uint(-1));
52: 52:         }
53: 53:         wethAmt = otc.buyAllAmount(buyToken, buyAmt, wethToken, msg.value);
54: 54:         require(buyToken.transfer(msg.sender, min(buyAmt, buyToken.balanceOf(this)))); 
55: 55:         withdrawAndSend(wethToken, sub(msg.value, wethAmt));
56: 56:     }
57: 57: 
58: 58:     function buyAllAmountBuyEth(OtcInterface otc, TokenInterface wethToken, uint wethAmt, TokenInterface payToken, uint maxPayAmt) public returns (uint payAmt) {
59: 59:         uint payAmtNow = otc.getPayAmount(payToken, wethToken, wethAmt);
60: 60:         require(payAmtNow <= maxPayAmt);
61: 61:         require(payToken.transferFrom(msg.sender, this, payAmtNow));
62: 62:         if (payToken.allowance(this, otc) < payAmtNow) {
63: 63:             payToken.approve(otc, uint(-1));
64: 64:         }
65: 65:         payAmt = otc.buyAllAmount(wethToken, wethAmt, payToken, payAmtNow);
66: 66:         withdrawAndSend(wethToken, wethAmt);
67: 67:     }
68: 68: 
69: 69:     function() public payable {}
70: 70: }