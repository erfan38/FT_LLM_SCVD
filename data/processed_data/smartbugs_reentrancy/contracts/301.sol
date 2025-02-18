1: 1: 1: 1: 1: pragma solidity ^0.5.8;
2: 2: 2: 2: 2: 
3: 3: 3: 3: 3: interface ERC20 {
4: 4: 4: 4: 4:     function transfer(address _to, uint256 _value) external returns (bool);
5: 5: 5: 5: 5: }
6: 6: 6: 6: 6: 
7: 7: 7: 7: 7: contract Lock is Ownable {
8: 8: 8: 8: 8:     uint256 public constant MAX_LOCK_JUMP = 86400 * 365; 
9: 9: 9: 9: 9: 
10: 10: 10: 10: 10:     uint256 public lock;
11: 11: 11: 11: 11: 
12: 12: 12: 12: 12:     event SetLock(uint256 _prev, uint256 _new);
13: 13: 13: 13: 13:     
14: 14: 14: 14: 14:     constructor() public {
15: 15: 15: 15: 15:         lock = now;
16: 16: 16: 16: 16:         emit SetLock(0, now);
17: 17: 17: 17: 17:     }
18: 18: 18: 18: 18:     
19: 19: 19: 19: 19:     modifier onUnlocked() {
20: 20: 20: 20: 20:         require(now >= lock, "Wallet locked");
21: 21: 21: 21: 21:         _;
22: 22: 22: 22: 22:     }
23: 23: 23: 23: 23:     
24: 24: 24: 24: 24:     function setLock(uint256 _lock) external onlyOwner {
25: 25: 25: 25: 25:         require(_lock > lock, "Can't set lock to past");
26: 26: 26: 26: 26:         require(_lock - lock <= MAX_LOCK_JUMP, "Max lock jump exceeded");
27: 27: 27: 27: 27:         emit SetLock(lock, _lock);
28: 28: 28: 28: 28:         lock = _lock;
29: 29: 29: 29: 29:     }
30: 30: 30: 30: 30: 
31: 31: 31: 31: 31:     function withdraw(ERC20 _token, address _to, uint256 _value) external onlyOwner onUnlocked returns (bool) {
32: 32: 32: 32: 32:         return _token.transfer(_to, _value);
33: 33: 33: 33: 33:     }
34: 34: 34: 34: 34:     
35: 35: 35: 35: 35:     function call(address payable _to, uint256 _value, bytes calldata _data) external onlyOwner onUnlocked returns (bool, bytes memory) {
36: 36: 36: 36: 36:         return _to.call.value(_value)(_data);
37: 37: 37: 37: 37:     }
38: 38: 38: 38: 38: }