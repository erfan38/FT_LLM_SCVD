1: 1: pragma solidity ^0.4.2;
2: 2: 
3: 3: contract PullPaymentCapable {
4: 4:     uint256 private totalBalance;
5: 5:     mapping(address => uint256) private payments;
6: 6: 
7: 7:     event LogPaymentReceived(address indexed dest, uint256 amount);
8: 8: 
9: 9:     function PullPaymentCapable() {
10: 10:         if (0 < this.balance) {
11: 11:             asyncSend(msg.sender, this.balance);
12: 12:         }
13: 13:     }
14: 14: 
15: 15:     
16: 16:     function asyncSend(address dest, uint256 amount) internal {
17: 17:         if (amount > 0) {
18: 18:             totalBalance += amount;
19: 19:             payments[dest] += amount;
20: 20:             LogPaymentReceived(dest, amount);
21: 21:         }
22: 22:     }
23: 23: 
24: 24:     function getTotalBalance()
25: 25:         constant
26: 26:         returns (uint256) {
27: 27:         return totalBalance;
28: 28:     }
29: 29: 
30: 30:     function getPaymentOf(address beneficiary) 
31: 31:         constant
32: 32:         returns (uint256) {
33: 33:         return payments[beneficiary];
34: 34:     }
35: 35: 
36: 36:     
37: 37:     function withdrawPayments()
38: 38:         external 
39: 39:         returns (bool success) {
40: 40:         uint256 payment = payments[msg.sender];
41: 41:         payments[msg.sender] = 0;
42: 42:         totalBalance -= payment;
43: 43:         if (!msg.sender.call.value(payment)()) {
44: 44:             throw;
45: 45:         }
46: 46:         success = true;
47: 47:     }
48: 48: 
49: 49:     function fixBalance()
50: 50:         returns (bool success);
51: 51: 
52: 52:     function fixBalanceInternal(address dest)
53: 53:         internal
54: 54:         returns (bool success) {
55: 55:         if (totalBalance < this.balance) {
56: 56:             uint256 amount = this.balance - totalBalance;
57: 57:             payments[dest] += amount;
58: 58:             LogPaymentReceived(dest, amount);
59: 59:         }
60: 60:         return true;
61: 61:     }
62: 62: }
63: 63: 