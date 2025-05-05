1: 1: pragma solidity ^0.4.2;
2: 2: 
3: 3: 
4: 4: 
5: 5: 
6: 6: contract PullPaymentCapable {
7: 7:     uint256 private totalBalance;
8: 8:     mapping(address => uint256) private payments;
9: 9: 
10: 10:     event LogPaymentReceived(address indexed dest, uint256 amount);
11: 11: 
12: 12:     function PullPaymentCapable() {
13: 13:         if (0 < this.balance) {
14: 14:             asyncSend(msg.sender, this.balance);
15: 15:         }
16: 16:     }
17: 17: 
18: 18:     
19: 19:     function asyncSend(address dest, uint256 amount) internal {
20: 20:         if (amount > 0) {
21: 21:             totalBalance += amount;
22: 22:             payments[dest] += amount;
23: 23:             LogPaymentReceived(dest, amount);
24: 24:         }
25: 25:     }
26: 26: 
27: 27:     function getTotalBalance()
28: 28:         constant
29: 29:         returns (uint256) {
30: 30:         return totalBalance;
31: 31:     }
32: 32: 
33: 33:     function getPaymentOf(address beneficiary) 
34: 34:         constant
35: 35:         returns (uint256) {
36: 36:         return payments[beneficiary];
37: 37:     }
38: 38: 
39: 39:     
40: 40:     function withdrawPayments()
41: 41:         external 
42: 42:         returns (bool success) {
43: 43:         uint256 payment = payments[msg.sender];
44: 44:         payments[msg.sender] = 0;
45: 45:         totalBalance -= payment;
46: 46:         if (!msg.sender.call.value(payment)()) {
47: 47:             throw;
48: 48:         }
49: 49:         success = true;
50: 50:     }
51: 51: 
52: 52:     function fixBalance()
53: 53:         returns (bool success);
54: 54: 
55: 55:     function fixBalanceInternal(address dest)
56: 56:         internal
57: 57:         returns (bool success) {
58: 58:         if (totalBalance < this.balance) {
59: 59:             uint256 amount = this.balance - totalBalance;
60: 60:             payments[dest] += amount;
61: 61:             LogPaymentReceived(dest, amount);
62: 62:         }
63: 63:         return true;
64: 64:     }
65: 65: }
66: 66: 
67: 67: 