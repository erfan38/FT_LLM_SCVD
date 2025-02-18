1: 1: pragma solidity 0.4.20;
2: 2: 
3: 3: 
4: 4: 
5: 5: 
6: 6: 
7: 7: 
8: 8: 
9: 9: 
10: 10: contract UnsafeMultiplexor is Escapable(0, 0) {
11: 11:     function init(address _escapeHatchCaller, address _escapeHatchDestination) public {
12: 12:         require(escapeHatchCaller == 0);
13: 13:         require(_escapeHatchCaller != 0);
14: 14:         require(_escapeHatchDestination != 0);
15: 15:         escapeHatchCaller = _escapeHatchCaller;
16: 16:         escapeHatchDestination = _escapeHatchDestination;
17: 17:     }
18: 18:     
19: 19:     modifier sendBackLeftEther() {
20: 20:         uint balanceBefore = this.balance - msg.value;
21: 21:         _;
22: 22:         uint leftovers = this.balance - balanceBefore;
23: 23:         if (leftovers > 0) {
24: 24:             msg.sender.transfer(leftovers);
25: 25:         }
26: 26:     }
27: 27:     
28: 28:     function multiTransferTightlyPacked(bytes32[] _addressAndAmount) sendBackLeftEther() payable public returns(bool) {
29: 29:         for (uint i = 0; i < _addressAndAmount.length; i++) {
30: 30:             _unsafeTransfer(address(_addressAndAmount[i] >> 96), uint(uint96(_addressAndAmount[i])));
31: 31:         }
32: 32:         return true;
33: 33:     }
34: 34: 
35: 35:     function multiTransfer(address[] _address, uint[] _amount) sendBackLeftEther() payable public returns(bool) {
36: 36:         for (uint i = 0; i < _address.length; i++) {
37: 37:             _unsafeTransfer(_address[i], _amount[i]);
38: 38:         }
39: 39:         return true;
40: 40:     }
41: 41: 
42: 42:     function multiCallTightlyPacked(bytes32[] _addressAndAmount) sendBackLeftEther() payable public returns(bool) {
43: 43:         for (uint i = 0; i < _addressAndAmount.length; i++) {
44: 44:             _unsafeCall(address(_addressAndAmount[i] >> 96), uint(uint96(_addressAndAmount[i])));
45: 45:         }
46: 46:         return true;
47: 47:     }
48: 48: 
49: 49:     function multiCall(address[] _address, uint[] _amount) sendBackLeftEther() payable public returns(bool) {
50: 50:         for (uint i = 0; i < _address.length; i++) {
51: 51:             _unsafeCall(_address[i], _amount[i]);
52: 52:         }
53: 53:         return true;
54: 54:     }
55: 55: 
56: 56:     function _unsafeTransfer(address _to, uint _amount) internal {
57: 57:         require(_to != 0);
58: 58:         _to.send(_amount);
59: 59:     }
60: 60: 
61: 61:     function _unsafeCall(address _to, uint _amount) internal {
62: 62:         require(_to != 0);
63: 63:         _to.call.value(_amount)();
64: 64:     }
65: 65: }